(* 干渉グラフの彩色 *)
(* 「最新コンパイラ構成技法」p226 - p231参照 *)
open Block

(******************)
(** グローバル変数 **)
(******************)
(* 関数内で登場する変数とその型 *)
let varenv = ref M.empty 
(* ＄r0 - ＄r32 *)
let anyregs = Array.to_list (Asm.anyregs)
(* ＄f0 - ＄f32 *)
let anyfregs = Array.to_list (Asm.anyfregs)
(* 割り当てにつかえない整数レジスタ *)
let invalid_regs = Block.diff_list anyregs Asm.allregs
(* 割り当てにつかえない浮動小数レジスタ *)
let invalid_fregs = Block.diff_list anyfregs Asm.allfregs
(* 既彩色の変数群。要はレジスタ *)
let precolored = ref S.empty
(* 彩色すべき変数群 *)
let initial = ref S.empty
(* ワークリスト *)
let simplify_worklist = ref S.empty
let freeze_worklist = ref S.empty
let spill_worklist = ref S.empty
(* スピルすべき・合併すべき・彩色済みの・スタックに積まれた変数群（ノード） *)
let spilled_nodes = ref S.empty
let coalesced_nodes = ref S.empty
let colored_nodes = ref S.empty
let select_stack = ref []
(* Mov系命令群 *)
let coalesced_moves = ref S.empty (* 文stmtのIDの集合 *)
let constrained_moves = ref S.empty 
let frozen_moves = ref S.empty 
let worklist_moves = ref S.empty 
let active_moves = ref S.empty 
let move_list = ref M.empty
let all_moves = ref M.empty
(* 合併された変数の別名解決用 *)
let alias = ref M.empty
(* 隣接行列。高速化のため3種類の方法で定義 *)
let adj_set = ref S.empty	(* TODO *)
let adj_list = ref M.empty
(* 次数 *)
let degree = ref M.empty (* int M.t *)
(* 彩色結果 *)
let color = ref M.empty (* 作業用テンポラリ *)
let colorenv = ref M.empty (* regAllocWithColoring.mlで使用 *)
(* スピルされたときに作られた新しい変数 *)
let new_temps = ref S.empty
(* スピルされた変数群 *)
let spill_cnt = ref 0
(* 関数の引数などをこのレジスタに割り当てたい！という要望があったらここに書いておく。運が良ければ反映される *)
type wish = Target of Id.t | Avoid of Id.t
let wish_env = ref M.empty
(* 関数の返り値となる変数群 *)
let ret_nodes = ref S.empty
(* 関数の実引数となる変数群 *)
let arg_nodes = ref S.empty
(* 関数呼び出しを跨いで生存する変数群 *)
let striding_nodes = ref S.empty
(* 再帰関数か *)
let is_loop = ref false

(********************)
(** デバッグ用関数群 **)
(********************)

(* 関数の干渉グラフをgraphvizで読み込める形式でocに書き込む書き込む *)
let output_iGraph fundef = ()
(*	(* graphvizで読み込めない文字を変換 *)
	let treat_string s =
		for i = 0 to String.length s - 1 do
			if s.[i] = '%' then s.[i] <- 'P'
			else if s.[i] = '.' then s.[i] <- '_'
			else ()
		done; s in
	let name = String.copy (Id.get_name fundef.fName) in
	let oc = open_out ("graph/" ^ (treat_string name) ^ "_" ^ (string_of_int !spill_cnt) ^ ".dot") in
	Printf.fprintf oc "strict graph %s {\n" (treat_string name);
	S.iter (fun edge -> Printf.fprintf oc "\t%s;\n" (treat_string (String.copy edge))) !adj_set;
	Printf.fprintf oc "}\n";
	close_out oc
*)
(***************)
(** 補助関数群 **)
(***************)

(* stmtに登場する変数とその型。set_varenvで使用 *)
let get_var_type stmt =
	match stmt.sInst with
		(* 変数1個 *)
		| Nop (xt)
		| Set (xt, _)
		| Float (xt, _)
		| SetL (xt, _)
		| Restore (xt, _) -> [xt]
		(* 変数2個 *)
		| Mov (xt, x)
		| Neg (xt, x) 
		| Add (xt, x, Asm.C _) 
		| Sub (xt, x, Asm.C _) 
		| Mul (xt, x, Asm.C _) 
		| Div (xt, x, Asm.C _) 
		| SLL (xt, x, Asm.C _) 
		| Ld (xt, x, Asm.C _) 
		| LdF (xt, x, Asm.C _) 
		| IfEq (xt, x, Asm.C _, _, _) 
		| IfLE (xt, x, Asm.C _, _, _) 
		| IfGE (xt, x, Asm.C _, _, _) -> [xt; (x, Type.Int)]
		| FMov (xt, x) 
		| FNeg (xt, x) -> [xt; (x, Type.Float)]
		(* Saveは第二引数の型は分からないが、必ず関数の他の部分で登場しているのでここではあえてなにもしない*)
		| Save (xt, x, _) -> []
		(* 変数3個 *)
		| Add (xt, x, Asm.V y) 
		| Sub (xt, x, Asm.V y) 
		| Mul (xt, x, Asm.V y) 
		| Div (xt, x, Asm.V y) 
		| SLL (xt, x, Asm.V y) 
		| Ld (xt, x, Asm.V y) 
		| LdF (xt, x, Asm.V y)
		| St (xt, x, y, Asm.C _)
		| IfEq (xt, x, Asm.V y, _, _) 
		| IfLE (xt, x, Asm.V y, _, _) 
		| IfGE (xt, x, Asm.V y, _, _) -> [xt; (x, Type.Int); (y, Type.Int)]
		| FAdd (xt, x, y) 
		| FSub (xt, x, y) 
		| FMul (xt, x, y) 
		| FDiv (xt, x, y) 
		| IfFEq (xt, x, y, _, _)
		| IfFLE (xt, x, y, _, _) -> [xt; (x, Type.Float); (y, Type.Float)]
		| StF (xt, x, y, Asm.C _) -> [xt; (x, Type.Float); (y, Type.Int)]
		(* 変数4個 *)
		| St (xt, x, y, Asm.V z) -> [xt; (x, Type.Int); (y, Type.Int); (z, Type.Int)]
		| StF (xt, x, y, Asm.V z) -> [xt; (x, Type.Float); (y, Type.Int); (z, Type.Int)]
		(* 変数いっぱい *)
		| CallCls (xt, name, args, fargs) -> assert false
		| CallDir (xt, Id.L name, args, fargs) -> [xt] @ (List.map (fun x -> (x, Type.Int)) args) @ (List.map (fun x -> (x, Type.Float)) fargs)

