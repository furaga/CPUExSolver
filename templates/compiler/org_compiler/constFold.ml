(* �������� 2011/10/16 0:27 *)
open KNormal

let memi x env =
  try (match M.find x env with Int(_) -> true | _ -> false)
  with Not_found -> false
let memf x env =
  try (match M.find x env with Float(_) -> true | _ -> false)
  with Not_found -> false
let memt x env =
  try (match M.find x env with Tuple(_) -> true | _ -> false)
  with Not_found -> false

(* M.find x env����if ������ then 1 else 0 �Τ褦��ñ���ifʸ�ʤ�true *)
let mem_simple_if x env =
  try (
  	match M.find x env with 
  		| IfEq (_, _, Int m, Int n) when (m = 0 || m = 1) && (n = 0 || n = 1) -> true
  		| IfLE (_, _, Int m, Int n) when (m = 0 || m = 1) && (n = 0 || n = 1) -> true
  		| _ -> false)
  with Not_found -> false

let findi x env = (match M.find x env with Int(i) -> i | _ -> raise Not_found)
let findf x env = (match M.find x env with Float(d) -> d | _ -> raise Not_found)
let findt x env = (match M.find x env with Tuple(ys) -> ys | _ -> raise Not_found)

let find_simple_if x env =
	match M.find x env with 
		| IfEq (a, b, Int m, Int n) as e when (m = 0 || m = 1) && (n = 0 || n = 1) -> e
		| IfLE (a, b, Int m, Int n) as e when (m = 0 || m = 1) && (n = 0 || n = 1) -> e
		| _ -> raise Not_found

let rec g env = function (* ������߹��ߥ롼�������� (caml2html: constfold_g) *)
	| Var(x) when memi x env -> Int(findi x env)
