(* 「最新コンパイラ構成技法」p427参照 *)
open Block
(*
let use_sites = ref M.empty	(* 変数の使用場所の集合 *)
let blkenv = ref S.empty	(* 探索済みの基本ブロック *)
*)

(** タイガーブックの方程式10.3 (p198) を満たしているか確認 **)
let chk_liveness fundef =
	M.iter (
		fun blk_id blk ->
(*			S.print ("\t" ^ blk_id ^ " bLivein : ") blk.bLivein;
			S.print ("\t" ^ blk_id ^ " bLiveout : ") blk.bLiveout;
			S.print ("\t" ^ blk_id ^ " def : ") (Block.get_def_as_block blk.bId);
			S.print ("\t" ^ blk_id ^ " use : ") (Block.get_use_as_block blk.bId);*)
			assert (
				blk.bLivein = 
					S.union 
						(Block.get_use_as_block blk.bId)
						(S.diff blk.bLiveout (Block.get_def_as_block blk.bId))
			);
			assert (
				blk.bLiveout =
					List.fold_left (
						fun env succ ->
							S.union env (if succ = "" then S.empty else (find_assert "確認中" succ fundef.fBlocks).bLivein)
					) S.empty blk.bSuccs
			);
	) fundef.fBlocks

(** 逆トポロジカルソート **)
type topological_sort = {t_id : Id.t; mutable t_succs : S.t}
let reverse_topological_sort blks =
	let res = ref [] in
	let next = ref [] in
	let ords = ref (List.map (fun blk -> {t_id = blk.bId; t_succs = S.of_list blk.bSuccs}) blks) in
	while !ords <> [] do
		next := [];
		List.iter (
			fun x ->
				if S.is_empty x.t_succs then
					(List.iter (
						fun y ->
							y.t_succs <- S.remove x.t_id y.t_succs
					) !ords;
					res := x.t_id :: !res)
				else
					next := x :: !next
		) !ords;
		if !ords = !next then
			(res := (List.hd !ords).t_id :: !res;
			next := List.tl !ords);
		ords := !next
	done;
	List.rev !res

(** 生存解析 **)
(* タイガーブックp198 *)
let analysis fundef =
	let name = Id.get_name fundef.fName in
(*	Printf.eprintf "<%s> アナライズ\n" name; (* 碧の軌跡面白い *)
*)
(*	Time.start ();*)
	Block.set_def_use_sites fundef;
	(* foreach n : in[n] <- {}; out[n] <- {}*)
	M.iter (
		fun _ blk ->
			blk.bLivein <- S.empty;
			blk.bLiveout <- S.empty
	) fundef.fBlocks;
(*	Time.stop "\tInitialize : ";*)

(*	Time.start ();*)
	let ord = reverse_topological_sort (M.fold (fun _ x env -> x :: env) fundef.fBlocks []) in
(* Time.stop "\tSORT : ";*)

(*	Time.start ();*)
	let flg = ref true in
	let cnt = ref 0 in
	while !flg do
		cnt := !cnt + 1;
		flg := false;
		List.iter (
			fun blk_id ->
				let blk = Block.find_assert "Blk in Analysis" blk_id fundef.fBlocks in
				let bLivein' = blk.bLivein in 
				let bLiveout' = blk.bLiveout in

				(* in[n] <- use[n] ∪ (out[n] - def[n]) *)
				blk.bLivein <- S.union (Block.get_use_as_block blk.bId) (S.diff blk.bLiveout (Block.get_def_as_block blk.bId));

				(* out[n] <- ∪(forall s in succ[n]) in[s] *)
				blk.bLiveout <-
					List.fold_left (
						fun env succ_id ->
							let succ = Block.find_assert "Succ in Analysis" succ_id fundef.fBlocks in
							S.union env succ.bLivein
					) S.empty blk.bSuccs;
				flg := !flg || bLivein' <> blk.bLivein || bLiveout' <> blk.bLiveout
		) ord
	done(*;
	(if Block.debug then chk_liveness fundef)*)
(*	Time.stop (Printf.sprintf "\tLOOP(%d回) : " !cnt)*)

