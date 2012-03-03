(* translation into SPARC assembly with infinite number of virtual registers *)

open Asm

let data = ref [] (* 浮動小数点数の定数テーブル (caml2html: virtual_data) *)

let global_cnt = ref 0

let global_offset = ref M.empty

let set_global_offset x =
	global_offset := M.add x !global_cnt !global_offset;
	global_cnt := 4 + !global_cnt;
	!global_cnt - 4
	
let get_global_offset x = try M.find x !global_offset with Not_found -> Printf.eprintf "Not found in Virtual.get_global_offset : %s\n" x; assert false

let is_global x = int_of_char 'a' <= int_of_char x.[0] && int_of_char x.[0] <= int_of_char 'z' && M.mem x !GlobalEnv.env

let classify xts ini addf addi =
  List.fold_left
    (fun acc (x, t) ->
      match t with
      | Type.Unit -> acc
      | Type.Float -> addf acc x
      | _ -> addi acc x t)
    ini
    xts

let separate xts =
  classify
    xts
    ([], [])
    (fun (int, float) x -> (int, float @ [x]))
    (fun (int, float) x _ -> (int @ [x], float))

let expand xts ini addf addi =
  classify
    xts
    ini
    (fun (offset, acc) x ->
      let offset = align offset in
      (offset + 4, addf x offset acc))
    (fun (offset, acc) x t ->
      (offset + 4, addi x t offset acc))

