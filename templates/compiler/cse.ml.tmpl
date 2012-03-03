(* 共通部分式除去（Common subexpression elimination, CSE）*)
open KNormal

let no_effect_fun = ref S.empty
(* 副作用がないと分かっている関数群 *)
let noeffectfun = S.of_list [
	"fequal"; "fless"; "fispos"; "fisneg"; "fiszero"; 
	"xor"; "not"; 
	"fabs"; "fneg"; 
	"fsqr"; "fhalf"; "floor";
	"float_of_int"; "int_of_float";
	"sin"; "cos"; "atan"; "sqrt"]

(* 副作用があるか *)
let rec effect env = function
	| Let (_, e1, e2) | IfEq (_, _, e1, e2) | IfLE (_, _, e1, e2) -> effect env e1 || effect env e2
	| LetRec ({name = (x,_); body = e1}, e2) -> if effect_fun x env e1 then effect env e2 else effect (S.add x env) e2
	| LetTuple (_, _, e) -> effect env e
	| App (x, _) -> not (S.mem x env)
	| ExtFunApp (x, _) -> not (S.mem x noeffectfun)
	| Put _  -> true
	| _ -> false
(* 関数idが副作用がないと仮定した上でeffect関数を呼ぶ *)
and effect_fun id env exp =
	if effect (S.add id env) exp then
		effect env exp
	else false

module CM =(* CSE用のMap KNormal.tをkeyとする *)
	Map.Make
	(struct
		type t = KNormal.t
		let compare = compare
	end)
include CM

(* 式と番号の対応関係 *)
let tagenv = ref (CM.empty,CM.empty,CM.empty) (* Get, ExtArray, その他 *)

let addtag key tag =
	let (getenv, extenv, etcenv) = !tagenv in
	match key with
		| Get _ -> tagenv := (CM.add key tag getenv, extenv, etcenv)
		| ExtArray _ -> tagenv := (getenv, CM.add key tag extenv, etcenv)
		| _ -> tagenv := (getenv, extenv, CM.add key tag etcenv)

let findtag key =
	let (getenv, extenv, etcenv) = !tagenv in
	match key with
		| Get _ -> CM.find key getenv
		| ExtArray _ -> CM.find key extenv
		| _ -> CM.find key etcenv

let tag = ref 0

let newtag () =
	tag := !tag + 1;
	string_of_int !tag

(* 式に対して番号を返す *)
let rec number e = 
	let find key =
		try
			findtag key
		with
			Not_found ->
				let tag = newtag() in
				addtag key tag; tag in
	let v x = (* 変数の番号 *)
		find (Var(x)) in
	match e with
		| Unit | Int(_) | Float(_) -> find e
		| Neg(x) -> find (Neg(v x))
		| Add(x, y) ->
			let x = v x in
			let y = v y in
			if x < y then find (Add(x, y))
			else find (Add(y, x))
		| Sub(x, y) -> find (Sub(v x, v y))
		| FMul(x, y) ->
			let x = v x in
			let y = v y in
			if x < y then find (Mul(x, y))
			else find (Mul(y, x))
		| Div(x, y) -> find (Sub(v x, v y))
		| SLL(x, i) -> find (SLL(v x, i))
		| FNeg(x) -> find (FNeg(v x))
		| FAdd(x, y) ->
			let x = v x in
			let y = v y in
			if x < y then find (FAdd(x, y))
			else find (FAdd(y, x))
		| FSub(x, y) -> find (FSub(v x, v y))
		| FMul(x, y) ->
			let x = v x in
			let y = v y in
			if x < y then find (FMul(x, y))
			else find (FMul(y, x))
		| FDiv(x, y) -> find (FDiv(v x, v y))
	
		| IfEq(V x, V y, e1, e2) ->
			let x = v x in
			let y = v y in
			if x < y then
				find (IfEq(V x, V y, Var(number e1), Var(number e2)))
			else
				find (IfEq(V y, V x, Var(number e1), Var(number e2)))

		| IfEq(V x, C y, e1, e2) ->
			let x = v x in
			find (IfEq(V x, C y, Var(number e1), Var(number e2)))

		| IfEq(C x, V y, e1, e2) ->
			let y = v y in
			find (IfEq(C x, V y, Var(number e1), Var(number e2)))

		| IfEq(C x, C y, e1, e2) ->
			find (IfEq(C x, C y, Var(number e1), Var(number e2)))

		| IfLE(V x, V y, e1, e2) -> find (IfLE(V (v x), V (v y), Var(number e1), Var(number e2)))
		| IfLE(V x, C y, e1, e2) -> find (IfLE(V (v x), C y, Var(number e1), Var(number e2)))
		| IfLE(C x, V y, e1, e2) -> find (IfLE(C x, V (v y), Var(number e1), Var(number e2)))
		| IfLE(C x, C y, e1, e2) -> find (IfLE(C x, C y, Var(number e1), Var(number e2)))

		| Var(x) -> v x
		| App(x, ys) ->
			if S.mem x !no_effect_fun then
				find (App(v x, List.map (fun y -> v y) ys))
			else newtag()
		| Tuple(xs) -> find (Tuple(List.map (fun x -> v x) xs))
		| ExtArray(x) -> find (ExtArray(v x))
		| ExtFunApp(x, ys) ->
			if S.mem x !no_effect_fun then
				find (ExtFunApp(v x, List.map (fun y -> v y) ys))
			else newtag()
		| Let((x, t), e1, e2) ->
			let num = number e1 in
			addtag (Var(x)) num;
			number e2
		| LetTuple (xts, y, e) ->
			ignore (List.fold_left
			(fun num (x,_) -> addtag (Var(x)) (y ^ string_of_int num); num + 1) 0 xts); (* y という Tuple に対して n 番目の要素を "yn" と番号づけする *)
			number e
		| Get(x,y) -> find (Get (v x, v y))
		| _ -> newtag() (* Get,Put *)

