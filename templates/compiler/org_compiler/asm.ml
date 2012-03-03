(* SPARC assembly with a few virtual instructions *)
type id_or_imm = V of Id.t | C of int
(*type id_or_imm' = V' of Id.t | C' of Id.t * int*)
type t =
	| Ans of exp
	| Let of (Id.t * Type.t) * exp * t
	| Forget of Id.t * t
and exp =
	| Nop
	| Set of int
	| SetL of Id.l
	| Mov of Id.t
	| Neg of Id.t
	| Add of Id.t * id_or_imm
	| Sub of Id.t * id_or_imm
	| Mul of Id.t * id_or_imm
	| Div of Id.t * id_or_imm
	| SLL of Id.t * id_or_imm
	| Ld of Id.t * id_or_imm
	| St of Id.t * Id.t * id_or_imm
	| FMovD of Id.t
	| FNegD of Id.t
	| FAddD of Id.t * Id.t
	| FSubD of Id.t * Id.t
	| FMulD of Id.t * Id.t
	| FDivD of Id.t * Id.t
	| LdDF of Id.t * id_or_imm
	| StDF of Id.t * Id.t * id_or_imm
	| Comment of string
	(* virtual instructions *)
	| IfEq of Id.t * id_or_imm * t * t
	| IfLE of Id.t * id_or_imm * t * t
	| IfGE of Id.t * id_or_imm * t * t
	| IfFEq of Id.t * Id.t * t * t
	| IfFLE of Id.t * Id.t * t * t
	(* closure address, integer arguments, and float arguments *)
	| CallCls of Id.t * Id.t list * Id.t list
	| CallDir of Id.l * Id.t list * Id.t list
	| Save of Id.t * Id.t (* レジスタ変数の値をスタック変数へ保存 *)
	| Restore of Id.t (* スタック変数から値を復元 *)
type fundef = { name : Id.l; args : Id.t list; fargs : Id.t list; body : t; ret : Type.t }
(* プログラム全体 = 浮動小数点数テーブル + トップレベル関数 + メインの式 (caml2html: sparcasm_prog) *)
type prog = Prog of (Id.l * float) list * fundef list * t

type fundata = {arg_regs : Id.t list; ret_reg : Id.t; use_regs : S.t}

let fundata = ref (M.add_list
  [
   ("min_caml_floor", { arg_regs = ["%f0"]; ret_reg = "%f0"; use_regs = S.of_list ["%g3"; "%g4"; "%f0"; "%f1"; "%f2"; "%f3"; "%f4"]});
   ("min_caml_ceil", { arg_regs = ["%f0"]; ret_reg = "%f0"; use_regs = S.of_list ["%g3"; "%g4"; "%f0"; "%f1"; "%f2"; "%f3"; "%f4"]});
   ("min_caml_float_of_int", { arg_regs = ["%g3"]; ret_reg = "%f0"; use_regs = S.of_list ["%g3"; "%g4"; "%g5"; "%f0"; "%f1"; "%f2"]});
   ("min_caml_int_of_float", { arg_regs = ["%f0"]; ret_reg = "%g3"; use_regs = S.of_list ["%g3"; "%g4"; "%g5"; "%f0"; "%f1"; "%f2"; "%f3"; "%f4"]});
   ("min_caml_truncate", { arg_regs = ["%f0"]; ret_reg = "%g3"; use_regs = S.of_list ["%g3"; "%g4"; "%g5"; "%f0"; "%f1"; "%f2"; "%f3"; "%f4"]});
   ("min_caml_create_array", { arg_regs = ["%g3"; "%g4"]; ret_reg = "%g3"; use_regs = S.of_list ["%g3"; "%g4"; "%g5"]});
   ("min_caml_create_float_array", { arg_regs = ["%g3"; "%f0"]; ret_reg = "%g3"; use_regs = S.of_list ["%g3"; "%g4"; "%f0"]});
   ("min_caml_print_char", { arg_regs = ["%g3"]; ret_reg = "%dummy"; use_regs = S.of_list ["%g3"]});
   ("min_caml_print_newline", { arg_regs = []; ret_reg = "%dummy"; use_regs = S.of_list ["%g3"]});
   ("min_caml_write", { arg_regs = ["%g3"]; ret_reg = "%g3"; use_regs = S.of_list ["%g3"]});
   ("min_caml_sqrt", { arg_regs = ["%f0"]; ret_reg = "%f0"; use_regs = S.of_list ["%f0"]});
   ("min_caml_newline", { arg_regs = []; ret_reg = "%dummy"; use_regs = S.of_list ["%g3"]});
   ("min_caml_read_char", { arg_regs = []; ret_reg = "%g3"; use_regs = S.of_list ["%g3"]});
   ("min_caml_input_char", { arg_regs = []; ret_reg = "%g3"; use_regs = S.of_list ["%g3"]})
  ] M.empty)

let fletd(x, e1, e2) = Let((x, Type.Float), e1, e2)
let seq(e1, e2) = Let((Id.gentmp Type.Unit, Type.Unit), e1, e2)

(* %g0には常に0が入る *)
let regs = (* Array.init 16 (fun i -> Printf.sprintf "%%r%d" i) *)
  [| "%g3"; "%g4"; "%g5"; "%g6"; "%g7"; "%g8"; "%g9";
  	 "%g10"; "%g11"; "%g12"; "%g13"; "%g14"; "%g15"; "%g16"; "%g17"; "%g18"; "%g19"; 
     "%g20"; "%g21"; "%g22"; "%g23"; "%g24"; "%g25"; "%g26"; "%g27"; "%g30"|]

let freg_num = 16

let fregs = Array.init (freg_num) (fun i -> Printf.sprintf "%%f%d" i)
let allregs = Array.to_list regs
let allfregs = Array.to_list fregs
let reg_cl = regs.(Array.length regs - 1) (* closure address (caml2html: sparcasm_regcl) *)
let reg_sw = regs.(Array.length regs - 2) (* temporary for swap *)
let reg_fsw = fregs.(Array.length fregs - 1) (* temporary for swap *)

let reg_0 = "%g0"	(* 常に０ *)
let reg_p1 = "%g28"	(* 常に１ *)
let reg_m1 = "%g29"	(* 常に-１ *)

let reg_sp = "%g1" (* stack pointer *)
let reg_hp = "%g2" (* heap pointer (caml2html: sparcasm_reghp) *)
let reg_bottom = "%g31" (* return address *)

let reg_fgs = Array.to_list (Array.init (32 - freg_num) (fun i -> Printf.sprintf "%%f%d" (freg_num + i)))

let get_arg_regs x = try (M.find x !fundata).arg_regs with Not_found -> Printf.eprintf "Not_found %s\n" x; assert false
let get_ret_reg x = try (M.find x !fundata).ret_reg with Not_found -> Printf.eprintf "Not_found %s\n" x; assert false
let get_use_regs x = 
	try (M.find x !fundata).use_regs with Not_found -> Printf.printf "\tNotFound %s\n" x; S.of_list (allregs @ allfregs)

let is_reg x = (x.[0] = '%')
(*let co_freg_table =
  let ht = Hashtbl.create 16 in
  for i = 0 to 15 do
    Hashtbl.add
      ht
      (Printf.sprintf "%%f%d" (i * 2))
      (Printf.sprintf "%%f%d" (i * 2 + 1))
  done;
  ht
let co_freg freg = Hashtbl.find co_freg_table freg (* "companion" freg *)*)

(* super-tenuki *)
let rec remove_and_uniq xs = function
  | [] -> []
  | x :: ys when S.mem x xs -> remove_and_uniq xs ys
  | x :: ys -> x :: remove_and_uniq (S.add x xs) ys
let rec cat xs ys env =
	match xs with
		| [] -> ys
		| x :: xs when S.mem x env -> cat xs ys env
		| x :: xs -> x :: cat xs ys (S.add x env)
(* free variables in the order of use (for spilling) (caml2html: sparcasm_fv) *)

let fv_id_or_imm = function V(x) -> [x] | _ -> []
let rec fv' = function
	| Nop | Set(_) | SetL(_) | Comment(_) | Restore(_) -> []
	| Mov(x) | Neg(x) | FMovD(x) | FNegD(x) | Save(x, _) -> [x]
	| Add(x, y') | Sub(x, y') | Mul(x, y') | Div(x, y') | SLL(x, y') | Ld(x, y') | LdDF(x, y') -> x :: fv_id_or_imm y'
	| St(x, y, z') | StDF(x, y, z') -> x :: y :: fv_id_or_imm z'
	| FAddD(x, y) | FSubD(x, y) | FMulD(x, y) | FDivD(x, y) -> [x; y]
	| IfEq(x, y', e1, e2) | IfLE(x, y', e1, e2) | IfGE(x, y', e1, e2) -> x :: fv_id_or_imm y'
	| IfFEq(x, y, e1, e2) | IfFLE(x, y, e1, e2) -> [x; y]
	| CallCls(x, ys, zs) -> x :: ys @ zs
	| CallDir(_, ys, zs) -> ys @ zs

let rec fv_exp env cont e =
	let xs = fv' e in
	match e with
		| IfEq (_, _, e1, e2) | IfLE (_, _, e1, e2) | IfGE (_, _, e1, e2) | IfFEq (_, _, e1, e2) | IfFLE (_, _, e1, e2) ->
		 	cat xs (fv env (fv env cont e2) e1) env
		| _ -> cat xs cont env
and fv env cont = function
	| Ans exp -> fv_exp env cont exp
	| Let ((x, t), exp, e) ->
		let cont' = fv (S.add x env) cont e in
		fv_exp env cont' exp
	| Forget (x, e) -> fv (S.add x env) cont e
let fv e = remove_and_uniq S.empty (fv S.empty [] e)
	
let rec concat e1 xt e2 =
  match e1 with
  | Ans(exp) -> Let(xt, exp, e2)
  | Let(yt, exp, e1') -> Let(yt, exp, concat e1' xt e2)
  | Forget(y, e1') -> Forget(y, concat e1' xt e2)

let align i = (if i mod 4(*8*) = 0 then i else i + 4)

let indent = Global.indent

let rec print n = function
	| Ans e -> (indent n; Printf.printf "Ans (\n"; print_exp (n + 1) e; indent n; Printf.printf ")\n")
	| Let ((id, typ), exp, e) -> (indent n; Printf.printf "Let %s =\n" id; print_exp (n + 1) exp; indent n; Printf.printf "In\n"; print n e)
	| Forget (id, e) -> ()

and print_exp n = function
	| Nop -> (indent n; print_endline "Nop")
	| Set i -> (indent n; Printf.printf "Set (%d)\n" i)
	| SetL (Id.L label) -> (indent n; Printf.printf "Set (%s)\n" label)
	| Mov s -> (indent n; Printf.printf "Mov (%s)\n" s)
	| Neg s -> (indent n; Printf.printf "Neg (%s)\n" s)
	| Add (s, V(v)) -> (indent n; Printf.printf "%s + %s\n" s v)
	| Add (s, C(c)) -> (indent n; Printf.printf "%s + %d\n" s c)
	| Sub (s, V(v)) -> (indent n; Printf.printf "%s - %s\n" s v)
	| Sub (s, C(c)) -> (indent n; Printf.printf "%s - %d\n" s c)

	| Mul (s, V(v)) -> (indent n; Printf.printf "%s * %s\n" s v)
	| Mul (s, C(c)) -> (indent n; Printf.printf "%s * %d\n" s c)
	| Div (s, V(v)) -> (indent n; Printf.printf "%s / %s\n" s v)
	| Div (s, C(c)) -> (indent n; Printf.printf "%s / %d\n" s c)

	| SLL (s, V(v)) -> (indent n; Printf.printf "%s << %s\n" s v)
	| SLL (s, C(c)) -> (indent n; Printf.printf "%s << %d\n" s c)

	| Ld (s, V(v)) -> (indent n; Printf.printf "Lord %s[%s]\n" s v)
	| Ld (s, C(c)) -> (indent n; Printf.printf "Lord %s[%d]\n" s c)

	| St (value, s, V(v)) -> (indent n; Printf.printf "Store %s to %s[%s]\n" value s v)
	| St (value ,s, C(c)) -> (indent n; Printf.printf "Store %s to %s[%d]\n" value s c)

	| FMovD s -> (indent n; Printf.printf "FMovD (%s)\n" s)
	| FNegD s -> (indent n; Printf.printf "FNegD (%s)\n" s)

	| FAddD (s, v) -> (indent n; Printf.printf "%s +. %s\n" s v)
	| FSubD (s, v) -> (indent n; Printf.printf "%s -. %s\n" s v)
	| FMulD (s, v) -> (indent n; Printf.printf "%s *. %s\n" s v)
	| FDivD (s, v) -> (indent n; Printf.printf "%s /. %s\n" s v)

	| LdDF (s, V(v)) -> (indent n; Printf.printf "FLord %s[%s]\n" s v)
	| LdDF (s, C(c)) -> (indent n; Printf.printf "FLord %s[%d]\n" s c)

	| StDF (value, s, V(v)) -> (indent n; Printf.printf "FStore %s to %s[%s]\n" value s v)
	| StDF (value ,s, C(c)) -> (indent n; Printf.printf "FStore %s to %s[%d]\n" value s c)

	| Comment s -> (indent n; Printf.printf "Comment [%s]" s)
	
	(* virtual instructions *)
	| IfEq (id, V(v), e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s = %s Then\n" id v;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfEq (id, C(c), e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s = %d Then\n" id c;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfLE (id, V(v), e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s <= %s Then\n" id v;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfLE (id, C(c), e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s <= %d Then\n" id c;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfGE (id, V(v), e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s >= %s Then\n" id v;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfGE (id, C(c), e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s >= %d Then\n" id c;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfFEq (id, v, e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s =. %s Then\n" id v;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	| IfFLE (id, v, e1, e2) ->
		begin
			indent n;
			Printf.printf "If %s <=. %s Then\n" id v;
			print (n + 1) e1;
			indent n;
			Printf.printf "Then\n";
			print (n + 1) e2;
		end
	(* closure address, integer arguments, and float arguments *)
	| CallCls (addr, args, fargs) ->
		begin
			indent n;
			Printf.printf "CallCls %s " addr;
			List.iter (fun x -> Printf.printf "%s " x) args;
			List.iter (fun x -> Printf.printf "%s " x) fargs;
			print_newline ();
		end
	| CallDir (Id.L addr, args, fargs) ->
		begin
			indent n;
			Printf.printf "CallDir %s " addr;
			List.iter (fun x -> Printf.printf "%s " x) args;
			List.iter (fun x -> Printf.printf "%s " x) fargs;
			print_newline ();
		end
	| Save (id1, id2) ->
		(indent n; Printf.printf "Save %s, %s\n" id1 id2)
	| Restore id ->
		(indent n; Printf.printf "Restore %s\n" id)

and print_fundef n f =
	indent n;
	Type.print f.ret;
	Printf.printf " %s (" ((fun (Id.L x) -> x) f.name);
	List.iter (fun x -> Printf.printf "%s " x) f.args;
	List.iter (fun x -> Printf.printf "%s " x) f.fargs;
	Printf.printf ") =\n";
	print (n + 1) f.body
and print_prog n (Prog (datas, fs, e)) =
	List.iter (fun (Id.L label, value) -> indent n; Printf.printf "%s : %f\n" label value) datas;
	List.iter (fun x -> print_fundef n x) fs;
	print n e

let pp_id_or_imm = function
  | V(x) -> x
  | C(i) -> string_of_int i
