(* MinCamlの構文を表現するデータ型 (caml2html: syntax_t) *)
type t = t_sub * ((int * int) * (int * int))
and t_sub =
  | Unit
  | Bool of bool
  | Int of int
  | Float of float
  | Not of t
  | Neg of t
  | Add of t * t
  | Sub of t * t
  | Mul of t * t
  | Div of t * t
  | SLL of t * t
  | FNeg of t
  | FAdd of t * t
  | FSub of t * t
  | FMul of t * t
  | FDiv of t * t
  | Eq of t * t
  | LE of t * t
  | If of t * t * t
  | Let of (Id.t * Type.t) * t * t
  | Var of Id.t
  | LetRec of fundef * t
  | App of t * t list
  | Tuple of t list
  | LetTuple of (Id.t * Type.t) list * t * t
  | Array of t * t
  | Get of t * t
  | Put of t * t * t
and fundef = { name : Id.t * Type.t; args : (Id.t * Type.t) list; body : t }

let indent = Global.indent

let rec print n syntax =
	match fst syntax with
	| Unit -> (indent n; print_endline "()")
	| Bool b -> (indent n; 	Printf.printf "Bool(%s)\n" (string_of_bool b))
	| Int i -> (indent n; Printf.printf "Int(%d)\n" i)
	| Float f -> (indent n; Printf.printf "Float(%f)\n" f)
	| Not e -> (indent n; Printf.printf "Not\n"; print (n + 1) e)
	| Neg e -> (indent n; Printf.printf "Neg\n"; print (n + 1) e)
	| Add (e1, e2) -> (indent n; Printf.printf "Add(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| Sub (e1, e2) -> (indent n; Printf.printf "Sub(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| Mul (e1, e2) -> (indent n; Printf.printf "Mul(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| Div (e1, e2) -> (indent n; Printf.printf "Div(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| SLL (e1, e2) -> (indent n; Printf.printf "SLL(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| Neg e -> (indent n; Printf.printf "FNeg\n"; print (n + 1) e)
	| FAdd (e1, e2) -> (indent n; Printf.printf "FAdd(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| FSub (e1, e2) -> (indent n; Printf.printf "FSub(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| FMul (e1, e2) -> (indent n; Printf.printf "FMul(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| FDiv (e1, e2) -> (indent n; Printf.printf "FDiv(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| Eq (e1, e2) -> (indent n; Printf.printf "Eq(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| LE (e1, e2) -> (indent n; Printf.printf "LE(\n"; print (n + 1) e1; print (n + 1) e2; indent n; Printf.printf ")\n")
	| If (e1, e2, e3) ->
		begin
			indent n;
			Printf.printf "If\n";
			print (n + 1) e1;
			indent n; Printf.printf "Then\n";
			print (n + 1) e2;
			indent n; Printf.printf "Else\n";
			print (n + 1) e3
		end
	| Let ((id, typ), e1, e2) ->
		begin
			indent n;
			Printf.printf "Let %s : %s =\n" id (Type.string_of_type typ);
			print (n + 1) e1;
			indent n;
			Printf.printf "In\n";
			print n e2;
		end
	| Var id ->
		begin
			indent n;
			Printf.printf "Var(%s)\n" id;
		end
	| LetRec (f, e) ->
		begin
			indent n;
			Printf.printf "Let Rec %s : %s ( " (fst f.name) (Type.string_of_type (snd f.name));
			List.iter (fun x -> Printf.printf "%s " (fst x)) f.args;
			Printf.printf ")=\n";
			print (n + 1) f.body;
			indent n;
			Printf.printf "In\n";
			print n e;
		end
	| App (fn, args) ->
		begin
			indent n;
			Printf.printf "Apply\n";
			print (n + 1) fn;
			List.iter (fun x -> print (n + 1) x) args;
		end
	| Tuple elems ->
		begin
			indent n;
			Printf.printf "Tuple\n";
			List.iter (fun x -> print (n + 1) x) elems;
		end
	| LetTuple (elems, tpl, e) ->
		begin
			let len = List.length elems in
			let cnt = ref 1 in
			indent n;
			Printf.printf "Let (";
			List.iter (fun x -> Printf.printf "%s : %s" (fst x) (Type.string_of_type (snd x)); (cnt := !cnt + 1; if !cnt < len then Printf.printf ", ")) elems;
			Printf.printf ") =\n";
			print (n + 1) tpl;
			indent n;
			Printf.printf "In\n";
			print n e
		end
	| Array (e1, e2) ->
		begin
			print n e1;
			indent n;
			Printf.printf "[\n";
			print (n + 1) e2;
			indent n;
			Printf.printf "](Array)\n"
		end
	| Get (e1, e2) ->
		begin
			print n e1;
			indent n;
			Printf.printf "[\n";
			print (n + 1) e2;
			indent n;
			Printf.printf "]\n";
		end
	| Put (e1, e2, e3) ->
		begin
			print n e1;
			indent n;
			Printf.printf "[\n";
			print (n + 1) e2;
			indent n;
			Printf.printf "]\n";
			indent n;
			Printf.printf "<-\n";
			print (n + 1) e2;
		end
	| _ -> ()

