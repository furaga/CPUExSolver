type t = (* MinCamlの型を表現するデータ型 (caml2html: type_t) *)
  | Unit
  | Bool
  | Int
  | Float
  | Fun of t list * t (* arguments are uncurried *)
  | Tuple of t list
  | Array of t
  | Var of t option ref

let rec string_of_type = function
	| Unit -> "Unit"
	| Bool -> "Bool"
	| Int -> "Int"
	| Float -> "Float"
	| Fun (args, ret) ->
		(List.fold_left (fun a x -> a ^ (string_of_type x) ^ " -> ") "" args) ^ (string_of_type ret)
	| Tuple elems ->
		let len = List.length elems in
		let cnt = ref 0 in
		(List.fold_left (fun a x -> a ^ (string_of_type x) ^ (cnt := !cnt + 1; if !cnt < len then " * " else "")) "(" elems) ^ ")"
	| Array x ->
		"Array(" ^ (string_of_type x) ^ ")"
	| Var x ->
		begin
			match !x with
				| Some xx -> "Var[" ^ (string_of_type xx) ^ "]"
				| None -> "Var[None]"
		end

let print typ = print_string (string_of_type typ)

let gentyp () = Var(ref None) (* 新しい型変数を作る *)
