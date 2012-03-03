(* Floatの定数を読み込む部分を高速化したい *)
open Asm

let floatTable = ref []

let inc f env =
	if List.mem_assoc f env then
		(f, 1 + List.assoc f env)::(List.remove_assoc f env)
	else
		(f, 1)::env

let rec count env = function
	| Ans exp -> count' env exp
	| Let (_, exp, e) -> count (count' env exp) e
and count' env = function
	| Float f -> inc f env
	| IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) | IfGE(_, _, e1, e2) | IfFEq(_, _, e1, e2) | IfFLE(_, _, e1, e2) -> count (count env e1) e2
	| _ -> env

let rec g = function
	| Let (x, exp, e) -> Let (x, g' exp, g e)
	| Ans exp -> Ans (g' exp)
	| e -> e
and g' = function
	| Float f when List.mem_assoc f !floatTable -> FMov (List.assoc f !floatTable)
	| IfEq(a, b, e1, e2)  -> IfEq(a, b, g e1, g e2)
	| IfLE(a, b, e1, e2)  -> IfLE(a, b, g e1, g e2)
	| IfGE(a, b, e1, e2)  -> IfGE(a, b, g e1, g e2)
	| IfFEq(a, b, e1, e2) -> IfFEq(a, b, g e1, g e2) 
	| IfFLE(a, b, e1, e2) -> IfFLE(a, b, g e1, g e2)
	| e -> e
let h { name = l; args = xs; fargs = ys; body = e; ret = t } = { name = l; args = xs; fargs = ys; body = g e; ret = t }
	
let f (Prog (fundefs, e)) =
	let cnts =
		List.fold_left (
			fun env {name = l; args = xs; fargs = ys; body = e; ret = t} ->
				count env e
		) [] fundefs in
	let cnts = count cnts e in
	let cnts = List.sort (fun (_, n1) (_, n2) -> n2 - n1) cnts in
	
(*	List.iter (
		fun (f, n) ->
			Printf.printf "f = %f, n = %d\n" f n
	) cnts;*)
	
	let cnt =
		List.fold_left (
			fun cnt (f, _) ->
				if cnt >= List.length reg_fgs then
					cnt
				else
					let r = List.nth reg_fgs cnt in
					floatTable := (f, r) :: !floatTable;
					cnt + 1
		) 0 cnts in
	assert (cnt <= List.length reg_fgs);
	
	let e = g e in
	let e' =
		List.fold_left (
			fun e (f, r) -> Let ((r, Type.Float), Float f, e)
		) e !floatTable in
	let ans = Prog (List.map h fundefs, e') in
	ans

