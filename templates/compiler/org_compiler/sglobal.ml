(* Floatの定数を読み込む部分を高速化したい *)

open Asm

let gtable = ref []

(* envにはl[i]という要素が何度プログラム内に登場したかが記録されている *)
let rec inc' i env' =
	if List.mem_assoc i env' then
		(i, (List.assoc i env') + 1) :: (List.remove_assoc i env')
	else (i, 1) :: env'
let rec inc l i env =
	if M.mem l env then
		M.add l (inc' i (M.find l env)) env
	else M.add l [(i, 1)] env

let rec count env = function
	| Let ((x, _), SetL(Id.L(l)), Ans (LdDF(y, C(i)))) when x = y -> inc l i env
	| Let ((x, _), SetL(Id.L(l)), Let (_, LdDF(y, C(i)), e)) when x = y -> count (inc l i env) e
	| Ans exp -> count' env exp
	| Let (_, exp, e) -> count (count' env exp) e
	| Forget(_, e) -> count env e

and count' env = function
	| IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) | IfGE(_, _, e1, e2) | IfFEq(_, _, e1, e2) | IfFLE(_, _, e1, e2) -> count (count env e1) e2
	| _ -> env

let rec g = function
	| Let ((x, _), SetL(Id.L(l)), Let (zt, LdDF(y, C(i)), e)) when x = y && List.mem_assoc (l, i) !gtable -> Let (zt, FMovD(List.assoc (l, i) !gtable), g e)
	| Let (x, exp, e) -> Let (x, g' exp, g e)
	| Ans exp -> Ans (g' exp)
	| e -> e
and g' = function
	| IfEq(a, b, e1, e2)  -> IfEq(a, b, g e1, g e2)
	| IfLE(a, b, e1, e2)  -> IfLE(a, b, g e1, g e2)
	| IfGE(a, b, e1, e2)  -> IfGE(a, b, g e1, g e2)
	| IfFEq(a, b, e1, e2) -> IfFEq(a, b, g e1, g e2) 
	| IfFLE(a, b, e1, e2) -> IfFLE(a, b, g e1, g e2)
	| e -> e

let h { name = l; args = xs; fargs = ys; body = e; ret = t } = { name = l; args = xs; fargs = ys; body = g e; ret = t }

let f (Prog(data, fundefs, e)) =
	let counts = List.fold_left (fun env { name = l; args = xs; fargs = ys; body = e; ret = t} -> count env e) M.empty fundefs in
	let counts = count counts e in
	let gls = M.fold (fun l env' ls -> List.fold_left (fun ls (i, n) -> (l, i, n) :: ls) ls env') counts [] in
	let gls = List.sort (fun (_, _, n1) (_, _, n2) -> n2 - n1) gls in
	
	let _  = List.fold_left
	  (fun use_fgs (l, i, _) ->
	  	if String.sub l 0 2 = "l." then (* 定数テーブルに入ってたら。定数テーブルには入るのは浮動小数点のみ（2011/10/21現在） *)
	  		(* 可能ならそのラベルにAsm.reg_fgsのレジスタを一つ割り当てる *)
			if use_fgs >= List.length reg_fgs then
				use_fgs
			else
				let r = List.nth reg_fgs use_fgs in
				gtable := ((l, i), r) :: !gtable;
				use_fgs + 1
		else
			use_fgs
	  )
	  0 gls
	in
	(*(* for debug *)
	let rec show ls =
		match ls with
			| [] -> (Printf.printf "\tlen = %d\n" (List.length gls); flush stdout)
			| ((l, i), r) :: xs -> 
				begin
					Printf.printf "\t%s[%d] => %s\n" l i r;
					show xs
				end in
	show !gtable;*)
	let e = g e in
	let e' = List.fold_left
	  (fun e ((l, i), r) ->
	  	Let((reg_sw, Type.Int), SetL(Id.L(l)), (* reg_swは自由に使っていいはず *)
	  		Let ((r, Type.Float), LdDF(reg_sw, C i),
	  			e))
	  ) e !gtable in
	
	let ans = Prog(data, List.map h fundefs, e') in
	ans
