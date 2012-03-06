open Asm

(* gethi, getloはfloat.cで定義された関数。浮動小数をバイナリ列に変換するときに使う *)
external gethi : float -> int32 = "gethi"
external getlo : float -> int32 = "getlo"

(* スタックに退避された変数とその位置 *)
let stackmap = ref M.empty

(* スタックに変数xを退避 *)
let save x = 
	if not (M.mem x !stackmap) then
		stackmap := M.add x (M.length !stackmap) !stackmap

(* 退避された変数xのスタックにおける位置を取得 *)
let get_offset x = 
	try
		4 * M.find x !stackmap
	with Not_found -> failwith ("[Emit.get_offset] " ^ x ^ " is not in stackmap.")

(* スタックサイズを取得 *)
let get_stacksize () = align ((M.length !stackmap + 1) * 4)

(* 変数名ないし即値をId.t( = string)型として取得 *)
let pp_id_or_imm = function
	| V x -> x
	| C i -> string_of_int i

(* 実引数を仮引数に代入する手順を計算(register shuffling) *)
let rec shuffle sw xys =
	(* mov RX, RXのような無意味な移動命令を取り除く *)
	let _, xys = List.partition (fun (x, y) -> x = y) xys in
	(* find acyclic moves *)
	match List.partition (fun (_, y) -> List.mem_assoc y xys) xys with
		| [], [] -> []
		| (x, y) :: xys, [] ->
			(* no acyclic moves; resolve a cyclic move *)
			(y, sw) :: (x, y) ::
			shuffle sw (
				List.map (
					function
						| (y', z) when y = y' -> (sw, z)
						| yz -> yz
				) xys
			)
		| xys, acyc -> acyc @ shuffle sw xys

type dest =
	| Tail				(* 末尾 *)
	| NonTail of Id.t	(* 末尾でない。引数は演算結果の代入先 *)

(* 命令列のアセンブリ生成(ファイルに実際に出力するのはOutput.output関数) *)
let rec g oc = function
	| dest, Ans(exp) -> g' oc (dest, exp)
	| dest, Let((x, t), exp, e) ->
		g' oc (NonTail(x), exp);
		g oc (dest, e)

and g' oc = function
	(**************************************************************************
	 *
	 * 末尾でなかったら計算結果をNonTailの引数xにセット
	 *
	 **************************************************************************)

	(**************************************************************************
	 * 浮動小数演算以外
	 **************************************************************************)

	| NonTail(_), Nop -> ()

	| NonTail(x), Set(i) ->
		if i <= -32768 || 32768 < i then (
			Output.add_stmt (Output.Mvhi (x, (i lsr 16) mod (1 lsl 16)));
			Output.add_stmt (Output.Mvlo (x, (i mod (1 lsl 16))))
		)
		else
			(* 16ビットで収まるならaddi命令にする *)
			Output.add_stmt (Output.Addi (x, reg_0, i))

	| NonTail(x), SetL(Id.L(y)) ->
		Output.add_stmt (Output.SetL (x, y))

	| NonTail(x), Float f ->
		(* 浮動小数点fをIEEE756のビット列に変換 *)
		(* OCamlのfloat(64bit) -> Cのdouble(64bit) -> 32bitのバイナリ列 という順序で変換 *)
		(* IEEE756の仕様を満たす範囲内で、C言語と微妙に仕様が違うようなので結構アドホック *)
		let hi = Int32.to_int (gethi f) in
		let lo = Int32.to_int (getlo f) in
		let s = lo lsr 31 in
		let exp = (lo lsr 20) mod (1 lsl 12) in
		let frac = lo mod (1 lsl 20) in
		let b =
			if exp = 0 && frac = 0 then
				s lsl 31
			else (
				let exp = exp - (if s > 0 && frac <> 0 then 895 else 896) in (* 負の数だと1ずれる？ *)
				let frac = (frac lsl 3) + (hi lsr 29) in
				(s lsl 31) + (exp lsl 23) + frac
			) in
		Output.add_stmt (Output.Comment (Printf.sprintf "\t! %f" f));
		if -32768 < b && b <= 32768 then (
		  	Output.add_stmt (Output.Addi (reg_sw, reg_0, b));
		  	let ss = get_stacksize () in
		  	Output.add_stmt (Output.Sti (reg_sw, reg_sp, ss));
		  	Output.add_stmt (Output.LdFi (x, reg_sp, ss));
		)
		else (
		  	Output.add_stmt (Output.Mvhi (reg_sw, (b lsr 16) mod (1 lsl 16)));
		  	Output.add_stmt (Output.Mvlo (reg_sw, (b mod (1 lsl 16))));
		  	let ss = get_stacksize () in
		  	Output.add_stmt (Output.Sti (reg_sw, reg_sp, ss));
		  	Output.add_stmt (Output.LdFi (x, reg_sp, ss));
		)

	| NonTail(x), Mov(y) when x = y -> ()

	| NonTail(x), Mov(y) ->
		Output.add_stmt (Output.Mov (x, y))

	| NonTail(x), Neg(y) -> 
		Output.add_stmt (Output.Sub (x, reg_0, y))

	| NonTail(x), Add(y, V(z)) ->
		Output.add_stmt (Output.Add (x, y, z))

	| NonTail(x), Add(y, C(z)) ->
		Output.add_stmt (Output.Addi (x, y, z))

	| NonTail(x), Sub(y, V(z)) ->	
		Output.add_stmt (Output.Sub (x, y, z))

	| NonTail(x), Sub(y, C(z)) ->
		Output.add_stmt (Output.Subi (x, y, z))

	| NonTail(x), Mul(y, V(z)) ->
		Output.add_stmt (Output.Mul (x, y, z))

	| NonTail(x), Mul(y, C(z)) ->
		Output.add_stmt (Output.Muli (x, y, z))

	| NonTail(x), Div(y, V(z)) ->
		failwith "This architecture does not support div."

	| NonTail(x), Div(y, C(z)) ->
		failwith "This architecture does not support divi."

	| NonTail(x), SLL(y, V(z)) ->
		Output.add_stmt (Output.SLL (x, y, z))

	| NonTail(x), SLL(y, C(z)) when z >= 0 ->
		Output.add_stmt (Output.SLLi (x, y, z))

	| NonTail(x), SLL(y, C(z)) ->
		Output.add_stmt (Output.SRLi (x, y, -z))

	| NonTail(x), Ld(y, V z) ->
		Output.add_stmt (Output.Ld (x, y, z))

	| NonTail(x), Ld(y, C z) ->
		Output.add_stmt (Output.Ldi (x, y, z))

	| NonTail(_), St(x, y, V z) ->
		Output.add_stmt (Output.St (x, y, z))

	| NonTail(_), St(x, y, C z) ->
		Output.add_stmt (Output.Sti (x, y, z))

	(**************************************************************************
	 * 浮動小数演算
	 **************************************************************************)

	| NonTail(x), FMov(y) when x = y -> ()

	| NonTail(x), FMov(y) ->
		Output.add_stmt (Output.FMov (x, y))

	| NonTail(x), FNeg(y) ->
		Output.add_stmt (Output.FNeg (x, y))

	| NonTail(x), FAdd(y, z) ->
		Output.add_stmt (Output.FAdd (x, y, z))

	| NonTail(x), FSub(y, z) ->
		Output.add_stmt (Output.FSub (x, y, z))

	| NonTail(x), FMul(y, z) ->
		Output.add_stmt (Output.FMul (x, y, z))

	| NonTail(x), FDiv(y, z) ->
		Output.add_stmt (Output.FDiv (x, y, z))

	| NonTail(x), LdF(y, V(z)) ->
		Output.add_stmt (Output.LdF (x, y, z))

	| NonTail(x), LdF(y, C(z)) ->
		Output.add_stmt (Output.LdFi (x, y, z))

	| NonTail(_), StF(x, y, V(z)) ->
		Output.add_stmt (Output.StF (x, y, z))

	| NonTail(_), StF(x, y, C(z)) ->
		Output.add_stmt (Output.StFi (x, y, z))

	| NonTail(_), Comment(s) ->
		Output.add_stmt (Output.Comment (Printf.sprintf "\t! %s\n" s))

	(* 退避の仮想命令 *)
	| NonTail(_), Save(x, y) when List.mem x (reg_sw :: allregs) && not (M.mem y !stackmap) ->
		save y;
		let offset = get_offset y in
		Output.add_stmt (Output.Sti (x, reg_sp, offset))

	| NonTail(_), Save(x, y) when List.mem x (reg_fsw :: allfregs) && not (M.mem y !stackmap) ->
		save y;
		let offset = get_offset y in
		Output.add_stmt (Output.StFi (x, reg_sp, offset))

	| NonTail(_), Save(x, y) ->
		(* reg_fgsに含まれるレジスタなので退避しない *)
		if not (M.mem y !stackmap || Asm.is_reg x) then (
			(* xがレジスタでyが退避済みってことありえない *)
			failwith (Printf.sprintf "[Emit.g'](%s, %s) has already saved." x y)
		)

	(* 復帰の仮想命令 *)
	| NonTail(x), Restore(y) when List.mem x allregs ->
		Output.add_stmt (Output.Ldi (x, reg_sp, (get_offset y)))

	| NonTail(x), Restore(y) when List.mem x allfregs ->
		Output.add_stmt (Output.LdFi (x, reg_sp, (get_offset y)))

	| NonTail(x), Restore(y) ->
		(* reg_fgsに含まれるレジスタなので復帰しない *)
		assert (Asm.is_reg x); ()

	(**************************************************************************
	 * 末尾だったら計算結果を第一レジスタにセットして返る
	 **************************************************************************)

	| Tail, (Nop | St _ | StF _ | Comment _ | Save _ as exp) ->
		g' oc (NonTail(Id.gentmp Type.Unit), exp);
		Output.add_stmt Output.Return

	| Tail, (Set _ | SetL _| Mov _ | Neg _ | Add _ | Sub _ | SLL _ | Ld _ as exp) ->
		g' oc (NonTail(regs.(0)), exp);
		Output.add_stmt Output.Return

	| Tail, (FMov _ | FNeg _ | Float _ | FAdd _ | FSub _ | FMul _ | FDiv _ | LdF _  as exp) ->
		g' oc (NonTail(fregs.(0)), exp);
		Output.add_stmt Output.Return

	| Tail, (Restore(x) as exp) ->
		g' oc (NonTail(regs.(0)), exp);
		Output.add_stmt Output.Return

	(* ラスト２つの引数は順に「ラベル名の接頭辞」「命令名」*)
	| Tail, IfEq(x, V(y), e1, e2) ->
		g'_tail_if oc x (pp_id_or_imm (V y)) e2 e1 "jne" "jeq"

	| Tail, IfEq(x, C(0), e1, e2) ->
		g'_tail_if oc x reg_0 e2 e1 "jne" "jeq"

	| Tail, IfEq(x, C(1), e1, e2) ->
		g'_tail_if oc x reg_p1 e2 e1 "jne" "jeq"

	| Tail, IfEq(x, C(-1), e1, e2) ->
		g'_tail_if oc x reg_m1 e2 e1 "jne" "jeq"

	| Tail, IfEq(x, C(y), e1, e2) ->
		failwith "can't use immediate in the branch operations.(IfEq)"


	| Tail, IfLE(x, V(y), e1, e2) ->
		g'_tail_if oc (pp_id_or_imm (V y)) x e1 e2 "jle" "jlt"

	| Tail, IfLE(x, C(0), e1, e2) ->
		g'_tail_if oc reg_0 x e1 e2 "jle" "jlt"

	| Tail, IfLE(x, C(1), e1, e2) ->
		g'_tail_if oc reg_p1 x e1 e2 "jle" "jlt"

	| Tail, IfLE(x, C(-1), e1, e2) ->
		g'_tail_if oc reg_m1 x e1 e2 "jle" "jlt"

	| Tail, IfLE(x, C(y), e1, e2) ->
		failwith "can't use immediate in the branch operations.(IfLE)"


	| Tail, IfGE(x, V(y), e1, e2) ->
		g'_tail_if oc x (pp_id_or_imm (V y)) e1 e2 "jge" "jlt"

	| Tail, IfGE(x, C(0), e1, e2) ->
		g'_tail_if oc x reg_0 e1 e2 "jge" "jlt"

	| Tail, IfGE(x, C(1), e1, e2) ->
		g'_tail_if oc x reg_p1 e1 e2 "jge" "jlt"

	| Tail, IfGE(x, C(-1), e1, e2) ->
		g'_tail_if oc x reg_m1 e1 e2 "jge" "jlt"

	| Tail, IfGE(x, C(y), e1, e2) ->
		failwith "can't use immediate in the branch operations.(IfGE)"

	| Tail, IfFEq(x, y, e1, e2) ->
		g'_tail_if oc x y e2 e1 "fjne" "fjeq"
	| Tail, IfFLE(x, y, e1, e2) ->
		g'_tail_if oc y x e1 e2 "fjge" "fjlt"

	| NonTail(z), IfEq(x, V(y), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x (pp_id_or_imm (V y)) e2 e1 "jne" "jeq"

	| NonTail(z), IfEq(x, C(0), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x reg_0 e2 e1 "jne" "jeq"

	| NonTail(z), IfEq(x, C(1), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x reg_p1 e2 e1 "jne" "jeq"

	| NonTail(z), IfEq(x, C(-1), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x reg_m1 e2 e1 "jne" "jeq"

	| NonTail(z), IfEq(x, C(y), e1, e2) ->
		failwith "can't use immediate in the branch operations.(IfEq)"


	| NonTail(z), IfLE(x, V(y), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) (pp_id_or_imm (V y)) x e1 e2 "jle" "jlt"

	| NonTail(z), IfLE(x, C(0), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) reg_0 x e1 e2 "jle" "jlt"

	| NonTail(z), IfLE(x, C(1), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) reg_p1 x e1 e2 "jle" "jlt"

	| NonTail(z), IfLE(x, C(-1), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) reg_m1 x e1 e2 "jle" "jlt"

	| NonTail(z), IfLE(x, C(y), e1, e2) ->
		failwith "can't use immediate in the branch operations.(IfLE)"


	| NonTail(z), IfGE(x, V(y), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x (pp_id_or_imm (V y)) e1 e2 "jge" "jlt"

	| NonTail(z), IfGE(x, C(0), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x reg_0 e1 e2 "jge" "jlt"

	| NonTail(z), IfGE(x, C(1), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x reg_p1 e1 e2 "jge" "jlt"

	| NonTail(z), IfGE(x, C(-1), e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x reg_m1 e1 e2 "jge" "jlt"

	| NonTail(z), IfGE(x, C(y), e1, e2) ->
		failwith "can't use immediate in the branch operations.(IfGE)"


	| NonTail(z), IfFEq(x, y, e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) x y e2 e1 "fjne" "fjeq"
	| NonTail(z), IfFLE(x, y, e1, e2) ->
		g'_non_tail_if oc (NonTail(z)) y x e1 e2 "fjge" "fjlt"


	(* 関数呼び出しの仮想命令の実装 (caml2html: emit_call) *)
	(*jmp : 即値でジャンプ先を指定*)
	(*b : レジスタでジャンプ先を指定*)

	| Tail, CallCls(x, ys, zs) -> (* 末尾呼び出し (caml2html: emit_tailcall) *)
		g'_args oc x [(x, reg_cl)] ys zs;
		Output.add_stmt (Output.Ldi (reg_sw, reg_cl, 0));
		Output.add_stmt (Output.B reg_sw)		(*指定されたレジスタが指す位置へ飛ぶ *)

	| Tail, CallDir(Id.L(x), ys, zs) -> (* 末尾呼び出し *)
		(match x with
	  		| "min_caml_fabs" 
	  		| "min_caml_abs_float" ->
				Output.add_stmt (Output.FAbs (fregs.(0), (assert (List.length zs > 0); List.hd zs)));
				Output.add_stmt Output.Return
	  		| "min_caml_sqrt" ->
				Output.add_stmt (Output.FSqrt (fregs.(0), (assert (List.length zs > 0); List.hd zs)));
				Output.add_stmt Output.Return
		  	| "min_caml_print_newline" ->
				g'_args oc x [] ys zs;
				Output.add_stmt (Output.Addi (regs.(0), reg_0, 10));
				Output.add_stmt (Output.Output regs.(0));
				Output.add_stmt Output.Return
		  	| "min_caml_print_char"
		  	| "min_caml_write" ->
				Output.add_stmt (Output.Output (assert (List.length ys > 0); List.hd ys));
				Output.add_stmt Output.Return
			| "min_caml_input_char"
			| "min_caml_read_char" ->
				Output.add_stmt (Output.Input regs.(0));
				Output.add_stmt Output.Return
		 	| _ ->
				g'_args oc x [] ys zs;
				Output.add_stmt (Output.Jmp x)
		)

  | NonTail(a), CallCls(x, ys, zs) -> (* レジスタで飛ぶジャンプ *)
		g'_args oc x [(x, reg_cl)] ys zs;
		let ss = get_stacksize () in
		Output.add_stmt (Output.Ldi (reg_sw, reg_cl, 0));
		Output.add_stmt (Output.Subi (reg_sp, reg_sp, ss));
		Output.add_stmt (Output.CallR reg_sw);
		Output.add_stmt (Output.Addi (reg_sp, reg_sp, ss)); 
		(if List.mem a allregs && a <> regs.(0) then
			Output.add_stmt (Output.Mov (a, regs.(0)))
		else if List.mem a allfregs && a <> fregs.(0) then
			Output.add_stmt (Output.FMov (a, fregs.(0)))
		else ())

  | NonTail(a), CallDir(Id.L(x), ys, zs) -> (* ラベルで飛ぶジャンプ *)
	  	(match x with
	  		| "min_caml_fabs" 
	  		| "min_caml_abs_float" ->
				Output.add_stmt (Output.FAbs (a, (assert (List.length zs > 0); List.hd zs)))
	  		| "min_caml_sqrt" ->
				Output.add_stmt (Output.FSqrt (a, (assert (List.length zs > 0); List.hd zs)))
		  	| "min_caml_print_newline" ->
				let ss = get_stacksize () in
				Output.add_stmt (Output.Sti (regs.(0), reg_sp, ss));
				Output.add_stmt (Output.Addi (regs.(0), reg_0, 10));
				Output.add_stmt (Output.Output regs.(0));
				Output.add_stmt (Output.Ldi (regs.(0), reg_sp, ss))
		  	| "min_caml_print_char"
		  	| "min_caml_write" ->
			  	Output.add_stmt (Output.Output (assert (List.length ys > 0); List.hd ys))
			| "min_caml_input_char"
			| "min_caml_read_char" ->
			 	Output.add_stmt (Output.Input a)
			| _ ->
				g'_args oc x [] ys zs;
				let ss = get_stacksize () in
				Output.add_stmt (Output.Subi (reg_sp, reg_sp, ss));
				Output.add_stmt (Output.Call x);
				Output.add_stmt (Output.Addi (reg_sp, reg_sp, ss)); 
				if List.mem a allregs && a <> regs.(0) then
					Output.add_stmt (Output.Mov (a, regs.(0)))
				else if List.mem a allfregs && a <> fregs.(0) then
					Output.add_stmt (Output.FMov (a, fregs.(0)))
		)

	| _ -> failwith "unmatched"

(* bはラベルの接頭辞。bnは命令名 *)
and g'_tail_if oc x y e1 e2 b bn =
	let b_else = Id.genid (b ^ "_else") in
	Output.add_stmt (Output.JCmp (bn, x, y, b_else));
	let stackmap_back = !stackmap in
	g oc (Tail, e1);
	Output.add_stmt (Output.Label b_else);
	stackmap := stackmap_back;
	g oc (Tail, e2)
and g'_non_tail_if oc dest x y e1 e2 b bn =
	let b_else = Id.genid (b ^ "_else") in
	let b_cont = Id.genid (b ^ "_cont") in
	Output.add_stmt (Output.JCmp (bn, x, y, b_else));
	let stackmap_back = !stackmap in
	g oc (dest, e1);
	let stackmap1 = !stackmap in
	Output.add_stmt (Output.Jmp b_cont);
	Output.add_stmt (Output.Label b_else);
	stackmap := stackmap_back;
	g oc (dest, e2);
	Output.add_stmt (Output.Label b_cont);
	let stackmap2 = !stackmap in
	stackmap := M.inter stackmap1 stackmap2

and g'_args oc name x_reg_cl ys zs =
	let (regs, fregs) =
		try 
			let data = M.find name !fundata in
			let arg_regs = data.arg_regs in
			let (reg_ls, freg_ls) = List.partition (fun x -> List.mem x Asm.allregs) arg_regs in
			(Array.of_list reg_ls, Array.of_list freg_ls)
		with
		| Not_found -> print_endline ("not found args: " ^ name); (Asm.regs, Asm.fregs) in
	let (i, yrs) =
		List.fold_left (
			fun (i, yrs) y -> (i + 1, (y, regs.(i)) :: yrs)
		) (0, x_reg_cl) ys in
	List.iter (
		fun (y, r) -> Output.add_stmt (Output.Mov (r, y))
	) (shuffle reg_sw yrs);
	let (d, zfrs) = 
		List.fold_left (
			fun (d, zfrs) z -> (d + 1, (z, fregs.(d)) :: zfrs)
		) (0, []) zs in
	List.iter (
		fun (z, fr) ->
			Output.add_stmt (Output.FMov (fr, z))
	) (shuffle reg_fsw zfrs)

let print_list ls = 
	let rec print_list = function
		| [] -> ""
		| x :: [] -> x
		| x :: xs -> x ^ ", " ^ (print_list xs) in
	"[" ^ (print_list ls) ^ "]"

let h oc { name = Id.L(x); args = args; fargs = fargs; body = e; ret = ret } =
	Output.add_stmt (Output.Comment (Printf.sprintf "\n!---------------------------------------------------------------------"));
	Output.add_stmt (Output.Comment (Printf.sprintf "! args = %s" (print_list args)));
	Output.add_stmt (Output.Comment (Printf.sprintf "! fargs = %s" (print_list fargs)));
	(* TODO: 文字数が多くなるとアセンブリで読み込めなくなる *)
(*	Output.add_stmt (Output.Comment (Printf.sprintf "! use_regs = %s" (print_list (S.fold (fun x env -> x :: env) (Asm.get_use_regs x) []))));
*)	Output.add_stmt (Output.Comment (Printf.sprintf "! ret type = %s" (Type.string_of_type ret)));
	Output.add_stmt (Output.Comment (Printf.sprintf "!---------------------------------------------------------------------"));
	Output.add_stmt (Output.Label x);
	(*  Printf.printf "%s\n" x; flush stdout;*)
	stackmap := M.empty;
	g oc (Tail, e)

let f oc (Prog(fundefs, e)) =
	Format.eprintf "generating assembly...@.";

	Output.add_stmt (Output.Comment (Printf.sprintf ".init_heap_size\t0"));
	Output.add_stmt (Output.Jmp "min_caml_start");
	Output.add_stmt (Output.Label "min_caml_start");
	stackmap := M.empty;

	(* reg_hp, reg_p1, reg_m1の初期化 *)
	(* + 4してるのはヒープレジスタの退避用 *)
	let pos = !GlobalEnv.offset + 4 in
	Output.add_stmt (Output.Mvhi (reg_hp, (pos lsr 16) mod (1 lsl 16)));
	Output.add_stmt (Output.Mvlo (reg_hp, pos mod (1 lsl 16)));
	Output.add_stmt (Output.Addi (reg_p1, reg_0, 1));
	Output.add_stmt (Output.Sub (reg_m1, reg_0, reg_p1));
	g oc (NonTail reg_0, e);
	Output.add_stmt Output.Halt;

	List.iter (fun fundef -> h oc fundef) fundefs;

	Output.optimize ();
	Output.output oc