(* Mov系の命令か *)
(* ただし、＄f16とか割り当てに使われないレジスタを含むMov命令は無効とする *)
let is_move_instruction stmt = 
	match stmt.sInst with
		| Mov ((x, _), y)(* when not (List.mem x invalid_regs) && not (List.mem y invalid_regs)*) -> true
		| FMov ((x, _), y) (*when not (List.mem x invalid_fregs) && not (List.mem y invalid_fregs)*) -> true
		| _ -> false

(* env[x] <- env[x] U y *)
let add_S x y env =
	let e = if M.mem x env then M.find x env else S.empty in
	let e = S.add y e in
	M.add x e env

(* Some x の x を取り出す *)
let get_some = function Some x -> x | None -> assert false

(* varenvを参照してxの型を返す *)
let get_type x = Block.find_assert (Printf.sprintf "GET_TYPE %s : " x) x !varenv

(* degreeを参照してxの次数を返す *)
let get_degree x = Block.find_assert (Printf.sprintf "GET_DEGREE %s : " x) x !degree

(* adj_listを参照してxに隣接する変数の集合を返す *)
let get_adj_list x = Block.find_assert (Printf.sprintf "GET_ADJ_LIST %s : " x) x !adj_list

(* adj_listを参照してxと関連するMov系命令の集合を返す *)
let get_move_list x = Block.find_assert (Printf.sprintf "GET_MOVE_LIST %s : " x) x !move_list

(* nにとってのKの値 *)
let get_K n = if get_type n = Type.Float then List.length Asm.allfregs else List.length Asm.allregs

(* colorを参照してxに塗られた色を返す *)
let get_color x = Block.find_assert (Printf.sprintf "GET_COLOR %s : " x) x !color

(* wish_envを参照して、変数nに割り当てる色への希望を返す *)
let get_wishes x = if M.mem x !wish_env then Block.find_assert (Printf.sprintf "GET_WISHES %s : " x) x !wish_env else []

(* select_stackに対するプッシュとポップ *)
let push n = select_stack := n :: !select_stack
let pop () = 
	if !select_stack = [] then failwith "POP : select_stack is empty."
	else (
		let ans = List.hd !select_stack in
		select_stack := List.tl !select_stack;
		ans
	)

(* uvからadj_setに入れる値を生成 *)
let make_edge u v = u ^ " -- " ^ v

(* (u, v)が干渉グラフの枝集合に含まれているか *)
let mem_edges u v = S.mem (make_edge u v) !adj_set

(* 干渉グラフ（関数内）に登場する全変数の型を調べてvarenvに登録する。float, unit以外の型は全てintと見なす *)
(* Saveが特別扱いされるのでBlock.set_def_use_sitesを利用するのはよくないはず *)
let set_varenv fundef =
	varenv := M.empty;
	(* 関数本体を調べる *)
	M.iter (fun _ blk ->
			M.iter (
				fun _ stmt -> 
					let conv t = if t = Type.Float || t = Type.Unit then t else Type.Int in
					varenv := List.fold_left (fun env (x, y) -> M.add x (conv y) env) !varenv (get_var_type stmt)
			) blk.bStmts;
	) fundef.fBlocks;
	(* 整数引数 + 整数レジスタ *)
	List.iter (fun x -> varenv := M.add x Type.Int !varenv) (fundef.fArgs @ anyregs);
	(* 浮動小数引数 + 浮動小数レジスタ *)
	List.iter (fun x -> varenv := M.add x Type.Float !varenv) (fundef.fFargs @ anyfregs);
	(* ダミーレジスタ *)
	varenv := M.add "＄r0" Type.Unit !varenv(*;

	(if fundef.fName = Id.L "print_int.344" && !spill_cnt = 2 then
		assert (M.mem "Ti100.423.690" !varenv) 
	)
*)
let set_all_moves fundef =
	all_moves := M.empty;
	M.iter (fun _ blk ->
			M.iter (
				fun _ stmt -> 
					match stmt.sInst with
						| Mov (dst, src) (*when not (List.mem (fst dst) invalid_regs) && not (List.mem src invalid_regs)*) ->
							all_moves := M.add stmt.sId (blk.bId, stmt.sId, dst, src) !all_moves
						| FMov (dst, src) (*when not (List.mem (fst dst) invalid_fregs) && not (List.mem src invalid_fregs)*) ->
							all_moves := M.add stmt.sId (blk.bId, stmt.sId, dst, src) !all_moves
						| _ -> ()
			) blk.bStmts
	) fundef.fBlocks

