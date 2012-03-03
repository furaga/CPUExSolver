(* customized version of Set *)

module S =
  Set.Make
    (struct
      type t = Id.t
      let compare = compare
    end)
include S

let of_list l = List.fold_left (fun s e -> add e s) empty l
let length env = S.fold (fun env x -> x + 1) env 0
let print comment env = print_string comment; S.iter (Printf.printf "%s, ") env; print_newline ()
let eprint comment env = Printf.eprintf "%s" comment; S.iter (Printf.eprintf "%s, ") env; Printf.eprintf "\n"
let eq env1 env2 =
	length env1 = length env2 &&
	fold (fun x env -> env && mem x env2) env1 true
