open KNormal

let find x env = try M.find x env with Not_found -> x

let rec rename env = function
  | Unit -> Unit
  | Int(i) -> Int(i)
  | Float(d) -> Float(d)
  | Neg(x) -> Neg(find x env)
  | Add(x, y) -> Add(find x env, find y env)
  | Sub(x, y) -> Sub(find x env, find y env)
  | Mul(x, y) -> Mul(find x env, find y env)
  | Div(x, y) -> Div(find x env, find y env)
  | SLL(x, i) -> SLL(find x env, i)
  | FNeg(x) -> FNeg(find x env)
  | FAdd(x, y) -> FAdd(find x env, find y env)
  | FSub(x, y) -> FSub(find x env, find y env)
  | FMul(x, y) -> FMul(find x env, find y env)
  | FDiv(x, y) -> FDiv(find x env, find y env)

  | IfEq(V x, V y, e1, e2) -> IfEq(V (find x env), V (find y env), rename env e1, rename env e2)
  | IfEq(V x, C y, e1, e2) -> IfEq(V (find x env), C y, rename env e1, rename env e2)
  | IfEq(C x, V y, e1, e2) -> IfEq(C x, V (find y env), rename env e1, rename env e2)
  | IfEq(C x, C y, e1, e2) -> IfEq(C x, C y, rename env e1, rename env e2)

  | IfLE(V x, V y, e1, e2) -> IfLE(V (find x env), V (find y env), rename env e1, rename env e2)
  | IfLE(V x, C y, e1, e2) -> IfLE(V (find x env), C y, rename env e1, rename env e2)
  | IfLE(C x, V y, e1, e2) -> IfLE(C x, V (find y env), rename env e1, rename env e2)
  | IfLE(C x, C y, e1, e2) -> IfLE(C x, C y, rename env e1, rename env e2)

  | Let((x, t), e1, e2) ->
      Let((x, t), rename env e1, rename env e2)
  | Var(x) -> Var(find x env)
  | LetRec({ name = (x, t); args = yts; body = e1 }, e2) ->
      LetRec({ name = (x, t); args = yts; body = rename env e1 },
             rename env e2)
  | App(x, ys) -> App(find x env, List.map (fun y -> find y env) ys)
  | Tuple(xs) -> Tuple(List.map (fun x -> find x env) xs)
  | LetTuple(xts, y, e) ->
      LetTuple(xts, find y env, rename env e)
  | Get(x, y) -> Get(find x env, find y env)
  | Put(x, y, z) -> Put(find x env, find y env, find z env)
  | ExtArray(x) -> ExtArray(x)
  | ExtFunApp(x, ys) -> ExtFunApp(x, List.map (fun y -> find y env) ys)

let id x i = x ^ "-" ^ string_of_int i

let rec g env = function
  | IfEq(x, y, e1, e2) -> IfEq(x, y, g env e1, g env e2)
  | IfLE(x, y, e1, e2) -> IfLE(x, y, g env e1, g env e2)
  | Let((x, t), e1, e2) ->
      Let((x, t), g env e1, g env e2)
  | LetRec({ name = (x, t); args = yts; body = e1 }, e2) ->
      LetRec({ name = (x, t); args = yts; body = g env e1 },
             g env e2)
  (* タプルの要素のうち、eの中で使われるもののみ残す *)
  | LetTuple(xts, y, e) ->
	let xs = List.map fst xts in
	let free = KNormal.fv e in
	let env', rnenv, _ = List.fold_left 
							(fun (env, rnenv, i) x ->
								if S.mem x free then
									if M.mem (id y i) env then (* id y i が登録済みだったらその値で置換する *)
										(env, M.add x (M.find (id y i) env) rnenv, i + 1)
									else (* 新しくロード *)
										(M.add (id y i) x env, rnenv, i + 1)
								else (env, rnenv, i + 1)
							) (env, M.empty, 0) xs in
	LetTuple(xts, y, g env' (rename rnenv e))
  | e -> e

let f flg e =
 g M.empty e