(* 彩色に対する願いを追加１ *)
let add_wish n wish =
	let env = get_wishes n in
	wish_env := M.add n (wish :: env) !wish_env

(* 彩色に対する願いを追加２ *)
let add_wish_list n wish_list =
	let env = get_wishes n in
	wish_env := M.add n (wish_list @ env) !wish_env

(* 各変数の彩色に対する願い *)
let set_wish_env fundef = ()

(* 各変数の彩色に対する願い(命令別) *)
(* 関数呼び出しの引数はなるべく仮引数のレジスタと一致させたいし、他の仮引数とは一致させたくない *)
let set_wish_env_in_stmt fundef stmt livein liveout =
	match stmt.sInst with
		(* 再帰以外の関数呼び出しのとき *)
		| CallDir (xt, Id.L name, args, fargs) when Id.L name <> fundef.fName ->
			let arg_regs = try Asm.get_arg_regs name with Not_found -> failwith ("Call " ^ name) in
			let use_regs = S.union (Asm.get_use_regs name) (S.of_list arg_regs) in
			(* 関数呼び出しをまたがっている変数にはuse_regs以外のレジスタを割り当てたい *)
			let avoids = S.fold (fun x env -> (Avoid x) :: env) use_regs [] in
			S.iter (fun x -> add_wish_list x avoids) (S.inter livein liveout);
			(* 関数呼び出しの引数はなるべく仮引数のレジスタと一致させたいし、他の仮引数とは一致させたくない *)
			List.iter2 (
				fun r_arg t_arg ->
					let target = Target t_arg in
					let avoids = S.fold (fun x env -> (Avoid x) :: env) (S.remove t_arg use_regs) [] in
					add_wish_list r_arg (target :: avoids)
			) (args @ fargs) arg_regs;
			(* xtは返り値と一致させたい *)
			add_wish (fst xt) (Target (Asm.get_ret_reg name));
		(* 再帰呼び出しのとき *)
		| CallDir (xt, Id.L name, args, fargs) ->
			List.iter2 (
				fun x y ->
					(* 実引数・仮引数は一致させたい *)
					add_wish x (Target y);
					add_wish y (Target x);
					(* 実引数と対応しない仮引数は一致させたくない *)
					List.iter (
						fun a ->
							if a <> y then (
								add_wish x (Avoid a);
								add_wish a (Avoid x)
							)
					) (if List.mem x args then fundef.fArgs else fundef.fFargs)
			) (args @ fargs) (fundef.fArgs @ fundef.fFargs);
			(* xtは返り値と一致させたい *)
			add_wish (fst xt) (Target (Asm.get_ret_reg name))
		| Neg ((d, _), u) | FNeg ((d, _), u) ->
			add_wish d (Target u); add_wish u (Target d)
		| _ when stmt.sSucc = "" ->
			let def, use = Block.get_def_use stmt in
			List.iter (
				fun d ->
					List.iter (
						fun u -> add_wish d (Target u); add_wish u (Target d)
					) use
			) def
		| _ -> ()

(* ついでにret_nodes, arg_nodes, striding_nodesにも追加しておく *)
let set_call_nodes_in_stmt fundef stmt livein liveout =
	match stmt.sInst with
		(* 再帰以外の関数呼び出しのとき *)
		| CallDir ((x, _), Id.L name, args, fargs) ->
			ret_nodes := S.add x !ret_nodes;
			arg_nodes := S.union (S.of_list (args @ fargs)) !arg_nodes;
			striding_nodes := S.union (S.inter livein liveout) !striding_nodes;
			if Id.L name = fundef.fName then is_loop := true
		| _ -> ()

(* 干渉グラフから消去してselect_stackに積む変数を選択 *)
(* 1.2～4以外の変数 *)
(* 2.CallDirの返り値 *)
(* 3.CallDirの引数 *)
(* 5.仮引数 *)
(* の順番で選んでいく *)
let choose_simplify_node fundef =
	let s2 = S.inter !ret_nodes !simplify_worklist in
	let s3 = S.inter !arg_nodes !simplify_worklist in
	let s4 = S.inter (S.of_list (fundef.fArgs @ fundef.fFargs)) !simplify_worklist in
	let s = S.diff !simplify_worklist (S.union s2 (S.union s3 s4)) in
	let (_, ans) = 
		List.fold_left (
			fun (s, ans) ds ->
				if ans <> [] then (s, ans)
				else (
					if S.is_empty s then (S.union s ds, [])
					else (s, [S.min_elt s])				
				)
		) (s, []) [s2; s3; s4; S.empty] in
	assert (List.length ans = 1);
	let ans = List.hd ans in
	assert (S.mem ans !simplify_worklist);
	ans

(* uv間に枝を追加する *)
let add_edge u v =
	let t1 = get_type u and t2 = get_type v in
	assert (t1 = Type.Float || t1 = Type.Unit || t1 = Type.Int);
	assert (t2 = Type.Float || t2 = Type.Unit || t2 = Type.Int);
	let uv = make_edge u v and vu = make_edge v u in
	if t1 = t2 && u <> v && not (S.mem uv !adj_set) then (
		adj_set := S.add uv !adj_set;
		adj_set := S.add vu !adj_set;
		if not (S.mem u !precolored) then (
			adj_list := add_S u v !adj_list;
			degree := M.add u (1 + get_degree u) !degree
		);
		if not (S.mem v !precolored) then (
			adj_list := add_S v u !adj_list;
			degree := M.add v (1 + get_degree v) !degree
		)
	)
	
