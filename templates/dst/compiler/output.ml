(* Emitの出力を加工して、無駄な部分を省く *)

type t =
	| Comment of string
	| Label of Id.t
	| JCmp of Id.t * Id.t * Id.t * Id.t
	| SetL of Id.t * Id.t
	| FSet of Id.t * float
	| FMvhi of Id.t * int
	| FMvlo of Id.t * int
	| Mvhi of Id.t * int
	| Mvlo of Id.t * int
	| Mov of Id.t * Id.t
	| FMov of Id.t * Id.t
	| FNeg of Id.t * Id.t
	| Add of Id.t * Id.t * Id.t
	| Sub of Id.t * Id.t * Id.t
	| Mul of Id.t * Id.t * Id.t
	| Div of Id.t * Id.t * Id.t
	| SLL of Id.t * Id.t * Id.t
	| Addi of Id.t * Id.t * int
	| Subi of Id.t * Id.t * int
	| Muli of Id.t * Id.t * int
	| Divi of Id.t * Id.t * int
	| SLLi of Id.t * Id.t * int
	| SRLi of Id.t * Id.t * int
	| FAdd of Id.t * Id.t * Id.t
	| FSub of Id.t * Id.t * Id.t
	| FMul of Id.t * Id.t * Id.t
	| FDiv of Id.t * Id.t * Id.t
	| FPI of Id.t * Id.t * Id.t
	| FAbs of Id.t * Id.t
	| FInv of Id.t * Id.t
	| FMovI of Id.t * Id.t
	| IMovF of Id.t * Id.t
	| Ld of Id.t * Id.t * Id.t
	| St of Id.t * Id.t * Id.t
	| Ldi of Id.t * Id.t * int
	| Sti of Id.t * Id.t * int
	| LdF of Id.t * Id.t * Id.t
	| StF of Id.t * Id.t * Id.t
	| LdFi of Id.t * Id.t * int
	| StFi of Id.t * Id.t * int
	| Input of Id.t
	| InputW of Id.t
	| InputF of Id.t
	| Output of Id.t
	| OutputW of Id.t
	| OutputF of Id.t
	| B of Id.t
	| Jmp of Id.t
	| Jal of Id.t
	| Jarl of Id.t
	| Call of Id.t
	| CallR of Id.t
	| Return
	| Halt

type state = Exist | Vanish
	
type stmt = {
	inst : t;
	mutable state : state
}

let prog = ref []
let add_stmt inst = prog := {inst = inst; state = Exist} :: !prog

