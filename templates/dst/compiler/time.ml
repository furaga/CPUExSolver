(* 実行時間の計測 *)
let time = ref 0.0
let start () = time := Sys.time ()
let stop comment flg = if flg then Printf.eprintf "%s%f 秒\n" comment (Sys.time () -. !time)