(* 現時点でnに隣り合っている節点。スタックにつまれたり合併された分はカウントしない *)
let adjacent n = S.diff (get_adj_list n) (S.union (S.of_list !select_stack) !coalesced_nodes)

(* nがオペランドとして使用されているMov系命令の集合 *)
let node_moves n = S.inter (get_move_list n) (S.union !active_moves !worklist_moves)

(* nがMov系の命令のオペランドとして使用されているか *)
let move_related n = not (S.is_empty (node_moves n))

(* nodesの各要素について、その変数と関連するMov命令を合併可能にする *)
let enable_moves nodes =
	S.iter (
		fun n ->
			S.iter (
				fun m ->
					if S.mem m !active_moves then (
						active_moves := S.remove m !active_moves;
						worklist_moves := S.add m !worklist_moves
					)
			) (node_moves n)
	) nodes

(* mの次数を1減らす *)
let decrement_degree m =
	let d = get_degree m in
	if d = get_K m then (
		enable_moves (S.add m (adjacent m));
		spill_worklist := S.remove m !spill_worklist;
		if move_related m then 	freeze_worklist := S.add m !freeze_worklist
		else simplify_worklist := S.add m !simplify_worklist
	)

(* 可能ならuの凍結を解除してsimplify_worklistに追加 *)
let add_worklist u =
	if not (S.mem u !precolored) && not (move_related u) && get_degree u < get_K u then (
		freeze_worklist := S.remove u !freeze_worklist;
		simplify_worklist := S.add u !simplify_worklist;
	)

(* 既彩色節を合併するかを決める。rは既彩色節（レジスタ）だと分かっている *)
let ok t r = get_degree t < get_K t || S.mem t !precolored || mem_edges t r

(* タイガーブックp215にあるBriggsの保守的な合併戦略 *)
let conservative nodes =
	let k = ref 0 in
	S.iter (
		fun n ->
			if get_degree n >= get_K n then k := !k + 1
	) nodes;
	S.is_empty nodes || !k < get_K (S.min_elt nodes)

(* 合併によってつけられた別名を検索 *)
let rec get_alias n =
	if S.mem n !coalesced_nodes then get_alias (find_assert (Printf.sprintf "GET_ALIAS %s" n) n !alias)
	else n
	
(* u, vを合併 *)
let combine u v =
	(if S.mem v !freeze_worklist then freeze_worklist := S.remove v !freeze_worklist
	else spill_worklist := S.remove v !spill_worklist);
	coalesced_nodes := S.add v !coalesced_nodes;
	alias := M.add v u !alias;
	move_list := M.add u (S.union (get_move_list u) (get_move_list v)) !move_list;
	enable_moves (S.of_list [v]);
	S.iter (
		fun t ->
			add_edge t u;
			decrement_degree t
	) (adjacent v);
	if get_degree u >= get_K u && S.mem u !freeze_worklist then (
		freeze_worklist := S.remove u !freeze_worklist;
		spill_worklist := S.add u !spill_worklist
	)

(* u関連のMov系命令の合併は絶対にしない *)
let freeze_moves u =
	S.iter (
		fun m ->
			let (_, _, (y, _), x) = Block.find_assert "COALESCE : " m !all_moves in
			let v = if get_alias y = get_alias u then get_alias x else get_alias y in
			active_moves := S.remove m !active_moves;
			frozen_moves := S.add m !frozen_moves;
			(* vがレジスタならワークリストに加えてはいけない *)
			if not (S.mem v !precolored) && S.is_empty (node_moves v) && get_degree v < get_K v then (
				freeze_worklist := S.remove v !freeze_worklist;
				simplify_worklist := S.add v !simplify_worklist;
			)
	) (node_moves u)
	
(* spill_worklistから優先してスピルしたい変数を選ぶ *)
(* 「コンパイラの構成と最適化」p423の[Chai82]の方法を使った *)
let choose_spill_node fundef =
	let (x, hx) = 
		S.fold (
			fun x (m, hm) ->
				let cost = List.length (Block.get_use_sites x @ Block.get_def_sites x) in
				let deg = get_degree x in
				assert (deg > 0);
				let hx = (float_of_int cost) /. (float_of_int deg) in
				if hx < hm then (x, hx) (* 更新 *)
				else (m, hm)
		) !spill_worklist ("", max_float) in
	assert (x <> "");
	assert (S.mem x !spill_worklist);
	x
	