(* 関数を含んでいるか *)
let rec hasapp = function
  | App _ | ExtFunApp _ -> true
  | IfEq (_, _, e1, e2) | IfLE (_, _, e1, e2) | Let (_, e1, e2)
      -> (hasapp e1 || hasapp e2)
  | LetTuple (_, _, e) -> hasapp e
  | _ -> false

(* Putや関数適用があった場合、以前までのGetに対する番号づけを削除 *)
let remove_get () =
  let (getenv, extenv, etcenv) = !tagenv in
    tagenv := (CM.empty, extenv, etcenv)
      
let remove_extarray env =
  let (getenv, extenv, etcenv) = !tagenv in
    CM.fold (fun _ tag a -> M.remove tag a) extenv env

let find e env =
  try Var(M.find (number e) env)
  with Not_found -> e


let rec g env = function
	| Unit | Float _ | Int _ | Neg _ | Add _ | Sub _ | Mul _ | Div _ | SLL _ | Var _ | Tuple _
	| FNeg _ | FAdd _ | FSub _ | FMul _ | FDiv _ |  Get _ | ExtArray _ as e ->
		find e env
	| App (x, _) | ExtFunApp (x, _) as e when S.mem x !no_effect_fun -> find e env
	| App _ | ExtFunApp _ as e -> remove_get(); find e env
	| Put _ as e -> remove_get() ; e
	| IfEq(x, y, e1, e2) -> IfEq(x, y, g env e1, g env e2)
	| IfLE(x, y, e1, e2) -> IfLE(x, y, g env e1, g env e2)
	| Let((x, t), e1, e2) ->
		let e1' = g env e1 in
		let num = number e1' in
		let env' = remove_extarray env in
		addtag (Var(x)) num;
		let e2' =
			if hasapp e1' then
				if effect !no_effect_fun e1' then g env' e2
				else g (M.add num x env') e2
			else
				g (M.add num x env) e2 in
		Let((x, t), e1', e2')
  | LetRec({ name = xt; args = yts; body = e1 }, e2) ->
      if not (S.mem (fst xt) !no_effect_fun) & not (effect_fun (fst xt) !no_effect_fun e1) then
        no_effect_fun := S.add (fst xt) !no_effect_fun;
      LetRec({ name = xt; args = yts; body = g M.empty e1 }, g env e2)
  | LetTuple (xts, y, e) ->
      let _, env' =
		  List.fold_left
			(fun (i,env) (x,_) ->
			   let num = y ^ string_of_int i in
				 addtag (Var(x)) num; (i + 1, M.add num x env)
			)
			(0,env)
			xts in (* y という Tuple に対して n 番目の要素を "yn" と番号づけする *)
			  LetTuple (xts, y, g env e)

let f flg e =
    no_effect_fun := noeffectfun;
	let ans = g M.empty e in
	if flg then
		begin
			print_endline "Print KNormal_t(Cse.ml):";
			print 1 ans;
			print_newline ();
			flush stdout;
		end;
	ans
