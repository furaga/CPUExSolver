open Asm
open Block

let find x env = try M.find x env with Not_found -> Printf.printf "Not_found [%s]\n" x; flush stdout; assert false

let rec g f blk_id =
	let blk = find blk_id f.fBlocks in
	let (e, res_blk) = g' f blk blk.bHead in
	(e, res_blk)

and g' f blk stmt_id =
	let (exp, res_blk) = 
		let stmt = find stmt_id blk.bStmts in
		let (xt, exp, res_blk) = get_exp f blk stmt.sInst in
		if stmt.sSucc <> "" then begin (* 基本ブロックの末尾じゃなかったら *)
			assert (blk = res_blk); (* res_blkは今見ているブロックと同一のはず *)
			let (e, res_blk) = g' f blk stmt.sSucc in
			let ans = (Let (xt, exp, e), res_blk) in
			ans
		end else (* 基本のブロックの末尾だったら *)
			if List.length res_blk.bSuccs <= 0 then (* 後続節がなければ終わり *)
				(Ans exp, res_blk)
			else begin
				assert (List.length res_blk.bSuccs = 1);	(* 後続節は一個だけのはず *)
				let succ_id = List.hd res_blk.bSuccs in
				let succ_blk = find succ_id f.fBlocks in
				assert (List.length succ_blk.bPreds = 2); (* 後続節の先行節は2つだけ *)
				if List.length blk.bSuccs = 1 then
					(Ans exp, res_blk)
				else if M.is_empty succ_blk.bStmts then
					(Ans exp, succ_blk)
				else
					let (e, res_blk) = g' f succ_blk succ_blk.bHead in
					(Let (xt, exp, e), res_blk)
			end
	 in
	(exp, res_blk)
	
and get_exp f blk = function
	| Block.Nop xt -> (xt, Asm.Nop, blk) 
	| Block.Set (xt, x) -> (xt, Asm.Set x, blk) 
	| Block.SetL (xt, Id.L x) -> (xt, Asm.SetL (Id.L x), blk) 
	| Block.Mov (xt, x) -> (xt, Asm.Mov x, blk)
	| Block.Neg (xt, x) -> (xt, Asm.Neg x, blk)
	| Block.Add (xt, x, y') -> (xt, Asm.Add (x, y'), blk)
	| Block.Sub (xt, x, y') -> (xt, Asm.Sub (x, y'), blk)
	| Block.Mul (xt, x, y') -> (xt, Asm.Mul (x, y'), blk)
	| Block.Div (xt, x, y') -> (xt, Asm.Div (x, y'), blk)
	| Block.SLL (xt, x, y') -> (xt, Asm.SLL (x, y'), blk)
	| Block.Ld (xt, x, y') -> (xt, Asm.Ld (x, y'), blk)
	| Block.St (xt, x, y, z') -> (xt, Asm.St (x, y, z'), blk)
	| Block.FMov (xt, x) -> (xt, Asm.FMovD x, blk)
	| Block.FNeg (xt, x) -> (xt, Asm.FNegD x, blk)
	| Block.FAdd (xt, x, y) -> (xt, Asm.FAddD (x, y), blk)
	| Block.FSub (xt, x, y) -> (xt, Asm.FSubD (x, y), blk)
	| Block.FMul (xt, x, y) -> (xt, Asm.FMulD (x, y), blk)
	| Block.FDiv (xt, x, y) -> (xt, Asm.FDivD (x, y), blk)
	| Block.LdF (xt, x, y') -> (xt, Asm.LdDF (x, y'), blk)
	| Block.StF (xt, x, y, z') -> (xt, Asm.StDF (x, y, z'), blk)
	| Block.IfEq (xt, x, y', b1, b2) ->
		let (e1, next_blk1) = g f b1 in
		let (e2, next_blk2) = g f b2 in
(*		Printf.printf "%s %s => " b1 b2;
		Printf.printf "IfEq %s %s\n" next_blk1.bId next_blk2.bId;*)
		assert (next_blk1.bSuccs = next_blk2.bSuccs);
		(xt, Asm.IfEq (x, y', e1, e2), next_blk1)
	| Block.IfLE (xt, x, y', b1, b2) ->
		let (e1, next_blk1) = g f b1 in
		let (e2, next_blk2) = g f b2 in
(*		Printf.printf "%s %s => " b1 b2;
		Printf.printf "IfLE %s %s\n" next_blk1.bId next_blk2.bId;*)
		assert (next_blk1.bSuccs = next_blk2.bSuccs);
		(xt, Asm.IfLE (x, y', e1, e2), next_blk1)
	| Block.IfGE (xt, x, y', b1, b2) ->
		let (e1, next_blk1) = g f b1 in
		let (e2, next_blk2) = g f b2 in
(*		Printf.printf "%s %s => " b1 b2;
		Printf.printf "IfGE %s %s\n" next_blk1.bId next_blk2.bId;*)
		assert (next_blk1.bSuccs = next_blk2.bSuccs);
		(xt, Asm.IfGE (x, y', e1, e2), next_blk1)
	| Block.IfFEq (xt, x, y, b1, b2) ->
		let (e1, next_blk1) = g f b1 in
		let (e2, next_blk2) = g f b2 in
(*		Printf.printf "%s %s => " b1 b2;
		Printf.printf "IfFEq %s %s\n" next_blk1.bId next_blk2.bId;*)
		assert (next_blk1.bSuccs = next_blk2.bSuccs);
		(xt, Asm.IfFEq (x, y, e1, e2), next_blk1)
	| Block.IfFLE (xt, x, y, b1, b2) ->
		let (e1, next_blk1) = g f b1 in
		let (e2, next_blk2) = g f b2 in
(*		Printf.printf "%s %s => " b1 b2;
		Printf.printf "IfFLE %s %s\n" next_blk1.bId next_blk2.bId;*)
		assert (next_blk1.bSuccs = next_blk2.bSuccs);
		(xt, Asm.IfFLE (x, y, e1, e2), next_blk1)
	| Block.CallCls (xt, name, args, fargs) -> (xt, Asm.CallCls (name, args, fargs), blk)
	| Block.CallDir (xt, Id.L name, args, fargs) -> (xt, Asm.CallDir (Id.L name, args, fargs), blk)
	| Block.Save (xt, x, y) -> (xt, Asm.Save (x, y), blk)
	| Block.Restore (xt, x) -> (xt, Asm.Restore x, blk)

let h fundef = 
	{
		name = fundef.fName;
		args = fundef.fArgs;
		fargs = fundef.fFargs;
		body = fst (g fundef fundef.fHead);
		ret = fundef.fRet
	}

let f (Block.Prog (data, fundefs, main_fun)) =
	let ans = Asm.Prog (data, List.map h fundefs, (h main_fun).body) in
(*	Asm.print_prog 0 ans;*)
	ans