(* ok_colorsから実際に彩色する色を選択 *)
let choose_color fundef n ok_colors =
	let env = 
		S.fold (
			fun c env -> M.add c 0 env
		) ok_colors M.empty in
	let env =
		List.fold_left (
			fun env x ->
				match x with
					| Target reg ->
						let reg = if M.mem reg !color then M.find reg !color else reg in
						if M.mem reg env then 
							let point = Block.find_assert "CHOOSE_COLOR(Target) : " reg env in
							M.add reg (point + 1) env
						else env
					| Avoid reg ->
						let reg = if M.mem reg !color then M.find reg !color else reg in
						if M.mem reg env then 
							let point = Block.find_assert "CHOOSE_COLOR(Avoid) : " reg env in
							M.add reg (point - 1) env
						else env
		) env (get_wishes n) in
	let (ans, point) =
		M.fold (
			fun x px (m, pm) ->
				if px > pm then (x, px) 
				else if px = pm then (
					(* ポイントが同じなら番号の若いレジスタを選ぶ *)
					let typ = Block.find_assert "CHOOSE_COLOR(x) : " x !varenv in
					let prefix_len = String.length (if typ = Type.Float then "＄f" else "＄r") in
					let nx = int_of_string (String.sub x prefix_len (String.length x - prefix_len)) in
					let nm = int_of_string (String.sub m prefix_len (String.length m - prefix_len)) in
					if nx < nm then (x, px)
					else (m, pm)
				)
				else (m, pm)
		) env ("", min_int) in
	assert (ans <> "");
	assert (S.mem ans ok_colors);
	ans

(* 文の直前にRestoreを挿入 *)
let insert_restore fundef (blk_id, stmt_id) x =
	let blk = Block.find_assert ("INSERT_RESTORE " ^ blk_id ^ " : ") blk_id fundef.fBlocks in
	let stmt = Block.find_assert ("INSERT_RESTORE " ^ stmt_id ^ " : ") stmt_id blk.bStmts in
	let t = get_type x in
	(* 命令のID作成 *)
	let id = Block.gen_stmt_id () in
	(* 新しいテンポラリを作成 *)
	let new_temp = Id.genid x in
	new_temps := S.add new_temp !new_temps;
	(* 新しいRestore文を作成 *)
	let new_stmt = {
		sId = id;
		sParent = blk.bId;
		sInst = Restore ((new_temp, t), x);
		sPred = stmt.sPred;
		sSucc = stmt.sId;
		sLivein = S.empty;
		sLiveout = S.empty
	} in
	stmt.sPred <- id;
	(if new_stmt.sPred = "" then blk.bHead <- id
	else
		let pred = Block.find_assert ("INSERT_RESTORE " ^ new_stmt.sPred ^ " : ") new_stmt.sPred blk.bStmts in
		pred.sSucc <- id);
	blk.bStmts <- M.add id new_stmt blk.bStmts;
	stmt.sInst <- Block.replace stmt x new_temp

(* 関数のはじめにSaveを挿入 *)
let insert_save_arg fundef x =
	let blk = Block.find_assert ("INSERT_SAVE_ARG " ^ fundef.fHead ^ " : ") fundef.fHead fundef.fBlocks in
	let stmt = Block.find_assert ("INSERT_SAVE_ARG " ^ blk.bHead ^ " : ") blk.bHead blk.bStmts in
	(* 命令のID作成 *)
	let id = Block.gen_stmt_id () in
	new_temps := S.add x !new_temps;
	(* 新しいSave文を作成 *)
	let new_stmt = {
		sId = id;
		sParent = blk.bId;
		sInst = Save (("＄r0", Type.Unit), x, x);
		sPred = "";
		sSucc = stmt.sId;
		sLivein = S.empty;
		sLiveout = S.empty
	} in
	stmt.sPred <- id;
	assert (new_stmt.sPred = "");
	blk.bHead <- id;
	blk.bStmts <- M.add id new_stmt blk.bStmts

let insert_save2 fundef blk stmt x new_temp =
	let get_succ b = Block.find_assert "INSERT_SAVE2 : " (List.hd b.bSuccs) fundef.fBlocks in
	let rec find_insert_point b cnt =
		let succ_len = List.length b.bSuccs in
		assert (succ_len > 0);
		let succ = get_succ b in
		if succ_len >= 2 then find_insert_point succ (cnt + 1)
		else if cnt > 1 then find_insert_point succ (cnt - 1)
		else succ in
	let succ = get_succ blk in
	let target_blk = find_insert_point succ 1 in
	let target_stmt = if M.is_empty target_blk.bStmts then None else Some (Block.find_assert ("INSERT_SAVE2 " ^ target_blk.bHead ^ " : ") target_blk.bHead target_blk.bStmts) in

	(* 命令のID作成 *)
	let id = Block.gen_stmt_id () in
	(* 新しいテンポラリを作成 *)
	new_temps := S.add new_temp !new_temps;
	(* 新しいSave文を作成 *)
	let new_stmt = {
		sId = id;
		sParent = target_blk.bId;
		sInst = Save (("＄r0", Type.Unit), new_temp, x);
		sPred = "";
		sSucc = if target_stmt = None then "" else (get_some target_stmt).sId;
		sLivein = S.empty;
		sLiveout = S.empty
	} in
	assert (new_stmt.sPred = "");
	(if target_stmt <> None then (get_some target_stmt).sPred <- id else target_blk.bTail <- id);
	target_blk.bHead <- id;
	target_blk.bStmts <- M.add id new_stmt target_blk.bStmts;
	stmt.sInst <- Block.replace stmt x new_temp;
	if Block.debug then
		Printf.eprintf "INSERT %s from (%s, %s) to (%s, %s)\n" id blk.bId stmt.sId target_blk.bId (if target_stmt = None then "" else (get_some target_stmt).sId)

		