let rec g env = function (* 式の仮想マシンコード生成 (caml2html: virtual_g) *)
  | Closure.Unit -> Ans(Nop)
  | Closure.Int(i) -> Ans(Set(i))
  | Closure.Float(d) ->
      let l =
	try
	  (* すでに定数テーブルにあったら再利用 *)
	  let (l, _) = List.find (fun (_, d') -> d = d') !data in
	  l
	with Not_found ->
	  let l = Id.L(Id.genid "l") in
	  data := (l, d) :: !data;
	  l in
      let x = Id.genid "l" in
      Let((x, Type.Int), SetL(l), Ans(LdDF(x, C(0))))
  | Closure.Neg(x) -> Ans(Neg(x))
  | Closure.Add(x, y) -> Ans(Add(x, V(y)))
  | Closure.Sub(x, y) -> Ans(Sub(x, V(y)))
  | Closure.Mul(x, y) -> Ans(Mul(x, V(y)))
  | Closure.Div(x, y) -> Ans(Div(x, V(y)))
  | Closure.SLL(x, y) -> Ans(SLL(x, V(y)))
  | Closure.FNeg(x) -> Ans(FNegD(x))
  | Closure.FAdd(x, y) -> Ans(FAddD(x, y))
  | Closure.FSub(x, y) -> Ans(FSubD(x, y))
  | Closure.FMul(x, y) -> Ans(FMulD(x, y))
  | Closure.FDiv(x, y) -> Ans(FDivD(x, y))

  | Closure.IfEq(Closure.V x, Closure.V y, e1, e2) ->
      (match M.find x env with
      | Type.Bool | Type.Int -> Ans(IfEq(x, V y, g env e1, g env e2))
      | Type.Float -> Ans(IfFEq(x, y, g env e1, g env e2))
      | _ -> failwith "equality supported only for bool, int, and float")
  | Closure.IfEq(Closure.V x, Closure.C y, e1, e2) ->
      (match M.find x env with
      | Type.Bool | Type.Int -> Ans(IfEq(x, C y, g env e1, g env e2))
      | _ -> failwith "equality supported only for bool and int")
  | Closure.IfEq(Closure.C x, Closure.V y, e1, e2) ->
      (match M.find y env with
      | Type.Bool | Type.Int -> Ans(IfEq(y, C x, g env e1, g env e2))
      | _ -> failwith "equality supported only for bool and int")
  | Closure.IfEq(Closure.C x, Closure.C y, e1, e2) -> (print_endline "ifeq (C x, C y)はありえません"; assert false)

  | Closure.IfLE(Closure.V x, Closure.V y, e1, e2) ->
      (match M.find x env with
      | Type.Bool | Type.Int -> Ans(IfLE(x, V y, g env e1, g env e2))
      | Type.Float -> Ans(IfFLE(x, y, g env e1, g env e2))
      | _ -> failwith "equality supported only for bool, int, and float")
  | Closure.IfLE(Closure.V x, Closure.C y, e1, e2) ->
      (match M.find x env with
      | Type.Bool | Type.Int -> Ans(IfLE(x, C y, g env e1, g env e2))
      | _ -> failwith "equality supported only for bool and int")
  | Closure.IfLE(Closure.C x, Closure.V y, e1, e2) ->
      (match M.find y env with
      | Type.Bool | Type.Int -> Ans(IfGE(y, C x, g env e1, g env e2))
      | _ -> failwith "equality supported only for bool and int")
  | Closure.IfLE(Closure.C x, Closure.C y, e1, e2) -> (print_endline "ifeq (C x, C y)はありえません"; assert false)
  (** グローバル領域に直にデータを書き込む場合、ヒープポインタを一時的に変更する **)
  | Closure.Let((x, t1), e1, e2) when M.mem x !GlobalEnv.direct_env ->
      let e1' = g env e1 in
      let e2' = g (M.add x t1 env) e2 in
		concat (
			concat (
				concat (
					concat (
						(* 	let %g2 = st %g2 %g31 !GlobalEnv.offset + 4 in *)
						(Ans (St (reg_hp, reg_bottom, C (4 + !GlobalEnv.offset))))
					)
			      	(Id.gentmp Type.Unit, Type.Unit)
					(*	let %g2 = %g31 - !GlobalEnv.offsets[x] in *)
					(Ans (Sub (reg_bottom, C (M.find x !GlobalEnv.offsets))))
				)
				(reg_hp, Type.Int)
				(* 	let x = e1' in *)
				e1'
			)
			(x, Type.Int)
			(* 	let %g2 = %g31 - !GlobalEnv.offset + 4  in *)
			(Ans (Ld (reg_bottom, C (4 + !GlobalEnv.offset))))
		)
		(reg_hp, Type.Int)
		(* e2' *)
		e2'
  | Closure.Let((x, t1), e1, e2) when t1 <> Type.Unit && is_global x ->
(*  	  Printf.printf "CLOSURE_LET: %s\n" x;*)
      let e1' = g env e1 in
      let e2' = g (M.add x t1 env) e2 in
      let st =
      	match t1 with
      		| Type.Unit -> assert false
      		| Type.Float -> Ans (StDF (x, reg_bottom, C (M.find x !GlobalEnv.offsets)))
      		| _ -> Ans (St (x, reg_bottom, C (M.find x !GlobalEnv.offsets))) in
      concat
      	(concat e1' (x, t1) st)
      	(Id.gentmp Type.Unit, Type.Unit)
      	e2'
  | Closure.Let((x, t1), e1, e2) ->
      let e1' = g env e1 in
      let e2' = g (M.add x t1 env) e2 in
      concat e1' (x, t1) e2'
  (** 直にデータが入っているとき **)
  | Closure.Var(x)  when M.mem x !GlobalEnv.direct_env ->
  	  Ans (Sub (reg_bottom, C (M.find x !GlobalEnv.offsets)))
  | Closure.Var(x) ->
      (match M.find x env with
      | Type.Unit -> Ans(Nop)
      | Type.Float -> Ans(FMovD(x))
      | _ -> Ans(Mov(x)))
  | Closure.MakeCls((x, t), { Closure.entry = l; Closure.actual_fv = ys }, e2) -> (* クロージャの生成 (caml2html: virtual_makecls) *)
      (* Closureのアドレスをセットしてから、自由変数の値をストア *)
      let e2' = g (M.add x t env) e2 in
      let offset, store_fv =
		expand
		  (List.map (fun y -> (y, M.find y env)) ys)
		  (4, e2')
		  (fun y offset store_fv -> seq(StDF(y, x, C(-offset)), store_fv))
		  (fun y _ offset store_fv -> seq(St(y, x, C(-offset)), store_fv)) in
      Let((x, t), Mov(reg_hp),
		  Let((reg_hp, Type.Int), Add(reg_hp, C(align offset)),
			  let z = Id.genid "l" in
			  Let((z, Type.Int), SetL(l),
			  seq(St(z, x, C(0)),
				  store_fv))))
  (**TODO 引数にグローバル変数で直にデータが入っているものがあるとき **)
  | Closure.AppCls(x, ys) ->
      let (int, float) = separate (List.map (fun y -> (y, M.find y env)) ys) in
      Ans(CallCls(x, int, float))
  (**TODO 引数にグローバル変数で直にデータが入っているものがあるとき **)
  | Closure.AppDir(Id.L(x), ys) ->
      let (int, float) = separate (List.map (fun y -> (y, M.find y env)) ys) in
      let new_int = List.map (fun x -> if M.mem x !GlobalEnv.direct_env then Id.gentmp Type.Int else x) int in
      let new_float = List.map (fun x -> if M.mem x !GlobalEnv.direct_env then Id.gentmp Type.Float else x) float in
      let ans = 
		  List.fold_left (
		  	fun env (old, nw) ->
		  		if old = nw then env
		  		else
		  			Let (
		  				(nw, Type.Int),
		  				Sub (reg_bottom, C (M.find old !GlobalEnv.offsets)),
		  				env
		  			)
		  ) (Ans(CallDir(Id.L(x), new_int, new_float))) (List.combine int new_int) in
	  List.fold_left (
	  	fun env (old, nw) ->
	  		if old = nw then env
	  		else
	  			Let (
	  				(nw, Type.Float),
	  				Sub (reg_bottom, C (M.find old !GlobalEnv.offsets)),
	  				env
	  			)
	  ) ans (List.combine float new_float)
  | Closure.Tuple(xs) -> (* 組の生成 (caml2html: virtual_tuple) *)
      let y = Id.genid "t" in
      let (offset, store) =
		expand
		  (List.map (fun x -> (x, M.find x env)) xs)
		  (0, Ans(Mov(y)))
		  (fun x offset store -> seq(StDF(x, y, C(-offset)), store))
		  (fun x _ offset store -> seq(St(x, y, C(-offset)), store)) in
      Let((y, Type.Tuple(List.map (fun x -> M.find x env) xs)), Mov(reg_hp),
		  Let((reg_hp, Type.Int), Add(reg_hp, C(align offset)),
			  store))
  (** yがグローバル変数で直にデータが入っているもの **)
	| Closure.LetTuple(xts, y, e2) when M.mem y !GlobalEnv.direct_env ->
		let s = Closure.fv e2 in
		let (offset, load) =
		expand
			xts
			(0, g (M.add_list xts env) e2)
			(fun x offset load ->
				if not (S.mem x s) then load else
				fletd(x, LdDF(reg_bottom, C(-offset + M.find y !GlobalEnv.offsets)), load))
			(fun x t offset load ->
				if not (S.mem x s) then load else
				Let((x, t), Ld(reg_bottom, C(-offset + M.find y !GlobalEnv.offsets)), load)) in
		load
  | Closure.LetTuple(xts, y, e2) ->
      let s = Closure.fv e2 in
      let (offset, load) =
	expand
	  xts
	  (0, g (M.add_list xts env) e2)
	  (fun x offset load ->
	    if not (S.mem x s) then load else (* [XX] a little ad hoc optimization TODO*)
	    ((*Printf.printf "LetTupleF offset = %d (GLOBAL: %s)\n" (-offset) (string_of_bool (is_global x));*)
	    fletd(x, LdDF(y, C(-offset)), load)))
	  (fun x t offset load ->
	    if not (S.mem x s) then load else (* [XX] a little ad hoc optimization TODO*)
	    ((*Printf.printf "LetTupleI offset = %d (GLOBAL: %s)\n" (-offset) (string_of_bool (is_global x));*)
	    Let((x, t), Ld(y, C(-offset)), load))) in
      load
  (**simmでやる**)
  | Closure.Get(x, y) -> (* 配列の読み出し (caml2html: virtual_get) *)
      let offset = Id.genid "o" in
      let zero = Id.genid "o" in
      (match M.find x env with
      | Type.Array(Type.Unit) -> Ans(Nop)
      | Type.Array(Type.Float) ->
	  Let((offset, Type.Int), SLL(y, C(2)),
	      Ans(LdDF(x, V(offset)))) (* TODO *)
      | Type.Array(_) ->
	  Let((offset, Type.Int), SLL(y, C(2)),
	      Ans(Ld(x, V(offset)))) (* TODO *)
      | _ -> assert false)
  (**simmでやる**)
  | Closure.Put(x, y, z) ->
      let offset = Id.genid "o" in
      (match M.find x env with
      | Type.Array(Type.Unit) -> Ans(Nop)
      | Type.Array(Type.Float) ->
	  Let((offset, Type.Int), SLL(y, C(2)),
	      Ans(StDF(z, x, V(offset))))
      | Type.Array(_) ->
	  Let((offset, Type.Int), SLL(y, C(2)),
	      Ans(St(z, x, V(offset))))
      | _ -> assert false)
  | Closure.ExtArray(Id.L(x)) -> Ans(SetL(Id.L("min_caml_" ^ x)))

(* 関数の仮想マシンコード生成 (caml2html: virtual_h) *)
let h { Closure.name = (Id.L x, t); Closure.args = yts; Closure.formal_fv = zts; Closure.body = e } =
(*	print_endline x;*)

	let (int, float) = separate yts in
	let (offset, load) = expand
							zts
							(4, g (M.add x t (M.add_list yts (M.add_list zts (*M.empty*)!GlobalEnv.env))) e)
							(fun z offset load -> fletd(z, LdDF(reg_cl, C(-offset)), load))
							(fun z t offset load -> Let((z, t), Ld(reg_cl, C(-offset)), load)) in
	let (offset, load) = expand
							(List.fold_left (fun ls x -> if is_global x && not (M.mem x !GlobalEnv.direct_env) then (x, M.find x !GlobalEnv.env) :: ls else ls) [] (fv load))
							(0, load)
							(fun z offset load -> fletd(z, LdDF(reg_bottom, C(M.find z !GlobalEnv.offsets)), load))
							(fun z t offset load -> Let((z, t), Ld(reg_bottom, C(M.find z !GlobalEnv.offsets)), load)) in
	(* xの引数ytsに適当にレジスタを割り振っていく *)
	let (_, _, _, rs, frs) = List.fold_left
							(fun (iregs, fregs, xs, rs, frs) (x, t) -> match t with
								| Type.Unit -> (iregs, fregs, xs, rs, frs)
								| Type.Float -> (iregs, List.tl fregs, xs @ [x], rs, frs @ [List.hd fregs])
								| _ -> (List.tl iregs, fregs, xs @ [x], rs @ [List.hd iregs], frs)
							) (allregs, allfregs, [], [], []) yts in
	match t with
		| Type.Fun(_, t2) ->
			let ret_reg = 
				(match t2 with
					| Type.Unit -> "%dummy"
					| Type.Float -> List.hd allfregs
					| _ -> List.hd allregs) in
			fundata := M.add x {arg_regs = rs @ frs; ret_reg = ret_reg; use_regs = S.of_list (allregs @ allfregs)} !fundata;
			{name = Id.L x; args = int; fargs = float; body = load; ret = t2}
		| _ -> assert false

(* プログラム全体の仮想マシンコード生成 (caml2html: virtual_f) *)
let f flg (Closure.Prog(fundefs, e)) =
(*	List.map (
		fun fundef -> Printf.printf "<%s> nesting_tuple = %s\n" (Id.get_name (fst fundef.Closure.name)) (string_of_bool (TupleExpand.exist_nesting_tuple fundef.Closure.body))
	) fundefs;
*)
	data := [];
	(* fundataの初期化時点で登録されいない外部関数 *)	
	M.iter (fun x t ->
				match t with
					| Type.Fun(ts, y) when not (M.mem ("min_caml_" ^ x) !fundata) ->
						let args = List.map (fun t -> ("", t)) ts in
						let _ = h { Closure.name = (Id.L ("min_caml_" ^ x), t); Closure.args = args; Closure.formal_fv = []; Closure.body = Closure.Unit } in
						()
					| _ -> ()
				) !Typing.extenv;
	let e = g (*M.empty*)!GlobalEnv.env e in
	let fundefs = List.map h fundefs in
	let program = Prog(!data, fundefs, e) in
	program

