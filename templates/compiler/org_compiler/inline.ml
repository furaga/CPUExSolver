open KNormal

(* ����饤��Ÿ���򤹤�ؿ��Υ����� *)
let threshold = ref 0

(* ����饤��Ÿ���򤷤ʤ��ؿ��� *)
let noInline = ["write"; "read_int"; "read_float"; "create_array_int"; "create_array_float"]

(* ���ؿ��ˤĤ��ơ����δؿ�����������ǲ���Ŭ�Ѥ��줿�������� *)
let ref_counts = ref M.empty
let rec ref_count = function
  | IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) | Let(_, e1, e2) ->
      ref_count e1;
      ref_count e2
  | LetRec({ body = e1 }, e2) ->
      ref_count e1;
      ref_count e2
  | LetTuple(_, _, e) ->
      ref_count e
  | App(x, _) ->
      let n = try M.find x !ref_counts with Not_found -> 0 in
      ref_counts := M.add x (n + 1) !ref_counts
  | _ -> ()

(* �ؿ��Υ��������¬ *)
let rec size = function
  | IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) | Let(_, e1, e2) | LetRec({ body = e1 }, e2) ->
      1 + size e1 + size e2
  | LetTuple(_, _, e) -> 1 + size e
  | ExtFunApp(x, _) when x = "sqrt" || x = "fabs" -> 1
  | App _ | ExtFunApp _ -> 20		(* �ؿ�Ŭ�Ѥ�Ÿ�����줿�ꤹ��Τǥ������ϰ�դ˷�ޤ�ʤ����椨�˥ҥ塼�ꥹ�ƥ��å����˷��Ƥ��� *)
  | _ -> 1

(* no_inline_nif�δؿ����ҤȤĤǤ�ޤޤ�Ƥ����饤��饤��Ÿ�����ʤ� *)
let rec no_inline nif = function
  | IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) | Let(_, e1, e2) | LetRec({ body = e1 }, e2) ->
      no_inline nif e1 || no_inline nif e2
  | LetTuple(_, _, e) -> no_inline nif e
  | ExtFunApp(x, _) when List.mem x noInline -> true
  | App(x, _) -> S.mem x nif
  | _ -> false
    
(* nif : no inline functions *)
let rec g nif env = function
	| IfEq(x, y, e1, e2) -> IfEq(x, y, g nif env e1, g nif env e2)
	| IfLE(x, y, e1, e2) -> IfLE(x, y, g nif env e1, g nif env e2)
	| Let(xt, e1, e2) -> Let(xt, g nif env e1, g nif env e2)
	| LetRec({name = (x, t); args = yts; body = e1}, e2) ->
		(* ����ؿ���Τ������ܲȤȤϤ��������㤦 *)
		(* �ܲȤϴؿ���ǤƤ������Ÿ���ѤδĶ����ɲä��Ƥ��� *)
		(* �����Ǥϡ�
			����0������Ȥ��Ƥ�����Ÿ�����ʤ�
			����1������Ȥ��Ƥ�����Ÿ������
			�����Ƶ�Ū�˴ؿ�x���������Ƥ��鹵�����Ÿ����threshold��¾���1/5���٤Ȥ��ư�����		
		*)
		let nif = if no_inline nif e1 then S.add x nif else nif in
		let e1 = g nif env e1 in
		let ref_count = try M.find x !ref_counts with Not_found -> 100 in
		let inline =
			if !threshold = 0 then false
			else if ref_count = 1 then true
			else (not (no_inline nif e1)) && size e1 < !threshold * (if S.mem x (fv e1) then 1 else 5) in
		let env =
			if inline then M.add x (yts, e1) env
			else env in
		let e1 = if S.mem x (fv e1) && inline then g nif env e1 else e1 in
		LetRec({ name = (x, t); args = yts; body = e1}, g nif env e2)
	| App(x, ys) when M.mem x env ->
		let (zs, e) = M.find x env in
		(*      Format.eprintf "inlining %s@." x;*)
		let env' = List.fold_left2
			(fun env' (z, t) y -> M.add z y env'
			) M.empty zs ys in
	Alpha.g env' e
	| LetTuple(xts, y, e) -> LetTuple(xts, y, g nif env e)
	| e -> e

let f e =
  (
	  Format.eprintf "Before Inline: %d@." (size e);
	  ref_counts := M.empty;
	  ref_count e;
	  let e = g S.empty M.empty e in
	  Format.eprintf "After Inline: %d@." (size e);
	  e
  )