(* 文の直後にSaveを挿入 *)
(* ただし、分岐する（If文で終わる）基本ブロックの末尾に挿入しなければいけないときは *)
(* その分岐の合流地点となる基本ブロックを探して、そこの先頭にSave命令を入れる *)
let insert_save fundef (blk_id, stmt_id) x new_temp =
	let blk = Block.find_assert ("INSERT_SAVE " ^ blk_id ^ " : ") blk_id fundef.fBlocks in
	let stmt = Block.find_assert ("INSERT_SAVE " ^ stmt_id ^ " : ") stmt_id blk.bStmts in
	(* 基本ブロックの末尾 *)
	if stmt.sSucc = "" then (
		if List.length blk.bSuccs >= 2 then insert_save2 fundef blk stmt x new_temp
		else stmt.sInst <- Block.replace stmt x new_temp
	)
	else (
		(* 命令のID作成 *)
		let id = Block.gen_stmt_id () in
		(* 新しいテンポラリを作成 *)
		let new_temp = Id.genid x in
		new_temps := S.add new_temp !new_temps;
		(* 新しいSave文を作成 *)
		let new_stmt = {
			sId = id;
			sParent = blk.bId;
			sInst = Save (("＄r0", Type.Unit), new_temp, x);
			sPred = stmt.sId;
			sSucc = stmt.sSucc;
			sLivein = S.empty;
			sLiveout = S.empty
		} in
		stmt.sSucc <- id;
		(if new_stmt.sSucc = "" then (* ブロックの末尾だったら *)
			blk.bTail <- id
		else
			let succ = Block.find_assert ("INSERT_SAVE " ^ new_stmt.sSucc ^ " : ") new_stmt.sSucc blk.bStmts in
			succ.sPred <- id
		);
		blk.bStmts <- M.add id new_stmt blk.bStmts;
		stmt.sInst <- Block.replace stmt x new_temp
	)

(**********************)
(** 彩色のための関数群 **)
(**********************)

(** 初期化 **)
let initialize is_first fundef = 
	(* 既彩色節というのだからすべてのレジスタを入れるべきだろう? *)
	precolored := S.of_list (anyregs @ anyfregs);
	(* 干渉グラフに登場する全変数とその型 *)
	set_varenv fundef;
	(* ワークリスト *)
	simplify_worklist := S.empty;
	freeze_worklist := S.empty;
	spill_worklist := S.empty;
	(* 変数群（ノード） *)
	select_stack := [];
	(* Mov系命令群 *)
	coalesced_moves := S.empty; (* 文stmtのIDの集合 *)
	constrained_moves := S.empty; 
	frozen_moves := S.empty;
	worklist_moves := S.empty; 
	active_moves := S.empty ;
	move_list := M.fold (fun x _ env -> M.add x S.empty env) !varenv M.empty;
	set_all_moves fundef;
	(* 合併された変数の別名解決用 *)
	alias := M.empty;
	(* 隣接行列。高速化のため3種類の方法で定義 *)
	adj_set := S.empty;
	adj_list := M.fold (fun x _ env -> M.add x S.empty env) !varenv M.empty;
	(* 次数 *)
	degree := M.fold (fun x _ env -> M.add x 0 env) !varenv M.empty;
	(* 作業用テンポラリ。既彩色節についてはもう塗っておく *)
	color := S.fold (fun x env -> M.add x x env) !precolored M.empty; 
	(* 複数の引数に同じレジスタが割り当てられないように、引数間での完全グラフを作っておく *)
	List.iter (fun x -> List.iter (fun y -> add_edge x y) fundef.fArgs) fundef.fArgs;
	List.iter (fun x -> List.iter (fun y -> add_edge x y) fundef.fFargs) fundef.fFargs;
	(* 彩色に関する要望 *)
	wish_env := M.empty;
	set_wish_env fundef;
	(* 関数の返り値となる変数群 *)
	ret_nodes := S.empty;
	(* 関数の実引数となる変数群 *)
	arg_nodes := S.empty;
	(* 関数呼び出しを跨いで生存する変数群 *)
	striding_nodes := S.empty;
	(* 再帰関数か *)
	is_loop := false;
	(* rewriteのときには実行されないもの *)
	if is_first then (
		(* 全関数に対する彩色結果 *)
		colorenv := M.empty;
		(* initial。varenvのうち、レジスタでも型がUnitでもないものを登録 *)
		initial := M.fold (fun x t env -> if not (S.mem x !precolored) && t <> Type.Unit then S.add x env else env) !varenv S.empty;
		(* ノード群 *)
		colored_nodes := S.empty;
		spilled_nodes := S.empty;
		coalesced_nodes := S.empty;
		(* スピルされたときに作られた新しい変数 *)
		new_temps := S.empty;
		(* スピルされた回数 *)
		spill_cnt := 0
	);
	if Block.debug then Printf.eprintf "\n<%s> スピル %d 回目\n" (Id.get_name fundef.fName) !spill_cnt

