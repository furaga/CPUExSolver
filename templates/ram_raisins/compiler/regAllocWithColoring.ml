(* TODO *)
open Asm

let fixed = ref S.empty

let cur_fun = ref ""

(* auxiliary function for g and g'_and_restore *)
let add x r regenv =
  if is_reg x then (assert (x = r); regenv) else
  M.add x r regenv

(* auxiliary functions for g' *)
exception NoReg of Id.t * Type.t
let find x t regenv =
  if is_reg x then x else
  try M.find x regenv
  with Not_found -> raise (NoReg(x, t))
let find' x' regenv =
  match x' with
  | V(x) -> V(find x Type.Int regenv)
  | c -> c

let rec g dest cont regenv = function (* 命令列のレジスタ割り当て (caml2html: regalloc_g) *)
  | Ans(exp) -> g'_and_restore dest cont regenv exp
  | Let((x, t) as xt, exp, e) ->
(*      print_endline x; flush stdout;*)
      assert (not (M.mem x regenv));
      let cont' = concat e dest cont in
      let (e1', regenv1) = g'_and_restore xt cont' regenv exp in
      let r = 
      	if is_reg x then x 
      	else if t = Type.Unit then
      		"$r0"
      	else
      		try M.find x !Coloring.color with Not_found -> Printf.eprintf "not found %s\n" x; assert false in
	  let (e2', regenv2) = g dest cont (add x r regenv1) e in
	  (concat e1' (r, t) e2', regenv2)
and g'_and_restore dest cont regenv exp = (* 使用される変数をスタックからレジスタへRestore (caml2html: regalloc_unspill) *)
  try g' dest cont regenv exp
  with NoReg(x, t) ->
    ( (*Format.eprintf "restoring %s@." x;*)
     g dest cont regenv (Let((x, t), Restore(x), Ans(exp))))
and g' dest cont regenv = function (* 各命令のレジスタ割り当て (caml2html: regalloc_gprime) *)
  | Nop | Set _ | Float _ | SetL _ | Comment _ | Restore _ as exp -> (Ans(exp), regenv)
  | Mov(x) -> (Ans(Mov(find x Type.Int regenv)), regenv)
  | Neg(x) -> (Ans(Neg(find x Type.Int regenv)), regenv)
  | Add(x, y') -> (Ans(Add(find x Type.Int regenv, find' y' regenv)), regenv)
  | Sub(x, y') -> (Ans(Sub(find x Type.Int regenv, find' y' regenv)), regenv)
  | Mul(x, y') -> (Ans(Mul(find x Type.Int regenv, find' y' regenv)), regenv)
  | Div(x, y') -> (Ans(Div(find x Type.Int regenv, find' y' regenv)), regenv)
  | SLL(x, y') -> (Ans(SLL(find x Type.Int regenv, find' y' regenv)), regenv)
  | Ld(x, y') -> (Ans(Ld(find x Type.Int regenv, find' y' regenv)), regenv)
  | St(x, y, z') -> (Ans(St(find x Type.Int regenv, find y Type.Int regenv, find' z' regenv)), regenv)
  | FMov(x) -> (Ans(FMov(find x Type.Float regenv)), regenv)
  | FNeg(x) -> (Ans(FNeg(find x Type.Float regenv)), regenv)
  | FAdd(x, y) -> (Ans(FAdd(find x Type.Float regenv, find y Type.Float regenv)), regenv)
  | FSub(x, y) -> (Ans(FSub(find x Type.Float regenv, find y Type.Float regenv)), regenv)
  | FMul(x, y) -> (Ans(FMul(find x Type.Float regenv, find y Type.Float regenv)), regenv)
  | FDiv(x, y) -> (Ans(FDiv(find x Type.Float regenv, find y Type.Float regenv)), regenv)
  | LdF(x, y') -> (Ans(LdF(find x Type.Int regenv, find' y' regenv)), regenv)
  | StF(x, y, z') -> (Ans(StF(find x Type.Float regenv, find y Type.Int regenv, find' z' regenv)), regenv)
  | IfEq(x, y', e1, e2) as exp -> g'_if dest cont regenv exp (fun e1' e2' -> IfEq(find x Type.Int regenv, find' y' regenv, e1', e2')) e1 e2
  | IfLE(x, y', e1, e2) as exp -> g'_if dest cont regenv exp (fun e1' e2' -> IfLE(find x Type.Int regenv, find' y' regenv, e1', e2')) e1 e2
  | IfGE(x, y', e1, e2) as exp -> g'_if dest cont regenv exp (fun e1' e2' -> IfGE(find x Type.Int regenv, find' y' regenv, e1', e2')) e1 e2
  | IfFEq(x, y, e1, e2) as exp -> g'_if dest cont regenv exp (fun e1' e2' -> IfFEq(find x Type.Float regenv, find y Type.Float regenv, e1', e2')) e1 e2
  | IfFLE(x, y, e1, e2) as exp -> g'_if dest cont regenv exp (fun e1' e2' -> IfFLE(find x Type.Float regenv, find y Type.Float regenv, e1', e2')) e1 e2
  | CallCls(x, ys, zs) as exp -> g'_call x dest cont regenv exp (fun ys zs -> CallCls(find x Type.Int regenv, ys, zs)) ys zs
  | CallDir(Id.L x, ys, zs) as exp -> g'_call x dest cont regenv exp (fun ys zs -> CallDir(Id.L x, ys, zs)) ys zs
  | Save(x, y) -> (Ans (Save (find x Type.Unit regenv, y)), regenv)
and g'_if dest cont regenv exp constr e1 e2 = (* ifのレジスタ割り当て (caml2html: regalloc_if) *)
	let (e1', regenv1) = g dest cont regenv e1 in
	let (e2', regenv2) = g dest cont regenv e2 in
	let regenv' = (* 両方に共通のレジスタ変数だけ利用 *)
		List.fold_left
			(fun regenv' x ->
			try
				if is_reg x then regenv' else
					let r1 = M.find x regenv1 in
					let r2 = M.find x regenv2 in
					if r1 <> r2 then regenv' else
						M.add x r1 regenv'
			with Not_found -> regenv')
			M.empty
					(fv cont) in
	(List.fold_left
		(fun e x ->
			if x = fst dest || not (M.mem x regenv) || M.mem x regenv' then e else
			seq(Save(M.find x regenv, x), e)) (* そうでない変数は分岐直前にセーブ *)
		(Ans(constr e1' e2'))
		(fv cont), 
	regenv')
and g'_call id dest cont regenv exp constr ys zs = (* 関数呼び出しのレジスタ割り当て (caml2html: regalloc_call) *)
	(List.fold_left
		(fun (e, env) x ->
		(*	Printf.printf "\t(%s, %s)\n" x (if M.mem x regenv then M.find x regenv else "");
		*)	if x = fst dest || not (M.mem x regenv) then (* 返り値と同じレジスタ/まだ登録されていない変数は退避しない *)
				(e, env)
			else if S.mem (M.find x regenv) (Asm.get_use_regs id) then
				begin
(*					Printf.printf "Save %s = %s\n" (M.find x regenv) x;*)
					(seq (Save (M.find x regenv, x), e), env)
				end
			else if id = !cur_fun then	(* 自己再帰なら問答無用で退避 *)
				begin
(*					Printf.printf "Save %s = %s\n" (M.find x regenv) x;*)
					(seq (Save (M.find x regenv, x), e), env)
				end
			else (* 登録されてはいるが退避しなくてもいいレジスタ *)
				(e, M.add x (M.find x regenv) env))
		(Ans (constr
				(List.map (fun y -> find y Type.Int regenv) ys)
				(List.map (fun z -> find z Type.Float regenv) zs)), M.empty)
		(fv cont)
	)
	
(* 式の中で適用される各関数で使用されるレジスタの集合を返す。tailは関数の末尾かどうか *)
let rec get_use_regs id = function
	| Ans e -> get_use_regs' id e
	| Let ((x, _), e, t) ->
		S.add
			x
			(S.union
				(get_use_regs' id e) (* eはlet x = e in tのeの部分なので当然末尾ではない *)
				(get_use_regs id t))
and get_use_regs' id = function
	| IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) | IfGE(_, _, e1, e2) | IfFEq(_, _, e1, e2) | IfFLE(_, _, e1, e2) -> S.union (get_use_regs id e1) (get_use_regs id e2)
	| CallDir(Id.L x, ys, zs) when is_reg x -> assert false	(* ラベル名がレジスタとかありえない *)
	| CallDir(Id.L x, ys, zs) when x = id -> S.empty			(* 自分自身なら得られる情報がないのでS.empty *)
	| CallDir(Id.L x, ys, zs) -> Asm.get_use_regs x			(* 登録された情報を参照 *)
	| CallCls(x, ys, zs) when is_reg x && x <> reg_cl -> S.of_list (allregs @ allfregs)	(* 自分以外を指すレジスタなら全部のレジスタを退避すべき *)
	| CallCls(x, ys, zs) when x = reg_cl || x = id -> S.empty	(* 自分自身なら得られる情報がないのでS.empty *)
	| CallCls(x, ys, zs) -> Asm.get_use_regs x					(* 登録された情報を参照 *)
	| SetL (Id.L x) when String.sub x 0 2 = "l." -> S.empty	(* 浮動小数テーブルのラベルなので無視 *)
	| SetL (Id.L x) when x = id -> S.empty						(* 自分自身なら得られる情報がないのでS.empty *)
	| SetL (Id.L x) -> Asm.get_use_regs x						(* 登録された情報を参照 *)
	| _ -> S.empty												(* それ以外の式に現れるレジスタは退避しなくてもいい *)
	
let h { name = Id.L(x); args = ys; fargs = zs; body = e; ret = t } = (* 関数のレジスタ割り当て (caml2html: regalloc_h) *)
	(*Printf.eprintf "allocate %s\n" x;*)

	(* すべての関数はvirtual.mlでfundataに登録されているはず *)
	let data =
		if M.mem x !fundata then
			M.find x !fundata
		else
			assert false in

	cur_fun := x;

	(* 関数からクロージャ用レジスタへの写像を追加（再帰用） *)
	let regenv = M.add x reg_cl M.empty in
	(* 各仮引数から上で求めたレジスタへの写像を追加 *)
	let regenv = List.fold_left2
					(fun env x r -> M.add x r env
					) regenv (ys @ zs) data.arg_regs in
	let cont = Ans (if t = Type.Float then FMov data.ret_reg else Mov data.ret_reg) in

	(* 関数本体へのレジスタ割り当て *)
	let (e', _) = g (data.ret_reg, t) cont regenv e in
	
	(* use_regsを正しい値にする。（この時点では allregs @ allfregs がuse_regsに入っている） *)
	(* 正しい値とは、e'の中で使用されるレジスタ＋引数＋返り値（$r3または$f0） *)
	fundata := M.add x data !fundata;
	let env = S.union (S.of_list data.arg_regs) (S.add data.ret_reg (get_use_regs x e')) in
	let env = S.filter is_reg env in
	let env = S.union (S.of_list [reg_sw; reg_fsw]) env in
	
	let data = { data with use_regs = env} in
	fundata := M.add x data !fundata;

	(* レジスタ割り当てを済ませたのでその結果をhの返り値とする *)
(*	print_string "\targs: "; List.iter (fun x -> print_string (x ^ ", ")) (List.filter (fun x -> List.mem x allregs) data.arg_regs); print_newline ();
	print_string "\tfargs: "; List.iter (fun x -> print_string (x ^ ", ")) (List.filter (fun x -> List.mem x allfregs) data.arg_regs); print_newline ();
	print_string "\tret: "; print_endline data.ret_reg;
	print_string "\tuse_regs: "; S.iter (fun x -> print_string (x ^ ", ")) data.use_regs; print_newline (); flush stdout;*)
	{	name = Id.L x;
		args = List.filter (fun x -> List.mem x allregs) data.arg_regs;
		fargs = List.filter (fun x -> List.mem x allfregs) data.arg_regs;
		body = e'; 
		ret = t }

let f (Block.Prog(fundefs, main_fun)) = (* プログラム全体のレジスタ割り当て (caml2html: regalloc_f) *)
	Format.eprintf "start register allocation(graph coloring): may take some time.@.";
	(* メイン関数以外を彩色してAsmに戻してレジスタ割り当て *)
	let fundefs' = 
		List.map (
			fun fundef ->
				Coloring.main true fundef;
				h (ToAsm.h fundef)
		) fundefs in
	(* メイン関数を彩色してAsmに戻してレジスタ割り当て *)
	Coloring.main true main_fun;
	let e = (ToAsm.h main_fun).body in
	let e', regenv' = g (Id.gentmp Type.Unit, Type.Unit) (Ans(Nop)) M.empty e in

	let ans = Prog (fundefs', e') in
(*	Asm.print_prog 0 prog;
	Asm.print_prog 0 ans;*)
	ans

