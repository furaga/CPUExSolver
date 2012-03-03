let rec indent i =
	if i <= 0 then
		()
	else
		begin
			print_string "  ";
			indent (i - 1)
		end
		
let current_line = ref 1
let current_cols = ref [0]

let use_binary_data = ref false

let get_position n =
	let rec get_position_sub n line = function
		| [] -> assert false
		| x :: xs ->
			if n >= x then
				(line, n - x)
			else
				get_position_sub n (line - 1) xs in
	get_position_sub n !current_line !current_cols
	