(** 干渉グラフの作成 **)
let build fundef =
	M.iter (
		fun _ blk ->
			let live = ref blk.bLiveout in
			let rec iter stmt_id = 
				let liveout = !live in
				(* def, useの取得 *)
				let stmt = if stmt_id = "" then None else Some (Block.find_assert "BUILD : " stmt_id blk.bStmts) in
				let (def, use) = 
					if stmt_id = "" then (* 関数の先頭で引数が定義されているとみなす *)
						(S.empty, S.of_list (fundef.fArgs @ fundef.fFargs)) 
					else
						(fun (a, b) -> (S.of_list a, S.of_list b)) (Block.get_def_use (get_some stmt)) in
				(* Mov系命令だったらmove_listに登録 *)
				(if stmt_id <> "" && is_move_instruction (get_some stmt) then (
					let stmt = get_some stmt in
					live := S.diff !live use;
					S.iter (fun n -> move_list := add_S n stmt.sId !move_list) (S.union def use);
					worklist_moves := S.add stmt.sId !worklist_moves
				));
				(* liveの更新と枝の追加 *)
				live := S.union !live def;
				S.iter (fun d -> S.iter (fun l -> add_edge l d) !live) def;
				live := S.union use (S.diff !live def);
				let livein = !live in
				(* 彩色への要求と単純化の順序決めに使う変数群の設定 *)
				(if stmt_id <> "" then (
					set_wish_env_in_stmt fundef (get_some stmt) livein liveout;
					set_call_nodes_in_stmt fundef (get_some stmt) livein liveout
				));
				if stmt_id <> "" then iter (get_some stmt).sPred in	
			if not (M.is_empty blk.bStmts) then iter blk.bTail		
	) fundef.fBlocks;
	(** デバッグ出力 **)
	(if Block.debug then output_iGraph fundef)

(** ワークリストの作成。initialの値を３つのワークリストのいずれかに割り振っていく **)
let make_worklist fundef =
	S.iter (
		fun n ->
			if get_degree n >= get_K n then spill_worklist := S.add n !spill_worklist 
			else if move_related n then freeze_worklist := S.add n !freeze_worklist
			else simplify_worklist := S.add n !simplify_worklist
	) !initial;
	initial := S.empty;
	(** デバッグ出力 **)
	(if Block.debug then (
(*		S.eprint "SPILL_WORKLIST :" !spill_worklist;
		S.eprint "FREEZE_WORKLIST :" !freeze_worklist;
		S.eprint "SIMPLIFY_WORKLIST :" !simplify_worklist;*)
	))

(** 単純化 **)
let simplify fundef =
	(* ここで選ばれるのが後になるほど彩色されるのが早くなる *)
	(* 引数はできるだけ早めに塗られておきたい *)
	let n = choose_simplify_node fundef in
	simplify_worklist := S.remove n !simplify_worklist;
	push n;
	S.iter (fun m -> decrement_degree m) (adjacent n)

(** 合併 **)
let coalesce fundef =
	let m = S.min_elt !worklist_moves in
	let (_, _, (dst, _), src) = Block.find_assert "COALESCE : " m !all_moves in
	let x = get_alias src and y = get_alias dst in
	(* x, yのどっちかがレジスタだったら u の方がレジスタになるように調整 *)
	let (u, v) = if S.mem y !precolored then (y, x) else (x, y) in
	worklist_moves := S.remove m !worklist_moves;
	if u = v then (
		(* u <- u みたいな命令のとき。明らかに合併できる *)
		coalesced_moves := S.add m !coalesced_moves;
		add_worklist u
	)
	else if S.mem v !precolored || mem_edges u v then (
		(* やむごとなき事情（u, vが両方レジスタまたはu, vが干渉している）により絶対合併できない場合 *)
		constrained_moves := S.add m !constrained_moves;
		add_worklist u;
		add_worklist v
	)
	else if
		List.mem u (invalid_regs @ invalid_fregs) || (* この時点のvはレジスタではないので、uが割り当てに使われないレジスタだったら問答無用で合併できるはず。多分 *)
		let is_reg = S.mem u !precolored in 
		(is_reg && S.fold (fun t env -> env && ok t u) (adjacent v) true) ||
		(not is_reg && conservative (S.union (adjacent u) (adjacent v)))
	then (
		(* 合併できる場合 *)
		coalesced_moves := S.add m !coalesced_moves;
		combine u v;
		add_worklist u
	)
	else (
		(* まだ合併できないが、単純化されつづけたらできるようになるかもしれない場合 *)
		active_moves := S.add m !active_moves
	)

(** 凍結 **)
let freeze fundef = 
	let u = S.min_elt !freeze_worklist in
	freeze_worklist := S.remove u !freeze_worklist;
	simplify_worklist := S.add u !simplify_worklist;
	freeze_moves u

(** スピルする変数の選択。choose_spill関数で先に選ばれた変数がスピルする可能性が高くなる **)
(** この時点でspill_worklistに入っている要素のいくつかが将来スピルされる **)
let select_spill fundef =
	let m = choose_spill_node fundef in
	spill_worklist := S.remove m !spill_worklist;
	simplify_worklist := S.add m !simplify_worklist;
	freeze_moves m (* mの次数が多いのでm関連のMov命令は絶対に合併できない *)

(** selct_stackに入っているノードを順に彩色していく **)
let assign_colors fundef =
	(** デバッグ出力1 **)
	(if Block.debug then Block.eprint_list "SELECT_STACK :" !select_stack);
	assert (S.is_empty (S.inter !precolored (S.of_list !select_stack)));		(* レジスタはスタックには絶対積まれていないはず *)
	assert (S.is_empty (S.inter !precolored !coalesced_nodes)); 	(* レジスタはスタックには絶対積まれていないはず *)
	while !select_stack <> [] do
		let n = pop () in
		let ok_colors = ref (S.of_list (if get_type n = Type.Float then Asm.allfregs else Asm.allregs)) in
		S.iter (
			fun w ->
				let w = get_alias w in
				if S.mem w (S.union !colored_nodes !precolored) then
					ok_colors := S.remove (get_color w) !ok_colors 
		) (get_adj_list n);
		if S.is_empty !ok_colors then spilled_nodes := S.add n !spilled_nodes
		else (
			colored_nodes := S.add n !colored_nodes;
			let c = choose_color fundef n !ok_colors in (* wish_envをみて、ok_colorsの中から一番よさそうな色を割り当てる。別に最適ではない *)
			color := M.add n c !color
		)
	done;

	S.iter (fun n -> color := M.add n (get_color (get_alias n)) !color) !coalesced_nodes