(* 一文を出力 *)
let output_stmt oc stmt =
	if stmt.state = Vanish then ()
	else (
		(match stmt.state with
			| Exist -> ()
			| Vanish -> Printf.fprintf oc "# "
		);
		match stmt.inst with
			| Comment comment -> Printf.fprintf oc "%s\n" comment
			| Label label -> Printf.fprintf oc "%s:\n" label
			| SetL (dst, label) -> 	Printf.fprintf oc "\tsetl %s, %s\n" dst label (* ラベルのコピー *)
			| FSet (dst, f) -> 	Printf.fprintf oc "\tfliw %s, %.20E\n" dst f
			| FMvhi (dst, n) -> Printf.fprintf oc "\tfmvhi\t%s, %d\n" dst n
			| FMvlo (dst, n) -> Printf.fprintf oc "\tfmvlo\t%s, %d\n" dst n
			| Mvhi (dst, n) -> Printf.fprintf oc "\tmvhi\t%s, %d\n" dst n
			| Mvlo (dst, n) -> Printf.fprintf oc "\tmvlo\t%s, %d\n" dst n
			| Mov (dst, src) -> Printf.fprintf oc "\tmov\t%s, %s\n" dst src
			| FMov (dst, src) -> Printf.fprintf oc "\tfmov\t%s, %s\n" dst src
			| FNeg (dst, src) -> Printf.fprintf oc "\tfneg\t%s, %s\n" dst src
			| Add (dst, x, y) -> Printf.fprintf oc "\tadd\t%s, %s, %s\n" dst x y
			| Sub (dst, x, y) -> Printf.fprintf oc "\tsub\t%s, %s, %s\n" dst x y
			| Mul (dst, x, y) -> Printf.fprintf oc "\tmul\t%s, %s, %s\n" dst x y
			| Div (dst, x, y) -> Printf.fprintf oc "\tdiv\t%s, %s, %s\n" dst x y
			(* コンパイラでSLLが発行されることは現状ない *)
			| SLL (dst, x, y) -> failwith "this architecture must support sll or shift."
			| Addi (dst, x, y) -> Printf.fprintf oc "\taddi\t%s, %s, %d\n" dst x y
			| Subi (dst, x, y) -> Printf.fprintf oc "\tsubi\t%s, %s, %d\n" dst x y
			| Muli (dst, x, y) -> Printf.fprintf oc "\tmuli\t%s, %s, %d\n" dst x y
			| Divi (dst, x, y) -> Printf.fprintf oc "\tdivi\t%s, %s, %d\n" dst x y
			| SLLi (dst, x, y) -> Printf.fprintf oc "\tslli\t%s, %s, %d\n" dst x y
			| SRLi (dst, x, y) -> Printf.fprintf oc "\tsrai\t%s, %s, %d\n" dst x y
			| FAdd (dst, x, y) -> Printf.fprintf oc "\tfadd\t%s, %s, %s\n" dst x y
			| FSub (dst, x, y) -> Printf.fprintf oc "\tfsub\t%s, %s, %s\n" dst x y
			| FMul (dst, x, y) -> Printf.fprintf oc "\tfmul\t%s, %s, %s\n" dst x y
			| FDiv (dst, x, y) -> Printf.fprintf oc "\tfdiv\t%s, %s, %s\n" dst x y
			| FPI (op, dst, src) -> Printf.fprintf oc "\t%s\t%s, %s\n" op dst src
			| FAbs (dst, src) -> Printf.fprintf oc "\tfabs\t%s, %s\n" dst src

			| FInv (dst, src) -> Printf.fprintf oc "\tfinv\t%s, %s\n" dst src
			| FMovI (dst, src) -> Printf.fprintf oc "\tfmovi\t%s, %s\n" dst src
			| IMovF (dst, src) -> Printf.fprintf oc "\timovf\t%s, %s\n" dst src

			(* 即値バージョンのLd, St系では、大人の事情によりindexの符号が逆になってしまっているので符号を反転させる。 *)
			| Ld (dst, src, index) -> Printf.fprintf oc "\tld\t%s, %s, %s\n" dst src index
			| Ldi (dst, src, index) -> Printf.fprintf oc "\tldi\t%s, %s, %d\n" dst src (-index);
			| LdF (dst, src, index) -> Printf.fprintf oc "\tfld\t%s, %s, %s\n" dst src index
			| LdFi (dst, src, index) -> Printf.fprintf oc "\tfldi\t%s, %s, %d\n" dst src (-index);
			| St (src, target, index) -> Printf.fprintf oc "\tst\t%s, %s, %s\n" src target index
			| Sti (src, target, index) -> Printf.fprintf oc "\tsti\t%s, %s, %d\n" src target (-index);
			| StF (src, target, index) -> Printf.fprintf oc "\tfst\t%s, %s, %s\n" src target index
			| StFi (src, target, index) -> Printf.fprintf oc "\tfsti\t%s, %s, %d\n" src target (-index);
			| Input src -> 	Printf.fprintf oc "\tinput\t%s\n" src
			| InputW src -> Printf.fprintf oc "\tinputw\t%s\n" src
			| InputF src -> Printf.fprintf oc "\tinputf\t%s\n" src
			| Output dst -> Printf.fprintf oc "\toutput\t%s\n" dst
			| OutputW dst -> Printf.fprintf oc "\toutputw\t%s\n" dst
			| OutputF dst -> Printf.fprintf oc "\toutputf\t%s\n" dst
			| B reg -> Printf.fprintf oc "\tjr\t%s\n" reg
			| Jmp label -> Printf.fprintf oc "\tj\t%s\n" label
			| JCmp (typ, x, y, label) -> Printf.fprintf oc "\t%s\t%s, %s, %s\n" typ x y label
			| Jal label -> Printf.fprintf oc "\tjal\t%s\n" label
			| Jarl cls -> Printf.fprintf oc "\tjalr\t%s\n" cls
			| Call label -> Printf.fprintf oc "\tcall\t%s\n" label
			| CallR cls -> Printf.fprintf oc "\tcallr\t%s\n" cls
			| Return -> Printf.fprintf oc "\treturn\n"
			| Halt -> Printf.fprintf oc "\thalt\n"
	)

(* 出力 *)
let output oc = List.iter (output_stmt oc) (List.rev !prog)