(*	| Var(x) when memf x env -> Float(findf x env)
	| Var(x) when memt x env -> Tuple(findt x env)*)
	| Neg(x) when memi x env -> Int(-(findi x env))

	| Add(x, y) when memi x env && memi y env -> Int(findi x env + findi y env) (* ­�����Υ����� (caml2html: constfold_add) *)
	| Add(x, y) when memi x env && M.find x env = Int(0) -> Var (y) (* �����������ä��餽���ä� *)
	| Add(x, y) when memi y env && M.find y env = Int(0) -> Var (x) (* �����������ä��餽���ä� *)

	| Sub(x, y) when memi x env && memi y env -> Int(findi x env - findi y env)
	| Sub(x, y) when memi x env && M.find x env = Int(0) -> Neg (y) (* �����������ä��餽���ä� *)
	| Sub(x, y) when memi y env && M.find y env = Int(0) -> Var (x) (* �����������ä��餽���ä� *)

	| Mul(x, y) when memi x env && memi y env -> Int(findi x env * findi y env)
	| Mul(x, y) when memi x env && M.find x env = Int(0) -> Int (0) (* ������0���ä��� *)
	| Mul(x, y) when memi y env && M.find y env = Int(0) -> Int (0) (* ������0���ä��� *)
	| Mul(x, y) when memi x env && M.find x env = Int(1) -> Var (y) (* ������1���ä��� *)
	| Mul(x, y) when memi y env && M.find y env = Int(1) -> Var (x) (* ������1���ä��� *)
	| Mul(x, y) when memi x env && M.find x env = Int(-1) -> Neg (y) (* ������-1���ä��� *)
	| Mul(x, y) when memi y env && M.find y env = Int(-1) -> Neg (x) (* ������-1���ä��� *)
	| Mul(x, y) when memi x env && M.find x env = Int(2) -> Add (y, y) (* X * 2 = X + X *)
	| Mul(x, y) when memi y env && M.find y env = Int(2) -> Add (x, x) (* X * 2 = X + X *)

	| Div(x, y) when memi x env && memi y env -> Int(findi x env / findi y env)
	| Div(x, y) when memi x env && M.find x env = Int(0) -> Int (0) (* ����1���ä��� *)
	| Div(x, y) when memi y env && M.find y env = Int(1) -> Var (x) (* ����1���ä��� *)
	| Div(x, y) when memi y env && M.find y env = Int(-1) -> Neg (x) (* ����-1���ä��� *)

	| SLL(x, y) when memi x env && memi y env && findi y env >= 0 -> Int(findi x env lsl findi y env)
	| SLL(x, y) when memi x env && memi y env -> Int(findi x env asr (-(findi y env)))
	| SLL(x, y) when memi x env && M.find x env = Int(0) -> Int (0) (* ���������ä��� *)
	| SLL(x, y) when memi y env && M.find y env = Int(0) -> Var (x) (* ���������ä��� *)

	| FNeg(x) when memf x env -> Float(-.(findf x env))

	| FAdd(x, y) when memf x env && memf y env -> Float(findf x env +. findf y env)
	| FAdd(x, y) when memf x env && M.find x env = Float (0.) -> Var(y)
	| FAdd(x, y) when memf y env && M.find y env = Float (0.) -> Var(x)
	
	| FSub(x, y) when memf x env && memf y env -> Float(findf x env -. findf y env)
	| FSub(x, y) when memf x env && M.find x env = Float (0.) -> FNeg(y)
	| FSub(x, y) when memf y env && M.find y env = Float (0.) -> Var(x)

	| FMul(x, y) when memf x env && memf y env -> Float(findf x env *. findf y env)
	| FMul(x, y) when memf x env && M.find x env = Float (0.) -> Float (0.)
	| FMul(x, y) when memf y env && M.find y env = Float (0.) -> Float (0.)
	| FMul(x, y) when memf x env && M.find x env = Float (1.) -> Var (y)
	| FMul(x, y) when memf y env && M.find y env = Float (1.) -> Var (x)
	| FMul(x, y) when memf x env && M.find x env = Float (-1.) -> FNeg (y)
	| FMul(x, y) when memf y env && M.find y env = Float (-1.) -> FNeg (x)
	
	| FDiv(x, y) when memf x env && memf y env -> Float(findf x env /. findf y env)
	| FDiv(x, y) when memf x env && M.find x env = Float (0.) -> Float (0.)
	| FDiv(x, y) when memf y env && M.find y env = Float (1.) -> Var (x)
	| FDiv(x, y) when memf y env && M.find y env = Float (-1.) -> FNeg (x)

	(* IfEq *)
	| IfEq(V x, V y, e1, e2) when memf x env && memf y env -> if findf x env = findf y env then g env e1 else g env e2
	| IfEq(V x, V y, e1, e2) when memi x env && memi y env -> if findi x env = findi y env then g env e1 else g env e2
	| IfEq(V x, C y, e1, e2) when memi x env -> if findi x env = y then g env e1 else g env e2
	| IfEq(C x, V y, e1, e2) when memi y env -> if x = findi y env then g env e1 else g env e2

	(*
			let x = if a <= b then 0 else 1 in
			������
			if x = 1 then e1 else e2

		�Τ褦�ʼ���
		
			if a <= b then e2 else e1

		���ѷ�	
	*)
	| IfEq(V x, C y, e1, e2) (*when (y = 1 || y = 0) && mem_simple_if x env*)
	| IfEq(C y, V x, e1, e2) when (y = 1 || y = 0) && mem_simple_if x env ->
		(match find_simple_if x env with
			| IfEq (a, b, Int m, Int n) ->
				if y = 1 && m = 1 && n = 1 then g env e1
				else if y = 0 && m = 1 && n = 1 then g env e2
				else if y = 1 && m = 0 && n = 0 then g env e2
				else if y = 0 && m = 0 && n = 0 then g env e1
				else if y = 1 && m = 1 && n = 0 then IfEq (a, b, g env e1, g env e2)
				else if y = 0 && m = 1 && n = 0 then IfEq (a, b, g env e2, g env e1)
				else if y = 1 && m = 0 && n = 1 then IfEq (a, b, g env e2, g env e1)
				else if y = 0 && m = 0 && n = 1 then IfEq (a, b, g env e1, g env e2)
				else assert false
			| IfLE (a, b, Int m, Int n) ->
				if y = 1 && m = 1 && n = 1 then g env e1
				else if y = 0 && m = 1 && n = 1 then g env e2
				else if y = 1 && m = 0 && n = 0 then g env e2
				else if y = 0 && m = 0 && n = 0 then g env e1
				else if y = 1 && m = 1 && n = 0 then IfLE (a, b, g env e1, g env e2)
				else if y = 0 && m = 1 && n = 0 then IfLE (a, b, g env e2, g env e1)
				else if y = 1 && m = 0 && n = 1 then IfLE (a, b, g env e2, g env e1)
				else if y = 0 && m = 0 && n = 1 then IfLE (a, b, g env e1, g env e2)
				else assert false
			| _ -> assert false
		)
	(* if x = y then a else e2 �� if x = y then (if ���� then 1 else 0) else e2�ߤ����ˤ����� *)
	| IfEq(x, y, Var a, e2) when mem_simple_if a env -> IfEq (x, y, find_simple_if a env, g env e2)
	| IfEq(x, y, e1, Var a) when mem_simple_if a env -> IfEq (x, y, g env e1, find_simple_if a env)
	| IfEq(x, y, e1, e2) -> IfEq(x, y, g env e1, g env e2)

	(* IfLE *)
	| IfLE(V x, V y, e1, e2) when memf x env && memf y env -> if findf x env <= findf y env then g env e1 else g env e2
	| IfLE(V x, V y, e1, e2) when memi x env && memi y env -> if findi x env <= findi y env then g env e1 else g env e2
	| IfLE(V x, C y, e1, e2) when memi x env -> if findi x env <= y then g env e1 else g env e2
	| IfLE(C x, V y, e1, e2) when memi y env -> if x <= findi y env then g env e1 else g env e2
	(* if x <= y then a else e2 �� if x <= y then (if ���� then 1 else 0) else e2�ߤ����ˤ����� *)
	| IfLE(x, y, Var a, e2) when mem_simple_if a env -> IfLE (x, y, find_simple_if a env, g env e2)
	| IfLE(x, y, e1, Var a) when mem_simple_if a env -> IfLE (x, y, g env e1, find_simple_if a env)
	| IfLE(x, y, e1, e2) -> IfLE(x, y, g env e1, g env e2)

	| Let((x, t), e1, e2) -> (* let�Υ����� (caml2html: constfold_let) *)
		let e1' = g env e1 in
		let e2' = g (M.add x e1' env) e2 in
		Let((x, t), e1', e2')
	| LetRec({ name = x; args = ys; body = e1 }, e2) ->
		LetRec({ name = x; args = ys; body = g env e1 }, g env e2)
	| LetTuple(xts, y, e) when memt y env ->
		List.fold_left2
			(fun e' xt z -> Let(xt, Var(z), e'))
			(g env e)
			xts
			(findt y env)
	| LetTuple(xts, y, e) -> LetTuple(xts, y, g env e)

	(*
	| App ("sqrt", [x]) when memf x env -> Float (sqrt (findf x env))
	| App ("sin", [x]) when memf x env -> Float (sin (findf x env))
	| App ("cos", [x]) when memf x env -> Float (cos (findf x env))
	| App ("tan", [x]) when memf x env -> Float (tan (findf x env))
	| App ("atan", [x]) when memf x env -> Float (atan (findf x env))
	*)
	| e -> e

let f = g M.empty