(** スピルされた変数の各定義・使用位置にそれぞれSave, Restore命令を挿入 **)
let rewrite_program fundef =
	new_temps := S.empty;
	S.iter (
		fun n ->
			(* 引数なら関数の最初にSave文をいれる *)
			(if List.mem n (fundef.fArgs @ fundef.fFargs) then insert_save_arg fundef n);
			(* 各定義の前にSaveを入れる *)
			let new_temp = Id.genid n in
			List.iter (fun site -> insert_save fundef site n new_temp) (Block.get_def_sites n);
			(* 各使用の前にRestoreを入れる *)
			List.iter (fun site -> insert_restore fundef site n) (Block.get_use_sites n);
	) !spilled_nodes;
	spilled_nodes := S.empty;

	(** デバッグ出力 **)
	(if Block.debug then
(*		if fundef.fName = Id.L "print_int.284" && !spill_cnt = 1 then (
			S.print (Printf.sprintf "<%s> colored_nodes in REWRITE (%d回目)\n" (Id.get_name fundef.fName) !spill_cnt) !colored_nodes;
			S.print (Printf.sprintf "<%s> coalesced_nodes in REWRITE (%d回目)\n" (Id.get_name fundef.fName) !spill_cnt) !coalesced_nodes;
			S.print (Printf.sprintf "<%s> new_temps in REWRITE (%d回目)\n" (Id.get_name fundef.fName) !spill_cnt) !new_temps
		)*)()
	);

	initial := S.union !colored_nodes (S.union !coalesced_nodes !new_temps);
	colored_nodes := S.empty;
	coalesced_nodes := S.empty;
	spill_cnt := 1 + !spill_cnt;
	(** デバッグ出力 **)
	(if Block.debug then
		Printf.eprintf "<%s> REWRITE (%d回目)\n" (Id.get_name fundef.fName) !spill_cnt;
(*		Block.print_fundef 2 fundef*)
	)

(** 関数毎に彩色。ついでに実行時間を計測する **)
let rec main is_first fundef = 
	let name = Id.get_name fundef.fName in
	(* 初期化 *)
	Time.start (); initialize is_first fundef; Time.stop ("<" ^ name ^ "> INITIALIZE : ") Block.debug; flush stderr;
	(* 生存解析 *)
	Time.start (); Liveness.analysis fundef; Time.stop ("<" ^ name ^ "> LIVENESS.ANALYSIS : ") Block.debug; flush stderr;
	(* 干渉グラフの作成 *)
	Time.start (); build fundef; Time.stop  ("<" ^ name ^ "> BUILD : ") Block.debug; flush stderr;
	(* 各ワークリストの作成 *)
	Time.start (); make_worklist fundef; Time.stop ("<" ^ name ^ "> MAKE_WORKLIST : ") Block.debug; flush stderr;
	(* 各ワークリストの変数が全てselect_stackかcoalesced_nodesに入るまで繰り返す *)
	Time.start (); 
	while
		not (
			S.is_empty !simplify_worklist &&
			S.is_empty !worklist_moves &&
			S.is_empty !freeze_worklist &&
			S.is_empty !spill_worklist
		)
	do
	(*	(if fundef.fName = Id.L "f.342" then (
			S.eprint "SIMPLIFY_WORKLIST : " !simplify_worklist;
			S.eprint "WORKLIST_MOVES : " !worklist_moves;
			S.eprint "FREEZE_WORKLIST : " !freeze_worklist;
			S.eprint "SPILL_WORKLIST : " !spill_worklist
		));
	*)
		if not (S.is_empty !simplify_worklist) then simplify fundef
		else if not (S.is_empty !worklist_moves) then coalesce fundef
		else if not (S.is_empty !freeze_worklist) then freeze fundef
		else if not (S.is_empty !spill_worklist) then select_spill fundef
	done;
	Time.stop ("<" ^ name ^ "> MAIN_LOOP : ") Block.debug; flush stderr;
	(* select_stack・coalesced_nodesの内容を元に彩色する *)
	Time.start (); assign_colors fundef; Time.stop ("<" ^ name ^ "> ASSIGN_COLORS : ") Block.debug; flush stderr;
	(* スピルされてたら書き換えてもう一回 *) 
	if not (S.is_empty !spilled_nodes) then (
		Time.start (); rewrite_program fundef; Time.stop ("<" ^ name ^ "> REWRITE_PROGRAM : ") Block.debug; flush stderr;
		main false fundef
	)
	else (
		(try
   			let data = M.find name !Asm.fundata in
   			let args = List.map (fun x -> try M.find x !color with Not_found -> Asm.reg_0) (fundef.fArgs @ fundef.fFargs) in
   			let data = {data with Asm.arg_regs = args} in
   			Asm.fundata := M.add name data !Asm.fundata;
		with Not_found -> assert (name = "min_caml_start"));
		colorenv := M.add (Id.get_name fundef.fName) !color !colorenv;
(*		Block.print_fundef 2 fundef;
		M.print 
			("color : ")
			(M.fold (fun x y env -> if x <> y then M.add x y env else env) !color M.empty) 
			(fun x -> x)*)
	);
	if Block.debug then Printf.eprintf "\n"

