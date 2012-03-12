(* æµ®å‹•å°æ•°åŸºæœ¬æ¼”ç®—1 *)
let rec fequal a b = a = b in
let rec fless a b = (a < b) in

let rec fispos a = (a > 0.0) in
let rec fisneg a = (a < 0.0) in
let rec fiszero a = (a = 0.0) in

(* boolç³» *)
let rec xor a b = a <> b in

(* æµ®å‹•å°æ•°åŸºæœ¬æ¼”ç®—2 *)
let rec fabs a =
	if a < 0.0 then -. a
	else a
in
let rec abs_float x = fabs x in
let rec fneg a = -. a in
let rec fhalf a = a *. 0.5 in
let rec fsqr a = a *. a in

(* floor, int_of_float, float_of_int ã¯lib_asm.sã§å®šç¾© *)

(* ç®—è¡“é–¢æ•° *)
let pi = 3.14159265358979323846264 in
let pi2 = pi *. 2.0 in
let pih = pi *. 0.5 in

(* atan *)
let rec atan_sub i xx y =
	if i < 0.5 then y
	else atan_sub (i -. 1.0) xx ((i *. i *. xx) /. (i +. i +. 1.0 +. y))
in
let rec atan x =
	let sgn =
		if x > 1.0 then 1
		else if x < -1.0 then -1
		else 0
	in
	let x =
		if sgn <> 0 then 1.0 /. x
		else x
	in
	let a = atan_sub 11.0 (x *. x) 0.0 in
	let b = x /. (1.0 +. a) in
	if sgn > 0 then pi /. 2.0 -. b
	else if sgn < 0 then -. pi /. 2.0 -. b
	else b
	in

(* tan *)
let rec tan x = (* -pi/4 <= x <= pi/4 *)
	let rec tan_sub i xx y =
		if i < 2.5 then y
			else tan_sub (i -. 2.) xx (xx /. (i -. y))
	in
	x /. (1. -. (tan_sub 9. (x *. x) 0.0))
in

(* sin *)
let rec sin_sub x = 
	let pi2 = pi *. 2.0 in
	if x > pi2 then sin_sub (x -. pi2)
	else if x < 0.0 then sin_sub (x +. pi2)
	else x in
let rec sin x =
	let pi = 3.14159265358979323846264 in
	let pi2 = pi *. 2.0 in
	let pih = pi *. 0.5 in
	(* tan *)
	let s1 = x > 0.0 in
	let x0 = fabs x in
	let x1 = sin_sub x0 in
	let s2 = if x1 > pi then not s1 else s1 in
	let x2 = if x1 > pi then pi2 -. x1 else x1 in
	let x3 = if x2 > pih then pi -. x2 else x2 in
	let t = tan (x3 *. 0.5) in
	let ans = 2. *. t /. (1. +. t *. t) in
	if s2 then ans else fneg ans in

(* cos *)
let rec cos x = 
	let pih = pi *. 0.5 in
	sin (pih -. x) in

(* create_arrayç³»ã¯ã‚³ãƒ³ãƒ‘ã‚¤ãƒ«æ™‚ã«ã‚³ãƒ¼ãƒ‰ã‚’ç”Ÿæˆã€‚compiler/emit.mlå‚ç…§ *)
let rec mul10 x = x * 8 + x * 2 in

(* read_int *)
let read_int_ans = Array.create 1 0 in
let read_int_s = Array.create 1 0 in
let rec read_int_token in_token prev =
	let c = input_char () in
	let flg = 
		if c < 48 then true
		else if c > 57 then true
		else false in
	if flg then
		(if in_token then (if read_int_s.(0) = 1 then read_int_ans.(0) else (-read_int_ans.(0))) else read_int_token false c)
	else
		((if read_int_s.(0) = 0 then
			(* prev == '-' *)
			(if prev = 45 then read_int_s.(0) <- (-1) else read_int_s.(0) <- (1));
		else
			());
		read_int_ans.(0) <- mul10 read_int_ans.(0) + (c - 48);
		read_int_token true c) in
let rec read_int _ = 
	read_int_ans.(0) <- 0;
	read_int_s.(0) <- 0;
	read_int_token false 32 in

(* read_float *)
let read_float_i = Array.create 1 0 in
let read_float_f = Array.create 1 0 in
let read_float_exp = Array.create 1 1 in
let read_float_s = Array.create 1 0 in
let rec read_float_token1 in_token prev =
	let c = input_char () in
	let flg =
		if c < 48 then true
		else if c > 57 then true
		else false in
	if flg then
		(if in_token then c else read_float_token1 false c)
	else
		((if read_float_s.(0) = 0 then
			(* prev == '-' *)
			(if prev = 45 then read_float_s.(0) <- (-1) else read_float_s.(0) <- (1));

		else
			());
		read_float_i.(0) <- mul10 read_float_i.(0) + (c - 48);
		read_float_token1 true c) in
let rec read_float_token2 in_token =
	let c = input_char () in
	let flg =
		if c < 48 then true
		else if c > 57 then true
		else false in
	if flg then
		(if in_token then () else read_float_token2 false)
	else
		(read_float_f.(0) <- mul10 read_float_f.(0) + (c - 48);
		read_float_exp.(0) <- mul10 read_float_exp.(0);
		read_float_token2 true) in
let rec read_float _ = 
	read_float_i.(0) <- 0;
	read_float_f.(0) <- 0;
	read_float_exp.(0) <- 1;
	read_float_s.(0) <- 0;
	let nextch = read_float_token1 false 32 in
	let ans =
		if nextch = 46 then (* nextch = '.' *)
			(read_float_token2 false;
			(float_of_int read_float_i.(0)) +. (float_of_int read_float_f.(0)) /. (float_of_int read_float_exp.(0)))
		else
			float_of_int read_float_i.(0) in
	if read_float_s.(0) = 1 then
		ans
	else
		-. ans in

(* / 2, * 2ã¯parser.mlyã§å·¦ãƒ»å³ã‚·ãƒ•ãƒˆã«å¤‰æ›ã•ã‚Œã‚‹ã®ã§ä½¿ã£ã¦ã‚ˆã„ *)
let rec mul_sub a b =
	if b = 0 then 0
	else (
		let b_mod_2 = b - (b / 2) * 2 in
		if b_mod_2 = 0 then
			(mul_sub (a * 2) (b / 2))
		else
			(mul_sub (a * 2) (b / 2)) + a
	) in

let rec mul a b =
	if b < 0 then 
		mul_sub (-a) (-b)
	else
		mul_sub a b in

let rec div_binary_search a b left right =
	let mid = (left + right) / 2 in
	let x = mid * b in
	if right - left <= 1 then
		left
	else
		if x < a then
			div_binary_search a b mid right
		else if x = a then
			mid
		else
			div_binary_search a b left mid in

let rec div_sub a b left =
	if mul (b * 2) left  <= a then
		div_sub a b (left * 2)
	else
		div_binary_search a b left (left * 2) in

let rec div a b =
	(* bã¯0ã§ã¯ãªã„ *)
	let abs_a = if a >= 0 then a else -a in
	let abs_b = if b >= 0 then b else -b in
	if abs_a < abs_b then
		0
	else (
		let ans = div_sub abs_a abs_b 1 in
		if a >= 0 then (
			if b >= 0 then
				ans
			else
				-ans
		)
		else (
			if b >= 0 then
				-ans
			else
				ans
		)
	) in

(* print_int divå‘½ä»¤ã‚’ä½¿ã‚ãªã„ç‰ˆ *)
let rec print_int x =
	if x < 0 then
		(print_char 45; print_int (-x))
	else
		(* 100000000ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 100000000 0 3 in
		let dx = tx * 100000000 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then false
			else (print_char (48 + tx); true) in

		(* 10000000ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 10000000 0 10 in
		let dx = tx * 10000000 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in

		(* 1000000ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 1000000 0 10 in
		let dx = tx * 1000000 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in

		(* 100000ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 100000 0 10 in
		let dx = tx * 100000 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in

		(* 10000ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 10000 0 10 in
		let dx = tx * 10000 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in

		(* 1000ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 1000 0 10 in
		let dx = tx * 1000 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in
		(* 100ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 100 0 10 in
		let dx = tx * 100 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in
		(* 10ã®ä½ã‚’è¡¨ç¤º *)
		let tx = div_binary_search x 10 0 10 in
		let dx = tx * 10 in
		let x = x - dx in
		let flg = 
			if tx <= 0 then
				(if flg then
					(print_char (48 + tx); true)
				else
					false)
			else
				(print_char (48 + tx); true) in
		(* 1ã®ä½ã‚’è¡¨ç¤º *)
		print_char (48 + x) in


(**************** ¥°¥í¡¼¥Ğ¥ëÊÑ¿ô¤ÎÀë¸À ****************)

(* ¥ª¥Ö¥¸¥§¥¯¥È¤Î¸Ä¿ô *)
let n_objects = create_array 1 0 in

(* ¥ª¥Ö¥¸¥§¥¯¥È¤Î¥Ç¡¼¥¿¤òÆş¤ì¤ë¥Ù¥¯¥È¥ë¡ÊºÇÂç60¸Ä¡Ë*)
let objects = 
  let dummy = create_array 0 0.0 in
  create_array 60 (0, 0, 0, 0, dummy, dummy, false, dummy, dummy, dummy, dummy) in

(* Screen ¤ÎÃæ¿´ºÂÉ¸ *)
let screen = create_array 3 0.0 in
(* »ëÅÀ¤ÎºÂÉ¸ *)
let viewpoint = create_array 3 0.0 in
(* ¸÷¸»Êı¸ş¥Ù¥¯¥È¥ë (Ã±°Ì¥Ù¥¯¥È¥ë) *)
let light = create_array 3 0.0 in
(* ¶ÀÌÌ¥Ï¥¤¥é¥¤¥È¶¯ÅÙ (É¸½à=255) *)
let beam = create_array 1 255.0 in
(* AND ¥Í¥Ã¥È¥ï¡¼¥¯¤òÊİ»ı *)
let and_net = create_array 50 (create_array 1 (-1)) in
(* OR ¥Í¥Ã¥È¥ï¡¼¥¯¤òÊİ»ı *)
let or_net = create_array 1 (create_array 1 (and_net.(0))) in

(* °Ê²¼¡¢¸òº¹È½Äê¥ë¡¼¥Á¥ó¤ÎÊÖ¤êÃÍ³ÊÇ¼ÍÑ *)
(* solver ¤Î¸òÅÀ ¤Î t ¤ÎÃÍ *)
let solver_dist = create_array 1 0.0 in
(* ¸òÅÀ¤ÎÄ¾ÊıÂÎÉ½ÌÌ¤Ç¤ÎÊı¸ş *)
let intsec_rectside = create_array 1 0 in
(* È¯¸«¤·¤¿¸òÅÀ¤ÎºÇ¾®¤Î t *)
let tmin = create_array 1 (1000000000.0) in
(* ¸òÅÀ¤ÎºÂÉ¸ *)
let intersection_point = create_array 3 0.0 in
(* ¾×ÆÍ¤·¤¿¥ª¥Ö¥¸¥§¥¯¥ÈÈÖ¹æ *)
let intersected_object_id = create_array 1 0 in
(* Ë¡Àş¥Ù¥¯¥È¥ë *)
let nvector = create_array 3 0.0 in
(* ¸òÅÀ¤Î¿§ *)
let texture_color = create_array 3 0.0 in

(* ·×»»Ãæ¤Î´ÖÀÜ¼õ¸÷¶¯ÅÙ¤òÊİ»ı *)
let diffuse_ray = create_array 3 0.0 in
(* ¥¹¥¯¥ê¡¼¥ó¾å¤ÎÅÀ¤ÎÌÀ¤ë¤µ *)
let rgb = create_array 3 0.0 in

(* ²èÁü¥µ¥¤¥º *)
let image_size = create_array 2 0 in
(* ²èÁü¤ÎÃæ¿´ = ²èÁü¥µ¥¤¥º¤ÎÈ¾Ê¬ *)
let image_center = create_array 2 0 in
(* 3¼¡¸µ¾å¤Î¥Ô¥¯¥»¥ë´Ö³Ö *)
let scan_pitch = create_array 1 0.0 in

(* judge_intersection¤ËÍ¿¤¨¤ë¸÷Àş»ÏÅÀ *)
let startp = create_array 3 0.0 in
(* judge_intersection_fast¤ËÍ¿¤¨¤ë¸÷Àş»ÏÅÀ *)
let startp_fast = create_array 3 0.0 in

(* ²èÌÌ¾å¤Îx,y,z¼´¤Î3¼¡¸µ¶õ´Ö¾å¤ÎÊı¸ş *)
let screenx_dir = create_array 3 0.0 in
let screeny_dir = create_array 3 0.0 in
let screenz_dir = create_array 3 0.0 in

(* Ä¾ÀÜ¸÷ÄÉÀ×¤Ç»È¤¦¸÷Êı¸ş¥Ù¥¯¥È¥ë *)
let ptrace_dirvec  = create_array 3 0.0 in

(* ´ÖÀÜ¸÷¥µ¥ó¥×¥ê¥ó¥°¤Ë»È¤¦Êı¸ş¥Ù¥¯¥È¥ë *)
let dirvecs = 
  let dummyf = create_array 0 0.0 in
  let dummyff = create_array 0 dummyf in
  let dummy_vs = create_array 0 (dummyf, dummyff) in
  create_array 5 dummy_vs in

(* ¸÷¸»¸÷¤ÎÁ°½èÍıºÑ¤ßÊı¸ş¥Ù¥¯¥È¥ë *)
let light_dirvec =
  let dummyf2 = create_array 0 0.0 in
  let v3 = create_array 3 0.0 in
  let consts = create_array 60 dummyf2 in
  (v3, consts) in

(* ¶ÀÊ¿ÌÌ¤ÎÈ¿¼Í¾ğÊó *)
let reflections =
  let dummyf3 = create_array 0 0.0 in
  let dummyff3 = create_array 0 dummyf3 in
  let dummydv = (dummyf3, dummyff3) in
  create_array 180 (0, dummydv, 0.0) in

(* reflections¤ÎÍ­¸ú¤ÊÍ×ÁÇ¿ô *) 

let n_reflections = create_array 1 0 in
(****************************************************************)
(*                                                              *)
(* Ray Tracing Program for (Mini) Objective Caml                *)
(*                                                              *)
(* Original Program by Ryoji Kawamichi                          *)
(* Arranged for Chez Scheme by Motohico Nanano                  *)
(* Arranged for Objective Caml by Y.Oiwa and E.Sumii            *)
(* Added diffuse ray tracer by Y.Sugawara                       *)
(*                                                              *)
(****************************************************************)

(*NOMINCAML open MiniMLRuntime;;*)
(*NOMINCAML open Globals;;*)
(*(*MINCAML*) let true = 1 in 
(*MINCAML*) let false = 0 in *)
(*(*MINCAML*) let rec xor x y = if x then not y else y in
*)
(******************************************************************************
   ¥æ¡¼¥Æ¥£¥ê¥Æ¥£¡¼
 *****************************************************************************)

(* Éä¹æ *)
let rec sgn x =
  if fiszero x then 0.0
  else if fispos x then 1.0
  else -1.0
in

(* ¾ò·ïÉÕ¤­Éä¹æÈ¿Å¾ *)
let rec fneg_cond cond x =
  if cond then x else fneg x
in

(* (x+y) mod 5 *)
let rec add_mod5 x y =
  let sum = x + y in
  if sum >= 5 then sum - 5 else sum
in

(******************************************************************************
   ¥Ù¥¯¥È¥ëÁàºî¤Î¤¿¤á¤Î¥×¥ê¥ß¥Æ¥£¥Ö
 *****************************************************************************)

(*
let rec vecprint v =
  (o_param_abc m) inFormat.eprintf "(%f %f %f)" v.(0) v.(1) v.(2)
in
*)

(* ÃÍÂåÆş *)
let rec vecset v x y z =
  v.(0) <- x;
  v.(1) <- y;
  v.(2) <- z
in

(* Æ±¤¸ÃÍ¤ÇËä¤á¤ë *)
let rec vecfill v elem =
  v.(0) <- elem;
  v.(1) <- elem;
  v.(2) <- elem
in

(* Îí½é´ü²½ *)
let rec vecbzero v =
  vecfill v 0.0
in

(* ¥³¥Ô¡¼ *)
let rec veccpy dest src = 
  dest.(0) <- src.(0);
  dest.(1) <- src.(1);
  dest.(2) <- src.(2)
in

(* µ÷Î¥¤Î¼«¾è *)
let rec vecdist2 p q = 
  fsqr (p.(0) -. q.(0)) +. fsqr (p.(1) -. q.(1)) +. fsqr (p.(2) -. q.(2))
in

(* Àµµ¬²½ ¥¼¥í³ä¤ê¥Á¥§¥Ã¥¯Ìµ¤· *)
let rec vecunit v = 
  let il = 1.0 /. sqrt(fsqr v.(0) +. fsqr v.(1) +. fsqr v.(2)) in
  v.(0) <- v.(0) *. il;
  v.(1) <- v.(1) *. il;
  v.(2) <- v.(2) *. il
in

(* Éä¹æÉÕÀµµ¬²½ ¥¼¥í³ä¥Á¥§¥Ã¥¯*)
let rec vecunit_sgn v inv =
  let l = sqrt (fsqr v.(0) +. fsqr v.(1) +. fsqr v.(2)) in
  let il = if fiszero l then 1.0 else if inv then -1.0 /. l else 1.0 /. l in
  v.(0) <- v.(0) *. il;
  v.(1) <- v.(1) *. il;
  v.(2) <- v.(2) *. il
in

(* ÆâÀÑ *)
let rec veciprod v w =
  v.(0) *. w.(0) +. v.(1) *. w.(1) +. v.(2) *. w.(2)
in

(* ÆâÀÑ °ú¿ô·Á¼°¤¬°Û¤Ê¤ëÈÇ *)
let rec veciprod2 v w0 w1 w2 =
  v.(0) *. w0 +. v.(1) *. w1 +. v.(2) *. w2
in

(* ÊÌ¤Ê¥Ù¥¯¥È¥ë¤ÎÄê¿ôÇÜ¤ò²Ã»» *)
let rec vecaccum dest scale v =
  dest.(0) <- dest.(0) +. scale *. v.(0);
  dest.(1) <- dest.(1) +. scale *. v.(1);
  dest.(2) <- dest.(2) +. scale *. v.(2)
in

(* ¥Ù¥¯¥È¥ë¤ÎÏÂ *)
let rec vecadd dest v =
  dest.(0) <- dest.(0) +. v.(0);
  dest.(1) <- dest.(1) +. v.(1);
  dest.(2) <- dest.(2) +. v.(2)
in

(* ¥Ù¥¯¥È¥ëÍ×ÁÇÆ±»Î¤ÎÀÑ *)
let rec vecmul dest v =
  dest.(0) <- dest.(0) *. v.(0);
  dest.(1) <- dest.(1) *. v.(1);
  dest.(2) <- dest.(2) *. v.(2)
in

(* ¥Ù¥¯¥È¥ë¤òÄê¿ôÇÜ *)
let rec vecscale dest scale =
  dest.(0) <- dest.(0) *. scale; 
  dest.(1) <- dest.(1) *. scale; 
  dest.(2) <- dest.(2) *. scale
in

(* Â¾¤Î£²¥Ù¥¯¥È¥ë¤ÎÍ×ÁÇÆ±»Î¤ÎÀÑ¤ò·×»»¤·²Ã»» *)
let rec vecaccumv dest v w =
  dest.(0) <- dest.(0) +. v.(0) *. w.(0);
  dest.(1) <- dest.(1) +. v.(1) *. w.(1);
  dest.(2) <- dest.(2) +. v.(2) *. w.(2)
in

(******************************************************************************
   ¥ª¥Ö¥¸¥§¥¯¥È¥Ç¡¼¥¿¹½Â¤¤Ø¤Î¥¢¥¯¥»¥¹´Ø¿ô
 *****************************************************************************)

(* ¥Æ¥¯¥¹¥Á¥ã¼ï 0:Ìµ¤· 1:»Ô¾¾ÌÏÍÍ 2:¼ÊÌÏÍÍ 3:Æ±¿´±ßÌÏÍÍ 4:ÈÃÅÀ*)
let rec o_texturetype m = 
  let (m_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_tex
in

(* ÊªÂÎ¤Î·Á¾õ 0:Ä¾ÊıÂÎ 1:Ê¿ÌÌ 2:Æó¼¡¶ÊÌÌ 3:±ß¿í *)
let rec o_form m = 
  let (xm_tex, m_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_shape
in

(* È¿¼ÍÆÃÀ­ 0:³È»¶È¿¼Í¤Î¤ß 1:³È»¶¡ÜÈó´°Á´¶ÀÌÌÈ¿¼Í 2:³È»¶¡Ü´°Á´¶ÀÌÌÈ¿¼Í *)
let rec o_reflectiontype m = 
  let (xm_tex, xm_shape, m_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_surface
in

(* ¶ÊÌÌ¤Î³°Â¦¤¬¿¿¤«¤É¤¦¤«¤Î¥Õ¥é¥° true:³°Â¦¤¬¿¿ false:ÆâÂ¦¤¬¿¿ *)
let rec o_isinvert m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       m_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m in
  m_invert
in

(* ²óÅ¾¤ÎÍ­Ìµ true:²óÅ¾¤¢¤ê false:²óÅ¾Ìµ¤· 2¼¡¶ÊÌÌ¤È±ß¿í¤Î¤ßÍ­¸ú *)
let rec o_isrot m = 
  let (xm_tex, xm_shape, xm_surface, m_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m in
  m_isrot
in

(* ÊªÂÎ·Á¾õ¤Î a¥Ñ¥é¥á¡¼¥¿ *)
let rec o_param_a m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       m_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_abc.(0)
in

(* ÊªÂÎ·Á¾õ¤Î b¥Ñ¥é¥á¡¼¥¿ *)
let rec o_param_b m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       m_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_abc.(1)
in

(* ÊªÂÎ·Á¾õ¤Î c¥Ñ¥é¥á¡¼¥¿ *)
let rec o_param_c m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       m_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_abc.(2)
in

(* ÊªÂÎ·Á¾õ¤Î abc¥Ñ¥é¥á¡¼¥¿ *)
let rec o_param_abc m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       m_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_abc
in

(* ÊªÂÎ¤ÎÃæ¿´xºÂÉ¸ *)
let rec o_param_x m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, m_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_xyz.(0)
in

(* ÊªÂÎ¤ÎÃæ¿´yºÂÉ¸ *)
let rec o_param_y m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, m_xyz,
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_xyz.(1)
in

(* ÊªÂÎ¤ÎÃæ¿´zºÂÉ¸ *)
let rec o_param_z m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, m_xyz,
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_xyz.(2)
in

(* ÊªÂÎ¤Î³È»¶È¿¼ÍÎ¨ 0.0 -- 1.0 *)
let rec o_diffuse m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, m_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_surfparams.(0)
in

(* ÊªÂÎ¤ÎÉÔ´°Á´¶ÀÌÌÈ¿¼ÍÎ¨ 0.0 -- 1.0 *)
let rec o_hilight m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, m_surfparams, xm_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_surfparams.(1)
in

(* ÊªÂÎ¿§¤Î RÀ®Ê¬ *)
let rec o_color_red m = 
  let (xm_tex, xm_shape, m_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, m_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_color.(0)
in

(* ÊªÂÎ¿§¤Î GÀ®Ê¬ *)
let rec o_color_green m = 
  let (xm_tex, xm_shape, m_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, m_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_color.(1)
in

(* ÊªÂÎ¿§¤Î BÀ®Ê¬ *)
let rec o_color_blue m = 
  let (xm_tex, xm_shape, m_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, m_color,
       xm_rot123, xm_ctbl) = m 
  in
  m_color.(2)
in

(* ÊªÂÎ¤Î¶ÊÌÌÊıÄø¼°¤Î y*z¹à¤Î·¸¿ô 2¼¡¶ÊÌÌ¤È±ß¿í¤Ç¡¢²óÅ¾¤¬¤¢¤ë¾ì¹ç¤Î¤ß *)
let rec o_param_r1 m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       m_rot123, xm_ctbl) = m 
  in
  m_rot123.(0)
in

(* ÊªÂÎ¤Î¶ÊÌÌÊıÄø¼°¤Î x*z¹à¤Î·¸¿ô 2¼¡¶ÊÌÌ¤È±ß¿í¤Ç¡¢²óÅ¾¤¬¤¢¤ë¾ì¹ç¤Î¤ß *)
let rec o_param_r2 m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       m_rot123, xm_ctbl) = m 
  in
  m_rot123.(1)
in

(* ÊªÂÎ¤Î¶ÊÌÌÊıÄø¼°¤Î x*y¹à¤Î·¸¿ô 2¼¡¶ÊÌÌ¤È±ß¿í¤Ç¡¢²óÅ¾¤¬¤¢¤ë¾ì¹ç¤Î¤ß *)
let rec o_param_r3 m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       m_rot123, xm_ctbl) = m 
  in
  m_rot123.(2)
in

(* ¸÷Àş¤ÎÈ¯¼ÍÅÀ¤ò¤¢¤é¤«¤¸¤á·×»»¤·¤¿¾ì¹ç¤ÎÄê¿ô¥Æ¡¼¥Ö¥ë *)
(*
   0 -- 2 ÈÖÌÜ¤ÎÍ×ÁÇ: ÊªÂÎ¤Î¸ÇÍ­ºÂÉ¸·Ï¤ËÊ¿¹Ô°ÜÆ°¤·¤¿¸÷Àş»ÏÅÀ
   3ÈÖÌÜ¤ÎÍ×ÁÇ: 
   Ä¾ÊıÂÎ¢ªÌµ¸ú
   Ê¿ÌÌ¢ª abc¥Ù¥¯¥È¥ë¤È¤ÎÆâÀÑ
   Æó¼¡¶ÊÌÌ¡¢±ß¿í¢ªÆó¼¡ÊıÄø¼°¤ÎÄê¿ô¹à
 *)
let rec o_param_ctbl m = 
  let (xm_tex, xm_shape, xm_surface, xm_isrot, 
       xm_abc, xm_xyz, 
       xm_invert, xm_surfparams, xm_color,
       xm_rot123, m_ctbl) = m 
  in
  m_ctbl
in

(******************************************************************************
   Pixel¥Ç¡¼¥¿¤Î¥á¥ó¥Ğ¥¢¥¯¥»¥¹´Ø¿ô·² 
 *****************************************************************************)

(* Ä¾ÀÜ¸÷ÄÉÀ×¤ÇÆÀ¤é¤ì¤¿¥Ô¥¯¥»¥ë¤ÎRGBÃÍ *)
let rec p_rgb pixel = 
  let (m_rgb, xm_isect_ps, xm_sids, xm_cdif, xm_engy,
       xm_r20p, xm_gid, xm_nvectors ) = pixel in
  m_rgb
in

(* Èô¤Ğ¤·¤¿¸÷¤¬ÊªÂÎ¤È¾×ÆÍ¤·¤¿ÅÀ¤ÎÇÛÎó *)
let rec p_intersection_points pixel = 
  let (xm_rgb, m_isect_ps, xm_sids, xm_cdif, xm_engy,
       xm_r20p, xm_gid, xm_nvectors ) = pixel in
  m_isect_ps
in

(* Èô¤Ğ¤·¤¿¸÷¤¬¾×ÆÍ¤·¤¿ÊªÂÎÌÌÈÖ¹æ¤ÎÇÛÎó *)
(* ÊªÂÎÌÌÈÖ¹æ¤Ï ¥ª¥Ö¥¸¥§¥¯¥ÈÈÖ¹æ * 4 + (solver¤ÎÊÖ¤êÃÍ) *)
let rec p_surface_ids pixel = 
  let (xm_rgb, xm_isect_ps, m_sids, xm_cdif, xm_engy,
       xm_r20p, xm_gid, xm_nvectors ) = pixel in
  m_sids
in

(* ´ÖÀÜ¼õ¸÷¤ò·×»»¤¹¤ë¤«Èİ¤«¤Î¥Õ¥é¥° *)
let rec p_calc_diffuse pixel = 
  let (xm_rgb, xm_isect_ps, xm_sids, m_cdif, xm_engy,
       xm_r20p, xm_gid, xm_nvectors ) = pixel in
  m_cdif
in

(* ¾×ÆÍÅÀ¤Î´ÖÀÜ¼õ¸÷¥¨¥Í¥ë¥®¡¼¤¬¥Ô¥¯¥»¥ëµ±ÅÙ¤ËÍ¿¤¨¤ë´óÍ¿¤ÎÂç¤­¤µ *)
let rec p_energy pixel =
  let (xm_rgb, xm_isect_ps, xm_sids, xm_cdif, m_engy,
       xm_r20p, xm_gid, xm_nvectors ) = pixel in
  m_engy
in

(* ¾×ÆÍÅÀ¤Î´ÖÀÜ¼õ¸÷¥¨¥Í¥ë¥®¡¼¤ò¸÷ÀşËÜ¿ô¤ò1/5¤Ë´Ö°ú¤­¤·¤Æ·×»»¤·¤¿ÃÍ *)
let rec p_received_ray_20percent pixel =
  let (xm_rgb, xm_isect_ps, xm_sids, xm_cdif, xm_engy,
       m_r20p, xm_gid, xm_nvectors ) = pixel in
  m_r20p
in

(* ¤³¤Î¥Ô¥¯¥»¥ë¤Î¥°¥ë¡¼¥× ID *)
(* 
   ¥¹¥¯¥ê¡¼¥óºÂÉ¸ (x,y)¤ÎÅÀ¤Î¥°¥ë¡¼¥×ID¤ò (x+2*y) mod 5 ¤ÈÄê¤á¤ë
   ·ë²Ì¡¢²¼¿Ş¤Î¤è¤¦¤ÊÊ¬¤±Êı¤Ë¤Ê¤ê¡¢³ÆÅÀ¤Ï¾å²¼º¸±¦4ÅÀ¤ÈÊÌ¤Ê¥°¥ë¡¼¥×¤Ë¤Ê¤ë
   0 1 2 3 4 0 1 2 3 4 
   2 3 4 0 1 2 3 4 0 1
   4 0 1 2 3 4 0 1 2 3
   1 2 3 4 0 1 2 3 4 0
*)

let rec p_group_id pixel =
  let (xm_rgb, xm_isect_ps, xm_sids, xm_cdif, xm_engy,
       xm_r20p, m_gid, xm_nvectors ) = pixel in
  m_gid.(0)
in
   
(* ¥°¥ë¡¼¥×ID¤ò¥»¥Ã¥È¤¹¤ë¥¢¥¯¥»¥¹´Ø¿ô *)
let rec p_set_group_id pixel id =
  let (xm_rgb, xm_isect_ps, xm_sids, xm_cdif, xm_engy,
       xm_r20p, m_gid, xm_nvectors ) = pixel in
  m_gid.(0) <- id
in

(* ³Æ¾×ÆÍÅÀ¤Ë¤ª¤±¤ëË¡Àş¥Ù¥¯¥È¥ë *)
let rec p_nvectors pixel =
  let (xm_rgb, xm_isect_ps, xm_sids, xm_cdif, xm_engy,
       xm_r20p, xm_gid, m_nvectors ) = pixel in
  m_nvectors
in

(******************************************************************************
   Á°½èÍıºÑ¤ßÊı¸ş¥Ù¥¯¥È¥ë¤Î¥á¥ó¥Ğ¥¢¥¯¥»¥¹´Ø¿ô
 *****************************************************************************)

(* ¥Ù¥¯¥È¥ë *)
let rec d_vec d =
  let (m_vec, xm_const) = d in
  m_vec
in

(* ³Æ¥ª¥Ö¥¸¥§¥¯¥È¤ËÂĞ¤·¤Æºî¤Ã¤¿ solver ¹âÂ®²½ÍÑÄê¿ô¥Æ¡¼¥Ö¥ë *)
let rec d_const d =
  let (dm_vec, m_const) = d in
  m_const
in
   
(******************************************************************************
   Ê¿ÌÌ¶ÀÌÌÂÎ¤ÎÈ¿¼Í¾ğÊó
 *****************************************************************************)

(* ÌÌÈÖ¹æ ¥ª¥Ö¥¸¥§¥¯¥ÈÈÖ¹æ*4 + (solver¤ÎÊÖ¤êÃÍ) *)
let rec r_surface_id r =
  let (m_sid, xm_dvec, xm_br) = r in
  m_sid
in

(* ¸÷¸»¸÷¤ÎÈ¿¼ÍÊı¸ş¥Ù¥¯¥È¥ë(¸÷¤ÈµÕ¸ş¤­) *)
let rec r_dvec r =
  let (xm_sid, m_dvec, xm_br) = r in
  m_dvec
in
   
(* ÊªÂÎ¤ÎÈ¿¼ÍÎ¨ *)
let rec r_bright r =
  let (xm_sid, xm_dvec, m_br) = r in
  m_br
in

(******************************************************************************
   ¥Ç¡¼¥¿ÆÉ¤ß¹ş¤ß¤Î´Ø¿ô·² 
 *****************************************************************************)

(* ¥é¥¸¥¢¥ó *)
let rec rad x = 
  x *. 0.017453293
in

(**** ´Ä¶­¥Ç¡¼¥¿¤ÎÆÉ¤ß¹ş¤ß ****)
let rec read_screen_settings _ =
  
  (* ¥¹¥¯¥ê¡¼¥óÃæ¿´¤ÎºÂÉ¸ *)
  screen.(0) <- read_float ();
  screen.(1) <- read_float ();
  screen.(2) <- read_float ();
  (* ²óÅ¾³Ñ *)
  let v1 = rad (read_float ()) in
  let cos_v1 = cos v1 in
  let sin_v1 = sin v1 in
  let v2 = rad (read_float ()) in
  let cos_v2 = cos v2 in
  let sin_v2 = sin v2 in
  (* ¥¹¥¯¥ê¡¼¥óÌÌ¤Î±ü¹Ô¤­Êı¸ş¤Î¥Ù¥¯¥È¥ë Ãí»ëÅÀ¤«¤é¤Îµ÷Î¥200¤ò¤«¤±¤ë *)
  screenz_dir.(0) <- cos_v1 *. sin_v2 *. 200.0;
  screenz_dir.(1) <- sin_v1 *. -200.0;
  screenz_dir.(2) <- cos_v1 *. cos_v2 *. 200.0;
  (* ¥¹¥¯¥ê¡¼¥óÌÌXÊı¸ş¤Î¥Ù¥¯¥È¥ë *)
  screenx_dir.(0) <- cos_v2;
  screenx_dir.(1) <- 0.0;
  screenx_dir.(2) <- fneg sin_v2;
  (* ¥¹¥¯¥ê¡¼¥óÌÌYÊı¸ş¤Î¥Ù¥¯¥È¥ë *)
  screeny_dir.(0) <- fneg sin_v1 *. sin_v2;
  screeny_dir.(1) <- fneg cos_v1;
  screeny_dir.(2) <- fneg sin_v1 *. cos_v2;
  (* »ëÅÀ°ÌÃÖ¥Ù¥¯¥È¥ë(ÀäÂĞºÂÉ¸) *)
  viewpoint.(0) <- screen.(0) -. screenz_dir.(0);
  viewpoint.(1) <- screen.(1) -. screenz_dir.(1);
  viewpoint.(2) <- screen.(2) -. screenz_dir.(2)

in

(* ¸÷¸»¾ğÊó¤ÎÆÉ¤ß¹ş¤ß *)
let rec read_light _ =
   
  let nl = read_int () in

  (* ¸÷Àş´Ø·¸ *)
  let l1 = rad (read_float ()) in
  let sl1 = sin l1 in
  light.(1) <- fneg sl1;
  let l2 = rad (read_float ()) in
  let cl1 = cos l1 in
  let sl2 = sin l2 in
  light.(0) <- cl1 *. sl2;
  let cl2 = cos l2 in
  light.(2) <- cl1 *. cl2;
  beam.(0) <- read_float ()

in

(* ¸µ¤Î2¼¡·Á¼°¹ÔÎó A ¤ËÎ¾Â¦¤«¤é²óÅ¾¹ÔÎó R ¤ò¤«¤±¤¿¹ÔÎó R^t * A * R ¤òºî¤ë *)
(* R ¤Ï x,y,z¼´¤Ë´Ø¤¹¤ë²óÅ¾¹ÔÎó¤ÎÀÑ R(z)R(y)R(x) *)
(* ¥¹¥¯¥ê¡¼¥óºÂÉ¸¤Î¤¿¤á¡¢y¼´²óÅ¾¤Î¤ß³ÑÅÙ¤ÎÉä¹æ¤¬µÕ *)

let rec rotate_quadratic_matrix abc rot =
  (* ²óÅ¾¹ÔÎó¤ÎÀÑ R(z)R(y)R(x) ¤ò·×»»¤¹¤ë *)
  let cos_x = cos rot.(0) in
  let sin_x = sin rot.(0) in
  let cos_y = cos rot.(1) in
  let sin_y = sin rot.(1) in
  let cos_z = cos rot.(2) in
  let sin_z = sin rot.(2) in

  let m00 = cos_y *. cos_z in
  let m01 = sin_x *. sin_y *. cos_z -. cos_x *. sin_z in
  let m02 = cos_x *. sin_y *. cos_z +. sin_x *. sin_z in

  let m10 = cos_y *. sin_z in
  let m11 = sin_x *. sin_y *. sin_z +. cos_x *. cos_z in
  let m12 = cos_x *. sin_y *. sin_z -. sin_x *. cos_z in

  let m20 = fneg sin_y in
  let m21 = sin_x *. cos_y in
  let m22 = cos_x *. cos_y in

  (* a, b, c¤Î¸µ¤ÎÃÍ¤ò¥Ğ¥Ã¥¯¥¢¥Ã¥× *)
  let ao = abc.(0) in
  let bo = abc.(1) in
  let co = abc.(2) in
	 
  (* R^t * A * R ¤ò·×»» *)
	 
  (* X^2, Y^2, Z^2À®Ê¬ *)
  abc.(0) <- ao *. fsqr m00 +. bo *. fsqr m10 +. co *. fsqr m20;
  abc.(1) <- ao *. fsqr m01 +. bo *. fsqr m11 +. co *. fsqr m21;
  abc.(2) <- ao *. fsqr m02 +. bo *. fsqr m12 +. co *. fsqr m22;

  (* ²óÅ¾¤Ë¤è¤Ã¤ÆÀ¸¤¸¤¿ XY, YZ, ZXÀ®Ê¬ *)
  rot.(0) <- 2.0 *. (ao *. m01 *. m02 +. bo *. m11 *. m12 +. co *. m21 *. m22);
  rot.(1) <- 2.0 *. (ao *. m00 *. m02 +. bo *. m10 *. m12 +. co *. m20 *. m22);
  rot.(2) <- 2.0 *. (ao *. m00 *. m01 +. bo *. m10 *. m11 +. co *. m20 *. m21)

in

(**** ¥ª¥Ö¥¸¥§¥¯¥È1¤Ä¤Î¥Ç¡¼¥¿¤ÎÆÉ¤ß¹ş¤ß ****)
let rec read_nth_object n =

  let texture = read_int () in                      
  if texture <> -1 then
    ( 
      let form = read_int () in                     
      let refltype = read_int () in
      let isrot_p = read_int () in

      let abc = Array.create 3 0.0 in
      abc.(0) <- read_float ();
      abc.(1) <- read_float (); (* 5 *)
      abc.(2) <- read_float ();

      let xyz = Array.create 3 0.0 in
      xyz.(0) <- read_float ();
      xyz.(1) <- read_float ();
      xyz.(2) <- read_float ();

      let m_invert = fisneg (read_float ()) in (* 10 *)

      let reflparam = Array.create 2 0.0 in      
      reflparam.(0) <- read_float (); (* diffuse *)
      reflparam.(1) <- read_float (); (* hilight *)
       
      let color = Array.create 3 0.0 in
      color.(0) <- read_float ();
      color.(1) <- read_float ();
      color.(2) <- read_float (); (* 15 *)
     
      let rotation = Array.create 3 0.0 in
      if isrot_p <> 0 then
	(
	 rotation.(0) <- rad (read_float ());
	 rotation.(1) <- rad (read_float ());
	 rotation.(2) <- rad (read_float ())
	) 
      else ();

      (* ¥Ñ¥é¥á¡¼¥¿¤ÎÀµµ¬²½ *)

      (* Ãí: ²¼µ­Àµµ¬²½ (form = 2) »²¾È *)
      let m_invert2 = if form = 2 then true else m_invert in
      let ctbl = Array.create 4 0.0 in
      (* ¤³¤³¤«¤é¤¢¤È¤Ï abc ¤È rotation ¤·¤«Áàºî¤·¤Ê¤¤¡£*)
      let obj = 
	(texture, form, refltype, isrot_p,
	 abc, xyz, (* x-z *)
	 m_invert2,
	 reflparam, (* reflection paramater *)
	 color, (* color *)
	 rotation, (* rotation *)
         ctbl (* constant table *)
	) in
      objects.(n) <- obj;

      if form = 3 then
	(
	  (* 2¼¡¶ÊÌÌ: X,Y,Z ¥µ¥¤¥º¤«¤é2¼¡·Á¼°¹ÔÎó¤ÎÂĞ³ÑÀ®Ê¬¤Ø *)
	 let a = abc.(0) in
	 abc.(0) <- if fiszero a then 0.0 else sgn a /. fsqr a; (* X^2 À®Ê¬ *)
	 let b = abc.(1) in
	 abc.(1) <- if fiszero b then 0.0 else sgn b /. fsqr b; (* Y^2 À®Ê¬ *)
	 let c = abc.(2) in
	 abc.(2) <- if fiszero c then 0.0 else sgn c /. fsqr c  (* Z^2 À®Ê¬ *)
	)
      else if form = 2 then
	(* Ê¿ÌÌ: Ë¡Àş¥Ù¥¯¥È¥ë¤òÀµµ¬²½, ¶ËÀ­¤òÉé¤ËÅı°ì *)
	vecunit_sgn abc (not m_invert)
      else ();

      (* 2¼¡·Á¼°¹ÔÎó¤Ë²óÅ¾ÊÑ´¹¤ò»Ü¤¹ *)
      if isrot_p <> 0 then
	rotate_quadratic_matrix abc rotation
      else ();
      
      true
     )
  else
    false (* ¥Ç¡¼¥¿¤Î½ªÎ» *)
in

(**** ÊªÂÎ¥Ç¡¼¥¿Á´ÂÎ¤ÎÆÉ¤ß¹ş¤ß ****)
let rec read_object n =
  if n < 60 then
    if read_nth_object n then 
      read_object (n + 1) 
    else
      n_objects.(0) <- n
  else () (* failwith "too many objects" *)
in

let rec read_all_object _ =
  read_object 0
in

(**** AND, OR ¥Í¥Ã¥È¥ï¡¼¥¯¤ÎÆÉ¤ß¹ş¤ß ****)

(* ¥Í¥Ã¥È¥ï¡¼¥¯1¤Ä¤òÆÉ¤ß¹ş¤ß¥Ù¥¯¥È¥ë¤Ë¤·¤ÆÊÖ¤¹ *)
let rec read_net_item length =
  let item = read_int () in
  if item = -1 then Array.create (length + 1) (-1)
  else
    let v = read_net_item (length + 1) in
    (v.(length) <- item; v)
in

let rec read_or_network length =
  let net = read_net_item 0 in
  if net.(0) = -1 then 
    Array.create (length + 1) net
  else
    let v = read_or_network (length + 1) in
    (v.(length) <- net; v)
in

let rec read_and_network n =
  let net = read_net_item 0 in
  if net.(0) = -1 then ()
  else (
    and_net.(n) <- net;
    read_and_network (n + 1)
  )
in

let rec read_parameter _ =
  (
   read_screen_settings();
   read_light();
   read_all_object ();
   read_and_network 0;
   or_net.(0) <- read_or_network 0
  )
in

(******************************************************************************
   Ä¾Àş¤È¥ª¥Ö¥¸¥§¥¯¥È¤Î¸òÅÀ¤òµá¤á¤ë´Ø¿ô·² 
 *****************************************************************************)

(* solver : 
   ¥ª¥Ö¥¸¥§¥¯¥È (¤Î index) ¤È¡¢¥Ù¥¯¥È¥ë L, P ¤ò¼õ¤±¤È¤ê¡¢
   Ä¾Àş Lt + P ¤È¡¢¥ª¥Ö¥¸¥§¥¯¥È¤È¤Î¸òÅÀ¤òµá¤á¤ë¡£
   ¸òÅÀ¤¬¤Ê¤¤¾ì¹ç¤Ï 0 ¤ò¡¢¸òÅÀ¤¬¤¢¤ë¾ì¹ç¤Ï¤½¤ì°Ê³°¤òÊÖ¤¹¡£
   ¤³¤ÎÊÖ¤êÃÍ¤Ï nvector ¤Ç¸òÅÀ¤ÎË¡Àş¥Ù¥¯¥È¥ë¤òµá¤á¤ëºİ¤ËÉ¬Í×¡£
   (Ä¾ÊıÂÎ¤Î¾ì¹ç)

   ¸òÅÀ¤ÎºÂÉ¸¤Ï t ¤ÎÃÍ¤È¤·¤Æ solver_dist ¤Ë³ÊÇ¼¤µ¤ì¤ë¡£
*)

(* Ä¾ÊıÂÎ¤Î»ØÄê¤µ¤ì¤¿ÌÌ¤Ë¾×ÆÍ¤¹¤ë¤«¤É¤¦¤«È½Äê¤¹¤ë *)
(* i0 : ÌÌ¤Ë¿âÄ¾¤Ê¼´¤Îindex X:0, Y:1, Z:2         i2,i3¤ÏÂ¾¤Î2¼´¤Îindex *)
let rec solver_rect_surface m dirvec b0 b1 b2 i0 i1 i2  =
  if fiszero dirvec.(i0) then false else
  let abc = o_param_abc m in
  let d = fneg_cond (xor (o_isinvert m) (fisneg dirvec.(i0))) abc.(i0) in
  
  let d2 = (d -. b0) /. dirvec.(i0) in
  if fless (fabs (d2 *. dirvec.(i1) +. b1)) abc.(i1) then
    if fless (fabs (d2 *. dirvec.(i2) +. b2)) abc.(i2) then
      (solver_dist.(0) <- d2; true)
    else false
  else false
in


(***** Ä¾ÊıÂÎ¥ª¥Ö¥¸¥§¥¯¥È¤Î¾ì¹ç ****)
let rec solver_rect m dirvec b0 b1 b2 =
  if      solver_rect_surface m dirvec b0 b1 b2 0 1 2 then 1   (* YZ Ê¿ÌÌ *)
  else if solver_rect_surface m dirvec b1 b2 b0 1 2 0 then 2   (* ZX Ê¿ÌÌ *)
  else if solver_rect_surface m dirvec b2 b0 b1 2 0 1 then 3   (* XY Ê¿ÌÌ *)
  else                                                     0
in


(* Ê¿ÌÌ¥ª¥Ö¥¸¥§¥¯¥È¤Î¾ì¹ç *)
let rec solver_surface m dirvec b0 b1 b2 =
  (* ÅÀ¤ÈÊ¿ÌÌ¤ÎÉä¹æ¤Ä¤­µ÷Î¥ *)
  (* Ê¿ÌÌ¤Ï¶ËÀ­¤¬Éé¤ËÅı°ì¤µ¤ì¤Æ¤¤¤ë *)
  let abc = o_param_abc m in
  let d = veciprod dirvec abc in
  if fispos d then (
    solver_dist.(0) <- fneg (veciprod2 abc b0 b1 b2) /. d;
    1
   ) else 0
in


(* 3ÊÑ¿ô2¼¡·Á¼° v^t A v ¤ò·×»» *)
(* ²óÅ¾¤¬Ìµ¤¤¾ì¹ç¤ÏÂĞ³ÑÉôÊ¬¤Î¤ß·×»»¤¹¤ì¤ĞÎÉ¤¤ *)
let rec quadratic m v0 v1 v2 =
  let diag_part = 
    fsqr v0 *. o_param_a m +. fsqr v1 *. o_param_b m +. fsqr v2 *. o_param_c m
  in
  if o_isrot m = 0 then 
    diag_part
  else
    diag_part
      +. v1 *. v2 *. o_param_r1 m
      +. v2 *. v0 *. o_param_r2 m
      +. v0 *. v1 *. o_param_r3 m
in

(* 3ÊÑ¿ôÁĞ1¼¡·Á¼° v^t A w ¤ò·×»» *)
(* ²óÅ¾¤¬Ìµ¤¤¾ì¹ç¤Ï A ¤ÎÂĞ³ÑÉôÊ¬¤Î¤ß·×»»¤¹¤ì¤ĞÎÉ¤¤ *)
let rec bilinear m v0 v1 v2 w0 w1 w2 =
  let diag_part = 
    v0 *. w0 *. o_param_a m 
      +. v1 *. w1 *. o_param_b m
      +. v2 *. w2 *. o_param_c m
  in
  if o_isrot m = 0 then
    diag_part
  else
    diag_part +. fhalf 
      ((v2 *. w1 +. v1 *. w2) *. o_param_r1 m
	 +. (v0 *. w2 +. v2 *. w0) *. o_param_r2 m
	 +. (v0 *. w1 +. v1 *. w0) *. o_param_r3 m)
in


(* 2¼¡¶ÊÌÌ¤Ş¤¿¤Ï±ß¿í¤Î¾ì¹ç *)
(* 2¼¡·Á¼°¤ÇÉ½¸½¤µ¤ì¤¿¶ÊÌÌ x^t A x - (0 ¤« 1) = 0 ¤È Ä¾Àş base + dirvec*t ¤Î
   ¸òÅÀ¤òµá¤á¤ë¡£¶ÊÀş¤ÎÊıÄø¼°¤Ë x = base + dirvec*t ¤òÂåÆş¤·¤Æt¤òµá¤á¤ë¡£
   ¤Ä¤Ş¤ê (base + dirvec*t)^t A (base + dirvec*t) - (0 ¤« 1) = 0¡¢
   Å¸³«¤¹¤ë¤È (dirvec^t A dirvec)*t^2 + 2*(dirvec^t A base)*t  + 
   (base^t A base) - (0¤«1) = 0 ¡¢¤è¤Ã¤Æt¤Ë´Ø¤¹¤ë2¼¡ÊıÄø¼°¤ò²ò¤±¤ĞÎÉ¤¤¡£*)

let rec solver_second m dirvec b0 b1 b2 =

  (* ²ò¤Î¸ø¼° (-b' ¡Ş sqrt(b'^2 - a*c)) / a  ¤ò»ÈÍÑ(b' = b/2) *)
  (* a = dirvec^t A dirvec *)
  let aa = quadratic m dirvec.(0) dirvec.(1) dirvec.(2) in

  if fiszero aa then 
    0 (* Àµ³Î¤Ë¤Ï¤³¤Î¾ì¹ç¤â1¼¡ÊıÄø¼°¤Î²ò¤¬¤¢¤ë¤¬¡¢Ìµ»ë¤·¤Æ¤âÄÌ¾ï¤ÏÂç¾æÉ× *)
  else (
    
    (* b' = b/2 = dirvec^t A base   *)
    let bb = bilinear m dirvec.(0) dirvec.(1) dirvec.(2) b0 b1 b2 in
    (* c = base^t A base  - (0¤«1)  *)
    let cc0 = quadratic m b0 b1 b2 in
    let cc = if o_form m = 3 then cc0 -. 1.0 else cc0 in
    (* È½ÊÌ¼° *)
    let d = fsqr bb -. aa *. cc in 

    if fispos d then (
      let sd = sqrt d in
      let t1 = if o_isinvert m then sd else fneg sd in
      (solver_dist.(0) <- (t1 -. bb) /.  aa; 1)
     ) 
    else 
      0
   )
in

(**** solver ¤Î¥á¥¤¥ó¥ë¡¼¥Á¥ó ****)
let rec solver index dirvec org =
  let m = objects.(index) in
  (* Ä¾Àş¤Î»ÏÅÀ¤òÊªÂÎ¤Î´ğ½à°ÌÃÖ¤Ë¹ç¤ï¤»¤ÆÊ¿¹Ô°ÜÆ° *)
  let b0 =  org.(0) -. o_param_x m in
  let b1 =  org.(1) -. o_param_y m in
  let b2 =  org.(2) -. o_param_z m in
  let m_shape = o_form m in
  (* ÊªÂÎ¤Î¼ïÎà¤Ë±ş¤¸¤¿Êä½õ´Ø¿ô¤ò¸Æ¤Ö *)
  if m_shape = 1 then       solver_rect m dirvec b0 b1 b2    (* Ä¾ÊıÂÎ *)
  else if m_shape = 2 then  solver_surface m dirvec b0 b1 b2 (* Ê¿ÌÌ *)
  else                      solver_second m dirvec b0 b1 b2  (* 2¼¡¶ÊÌÌ/±ß¿í *)
in

(******************************************************************************
   solver¤Î¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ
 *****************************************************************************)
(*
   ÄÌ¾ïÈÇsolver ¤ÈÆ±ÍÍ¡¢Ä¾Àş start + t * dirvec ¤ÈÊªÂÎ¤Î¸òÅÀ¤ò t ¤ÎÃÍ¤È¤·¤ÆÊÖ¤¹
   t ¤ÎÃÍ¤Ï solver_dist¤Ë³ÊÇ¼
   
   solver_fast ¤Ï¡¢Ä¾Àş¤ÎÊı¸ş¥Ù¥¯¥È¥ë dirvec ¤Ë¤Ä¤¤¤Æºî¤Ã¤¿¥Æ¡¼¥Ö¥ë¤ò»ÈÍÑ
   ÆâÉôÅª¤Ë solver_rect_fast, solver_surface_fast, solver_second_fast¤ò¸Æ¤Ö
   
   solver_fast2 ¤Ï¡¢dirvec¤ÈÄ¾Àş¤Î»ÏÅÀ start ¤½¤ì¤¾¤ì¤Ëºî¤Ã¤¿¥Æ¡¼¥Ö¥ë¤ò»ÈÍÑ
   Ä¾ÊıÂÎ¤Ë¤Ä¤¤¤Æ¤Ïstart¤Î¥Æ¡¼¥Ö¥ë¤Ë¤è¤ë¹âÂ®²½¤Ï¤Ç¤­¤Ê¤¤¤Î¤Ç¡¢solver_fast¤È
   Æ±¤¸¤¯ solver_rect_fast¤òÆâÉôÅª¤Ë¸Æ¤Ö¡£¤½¤ì°Ê³°¤ÎÊªÂÎ¤Ë¤Ä¤¤¤Æ¤Ï
   solver_surface_fast2¤Ş¤¿¤Ïsolver_second_fast2¤òÆâÉôÅª¤Ë¸Æ¤Ö

   ÊÑ¿ôdconst¤ÏÊı¸ş¥Ù¥¯¥È¥ë¡¢sconst¤Ï»ÏÅÀ¤Ë´Ø¤¹¤ë¥Æ¡¼¥Ö¥ë
*)

(***** solver_rect¤Îdirvec¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ ******)
let rec solver_rect_fast m v dconst b0 b1 b2 =
  let d0 = (dconst.(0) -. b0) *. dconst.(1) in
  if  (* YZÊ¿ÌÌ¤È¤Î¾×ÆÍÈ½Äê *)
    if fless (fabs (d0 *. v.(1) +. b1)) (o_param_b m) then
      if fless (fabs (d0 *. v.(2) +. b2)) (o_param_c m) then
	not (fiszero dconst.(1))
      else false
    else false
  then
    (solver_dist.(0) <- d0; 1)
  else let d1 = (dconst.(2) -. b1) *. dconst.(3) in 
  if  (* ZXÊ¿ÌÌ¤È¤Î¾×ÆÍÈ½Äê *)
    if fless (fabs (d1 *. v.(0) +. b0)) (o_param_a m) then
      if fless (fabs (d1 *. v.(2) +. b2)) (o_param_c m) then
	not (fiszero dconst.(3))
      else false
    else false
  then
    (solver_dist.(0) <- d1; 2)
  else let d2 = (dconst.(4) -. b2) *. dconst.(5) in 
  if  (* XYÊ¿ÌÌ¤È¤Î¾×ÆÍÈ½Äê *)
    if fless (fabs (d2 *. v.(0) +. b0)) (o_param_a m) then
      if fless (fabs (d2 *. v.(1) +. b1)) (o_param_b m) then
	not (fiszero dconst.(5))
      else false
    else false
  then
    (solver_dist.(0) <- d2; 3)
  else
    0
in

(**** solver_surface¤Îdirvec¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ ******)
let rec solver_surface_fast m dconst b0 b1 b2 =
  if fisneg dconst.(0) then (
    solver_dist.(0) <- 
      dconst.(1) *. b0 +. dconst.(2) *. b1 +. dconst.(3) *. b2;
    1 
   ) else 0
in

(**** solver_second ¤Îdirvec¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ ******)
let rec solver_second_fast m dconst b0 b1 b2 =
  
  let aa = dconst.(0) in
  if fiszero aa then
    0
  else 
    let neg_bb = dconst.(1) *. b0 +. dconst.(2) *. b1 +. dconst.(3) *. b2 in
    let cc0 = quadratic m b0 b1 b2 in
    let cc = if o_form m = 3 then cc0 -. 1.0 else cc0 in
    let d = (fsqr neg_bb) -. aa *. cc in
    if fispos d then (
      if o_isinvert m then
	solver_dist.(0) <- (neg_bb +. sqrt d) *. dconst.(4)
      else
	solver_dist.(0) <- (neg_bb -. sqrt d) *. dconst.(4);
      1)
    else 0
in

(**** solver ¤Îdirvec¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ *******)
let rec solver_fast index dirvec org =
  let m = objects.(index) in
  let b0 = org.(0) -. o_param_x m in
  let b1 = org.(1) -. o_param_y m in 
  let b2 = org.(2) -. o_param_z m in
  let dconsts = d_const dirvec in
  let dconst = dconsts.(index) in
  let m_shape = o_form m in
  if m_shape = 1 then       
    solver_rect_fast m (d_vec dirvec) dconst b0 b1 b2
  else if m_shape = 2 then  
    solver_surface_fast m dconst b0 b1 b2
  else                      
    solver_second_fast m dconst b0 b1 b2
in




(* solver_surface¤Îdirvec+start¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ *)
let rec solver_surface_fast2 m dconst sconst b0 b1 b2 =
  if fisneg dconst.(0) then (
    solver_dist.(0) <- dconst.(0) *. sconst.(3);
    1 
   ) else 0
in

(* solver_second¤Îdirvec+start¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ *)
let rec solver_second_fast2 m dconst sconst b0 b1 b2 =
  
  let aa = dconst.(0) in
  if fiszero aa then
    0
  else 
    let neg_bb = dconst.(1) *. b0 +. dconst.(2) *. b1 +. dconst.(3) *. b2 in
    let cc = sconst.(3) in
    let d = (fsqr neg_bb) -. aa *. cc in
    if fispos d then (
      if o_isinvert m then
	solver_dist.(0) <- (neg_bb +. sqrt d) *. dconst.(4)
      else
	solver_dist.(0) <- (neg_bb -. sqrt d) *. dconst.(4);
      1)
    else 0
in

(* solver¤Î¡¢dirvec+start¥Æ¡¼¥Ö¥ë»ÈÍÑ¹âÂ®ÈÇ *)
let rec solver_fast2 index dirvec =
  let m = objects.(index) in
  let sconst = o_param_ctbl m in
  let b0 = sconst.(0) in
  let b1 = sconst.(1) in
  let b2 = sconst.(2) in
  let dconsts = d_const dirvec in
  let dconst = dconsts.(index) in
  let m_shape = o_form m in
  if m_shape = 1 then       
    solver_rect_fast m (d_vec dirvec) dconst b0 b1 b2
  else if m_shape = 2 then  
    solver_surface_fast2 m dconst sconst b0 b1 b2
  else                      
    solver_second_fast2 m dconst sconst b0 b1 b2
in

(******************************************************************************
   Êı¸ş¥Ù¥¯¥È¥ë¤ÎÄê¿ô¥Æ¡¼¥Ö¥ë¤ò·×»»¤¹¤ë´Ø¿ô·²
 *****************************************************************************)

(* Ä¾ÊıÂÎ¥ª¥Ö¥¸¥§¥¯¥È¤ËÂĞ¤¹¤ëÁ°½èÍı *)
let rec setup_rect_table vec m = 
  let const = Array.create 6 0.0 in

  if fiszero vec.(0) then (* YZÊ¿ÌÌ *)
    const.(1) <- 0.0
  else (
    (* ÌÌ¤Î X ºÂÉ¸ *)
    const.(0) <- fneg_cond (xor (o_isinvert m) (fisneg vec.(0))) (o_param_a m);
    (* Êı¸ş¥Ù¥¯¥È¥ë¤ò²¿ÇÜ¤¹¤ì¤ĞXÊı¸ş¤Ë1¿Ê¤à¤« *)
    const.(1) <- 1.0 /. vec.(0)
  );
  if fiszero vec.(1) then (* ZXÊ¿ÌÌ : YZÊ¿ÌÌ¤ÈÆ±ÍÍ*)
    const.(3) <- 0.0
  else (
    const.(2) <- fneg_cond (xor (o_isinvert m) (fisneg vec.(1))) (o_param_b m);
    const.(3) <- 1.0 /. vec.(1)
  );
  if fiszero vec.(2) then (* XYÊ¿ÌÌ : YZÊ¿ÌÌ¤ÈÆ±ÍÍ*)
    const.(5) <- 0.0
  else (
    const.(4) <- fneg_cond (xor (o_isinvert m) (fisneg vec.(2))) (o_param_c m);
    const.(5) <- 1.0 /. vec.(2)
  );
  const
in

(* Ê¿ÌÌ¥ª¥Ö¥¸¥§¥¯¥È¤ËÂĞ¤¹¤ëÁ°½èÍı *)
let rec setup_surface_table vec m = 
  let const = Array.create 4 0.0 in
  let d = 
    vec.(0) *. o_param_a m +. vec.(1) *. o_param_b m +. vec.(2) *. o_param_c m
  in
  if fispos d then (
    (* Êı¸ş¥Ù¥¯¥È¥ë¤ò²¿ÇÜ¤¹¤ì¤ĞÊ¿ÌÌ¤Î¿âÄ¾Êı¸ş¤Ë 1 ¿Ê¤à¤« *)
    const.(0) <- -1.0 /. d;
    (* ¤¢¤ëÅÀ¤ÎÊ¿ÌÌ¤«¤é¤Îµ÷Î¥¤¬Êı¸ş¥Ù¥¯¥È¥ë²¿¸ÄÊ¬¤«¤òÆ³¤¯3¼¡°ì·Á¼°¤Î·¸¿ô *)
    const.(1) <- fneg (o_param_a m /. d);
    const.(2) <- fneg (o_param_b m /. d);
    const.(3) <- fneg (o_param_c m /. d)
   ) else
    const.(0) <- 0.0;
  const
 
in

(* 2¼¡¶ÊÌÌ¤ËÂĞ¤¹¤ëÁ°½èÍı *)
let rec setup_second_table v m = 
  let const = Array.create 5 0.0 in
  
  let aa = quadratic m v.(0) v.(1) v.(2) in
  let c1 = fneg (v.(0) *. o_param_a m) in
  let c2 = fneg (v.(1) *. o_param_b m) in
  let c3 = fneg (v.(2) *. o_param_c m) in

  const.(0) <- aa;  (* 2¼¡ÊıÄø¼°¤Î a ·¸¿ô *)

  (* b' = dirvec^t A start ¤À¤¬¡¢(dirvec^t A)¤ÎÉôÊ¬¤ò·×»»¤·const.(1:3)¤Ë³ÊÇ¼¡£
     b' ¤òµá¤á¤ë¤Ë¤Ï¤³¤Î¥Ù¥¯¥È¥ë¤Èstart¤ÎÆâÀÑ¤ò¼è¤ì¤ĞÎÉ¤¤¡£Éä¹æ¤ÏµÕ¤Ë¤¹¤ë *)
  if o_isrot m <> 0 then (
    const.(1) <- c1 -. fhalf (v.(2) *. o_param_r2 m +. v.(1) *. o_param_r3 m);
    const.(2) <- c2 -. fhalf (v.(2) *. o_param_r1 m +. v.(0) *. o_param_r3 m);
    const.(3) <- c3 -. fhalf (v.(1) *. o_param_r1 m +. v.(0) *. o_param_r2 m)
   ) else (
    const.(1) <- c1;
    const.(2) <- c2;
    const.(3) <- c3
   );
  if not (fiszero aa) then
    const.(4) <- 1.0 /. aa (* a·¸¿ô¤ÎµÕ¿ô¤òµá¤á¡¢²ò¤Î¸ø¼°¤Ç¤Î³ä¤ê»»¤ò¾Ãµî *)
  else ();
  const

in

(* ³Æ¥ª¥Ö¥¸¥§¥¯¥È¤Ë¤Ä¤¤¤ÆÊä½õ´Ø¿ô¤ò¸Æ¤ó¤Ç¥Æ¡¼¥Ö¥ë¤òºî¤ë *)
let rec iter_setup_dirvec_constants dirvec index =
  if index >= 0 then (
    let m = objects.(index) in
    let dconst = (d_const dirvec) in
    let v = d_vec dirvec in
    let m_shape = o_form m in
    if m_shape = 1 then  (* rect *)
      dconst.(index) <- setup_rect_table v m
    else if m_shape = 2 then  (* surface *)
      dconst.(index) <- setup_surface_table v m
    else                      (* second *)
      dconst.(index) <- setup_second_table v m;
    
    iter_setup_dirvec_constants dirvec (index - 1)
  ) else ()
in

let rec setup_dirvec_constants dirvec =
  iter_setup_dirvec_constants dirvec (n_objects.(0) - 1)
in

(******************************************************************************
   Ä¾Àş¤Î»ÏÅÀ¤Ë´Ø¤¹¤ë¥Æ¡¼¥Ö¥ë¤ò³Æ¥ª¥Ö¥¸¥§¥¯¥È¤ËÂĞ¤·¤Æ·×»»¤¹¤ë´Ø¿ô·²
 *****************************************************************************)

let rec setup_startp_constants p index =
  if index >= 0 then (
    let obj = objects.(index) in
    let sconst = o_param_ctbl obj in
    let m_shape = o_form obj in
    sconst.(0) <- p.(0) -. o_param_x obj;
    sconst.(1) <- p.(1) -. o_param_y obj;
    sconst.(2) <- p.(2) -. o_param_z obj;
    if m_shape = 2 then (* surface *)
      sconst.(3) <- 
	veciprod2 (o_param_abc obj) sconst.(0) sconst.(1) sconst.(2)
    else if m_shape > 2 then (* second *)
      let cc0 = quadratic obj sconst.(0) sconst.(1) sconst.(2) in
      sconst.(3) <- if m_shape = 3 then cc0 -. 1.0 else cc0
    else ();
    setup_startp_constants p (index - 1)
   ) else ()
in

let rec setup_startp p =
  veccpy startp_fast p;
  setup_startp_constants p (n_objects.(0) - 1)
in

(******************************************************************************
   Í¿¤¨¤é¤ì¤¿ÅÀ¤¬¥ª¥Ö¥¸¥§¥¯¥È¤Ë´Ş¤Ş¤ì¤ë¤«¤É¤¦¤«¤òÈ½Äê¤¹¤ë´Ø¿ô·² 
 *****************************************************************************)

(**** ÅÀ q ¤¬¥ª¥Ö¥¸¥§¥¯¥È m ¤Î³°Éô¤«¤É¤¦¤«¤òÈ½Äê¤¹¤ë ****)

(* Ä¾ÊıÂÎ *)
let rec is_rect_outside m p0 p1 p2 =
  if 
    if (fless (fabs p0) (o_param_a m)) then
      if (fless (fabs p1) (o_param_b m)) then
	fless (fabs p2) (o_param_c m)
      else false
    else false
  then o_isinvert m else not (o_isinvert m)
in

(* Ê¿ÌÌ *)
let rec is_plane_outside m p0 p1 p2 =
  let w = veciprod2 (o_param_abc m) p0 p1 p2 in
  not (xor (o_isinvert m) (fisneg w))
in

(* 2¼¡¶ÊÌÌ *)
let rec is_second_outside m p0 p1 p2 = 
  let w = quadratic m p0 p1 p2 in
  let w2 = if o_form m = 3 then w -. 1.0 else w in
  not (xor (o_isinvert m) (fisneg w2))
in

(* ÊªÂÎ¤ÎÃæ¿´ºÂÉ¸¤ËÊ¿¹Ô°ÜÆ°¤·¤¿¾å¤Ç¡¢Å¬ÀÚ¤ÊÊä½õ´Ø¿ô¤ò¸Æ¤Ö *)
let rec is_outside m q0 q1 q2 =
  let p0 = q0 -. o_param_x m in
  let p1 = q1 -. o_param_y m in
  let p2 = q2 -. o_param_z m in
  let m_shape = o_form m in
  if m_shape = 1 then
    is_rect_outside m p0 p1 p2
  else if m_shape = 2 then
    is_plane_outside m p0 p1 p2
  else 
    is_second_outside m p0 p1 p2
in

(**** ÅÀ q ¤¬ AND ¥Í¥Ã¥È¥ï¡¼¥¯ iand ¤ÎÆâÉô¤Ë¤¢¤ë¤«¤É¤¦¤«¤òÈ½Äê ****)
let rec check_all_inside ofs iand q0 q1 q2 =
  let head = iand.(ofs) in
  if head = -1 then 
    true 
  else (
    if is_outside objects.(head) q0 q1 q2 then 
      false
    else 
      check_all_inside (ofs + 1) iand q0 q1 q2
   )
in

(******************************************************************************
   ¾×ÆÍÅÀ¤¬Â¾¤ÎÊªÂÎ¤Î±Æ¤ËÆş¤Ã¤Æ¤¤¤ë¤«Èİ¤«¤òÈ½Äê¤¹¤ë´Ø¿ô·² 
 *****************************************************************************)

(* ÅÀ intersection_point ¤«¤é¡¢¸÷Àş¥Ù¥¯¥È¥ë¤ÎÊı¸ş¤ËÃ©¤ê¡¢   *)
(* ÊªÂÎ¤Ë¤Ö¤Ä¤«¤ë (=±Æ¤Ë¤Ï¤¤¤Ã¤Æ¤¤¤ë) ¤«Èİ¤«¤òÈ½Äê¤¹¤ë¡£*)

(**** AND ¥Í¥Ã¥È¥ï¡¼¥¯ iand ¤Î±ÆÆâ¤«¤É¤¦¤«¤ÎÈ½Äê ****)
let rec shadow_check_and_group iand_ofs and_group =
  if and_group.(iand_ofs) = -1 then
    false
  else
    let obj = and_group.(iand_ofs) in
    let t0 = solver_fast obj light_dirvec intersection_point in
    let t0p = solver_dist.(0) in
    if (if t0 <> 0 then fless t0p (-0.2) else false) then 
      (* Q: ¸òÅÀ¤Î¸õÊä¡£¼Âºİ¤Ë¤¹¤Ù¤Æ¤Î¥ª¥Ö¥¸¥§¥¯¥È¤Ë *)
      (* Æş¤Ã¤Æ¤¤¤ë¤«¤É¤¦¤«¤òÄ´¤Ù¤ë¡£*)
      let t = t0p +. 0.01 in
      let q0 = light.(0) *. t +. intersection_point.(0) in
      let q1 = light.(1) *. t +. intersection_point.(1) in
      let q2 = light.(2) *. t +. intersection_point.(2) in
      if check_all_inside 0 and_group q0 q1 q2 then
	true 
      else 
	shadow_check_and_group (iand_ofs + 1) and_group 
	  (* ¼¡¤Î¥ª¥Ö¥¸¥§¥¯¥È¤«¤é¸õÊäÅÀ¤òÃµ¤¹ *)
    else
      (* ¸òÅÀ¤¬¤Ê¤¤¾ì¹ç: ¶ËÀ­¤¬Àµ(ÆâÂ¦¤¬¿¿)¤Î¾ì¹ç¡¢    *)
      (* AND ¥Í¥Ã¥È¤Î¶¦ÄÌÉôÊ¬¤Ï¤½¤ÎÆâÉô¤Ë´Ş¤Ş¤ì¤ë¤¿¤á¡¢*)
      (* ¸òÅÀ¤Ï¤Ê¤¤¤³¤È¤Ï¼«ÌÀ¡£Ãµº÷¤òÂÇ¤ÁÀÚ¤ë¡£        *)
      if o_isinvert (objects.(obj)) then 
	shadow_check_and_group (iand_ofs + 1) and_group
      else 
	false
in

(**** OR ¥°¥ë¡¼¥× or_group ¤Î±Æ¤«¤É¤¦¤«¤ÎÈ½Äê ****)
let rec shadow_check_one_or_group ofs or_group =
  let head = or_group.(ofs) in
  if head = -1 then
    false
  else (
    let and_group = and_net.(head) in
    let shadow_p = shadow_check_and_group 0 and_group in
    if shadow_p then
      true
    else 
      shadow_check_one_or_group (ofs + 1) or_group
   )
in

(**** OR ¥°¥ë¡¼¥×¤ÎÎó¤Î¤É¤ì¤«¤Î±Æ¤ËÆş¤Ã¤Æ¤¤¤ë¤«¤É¤¦¤«¤ÎÈ½Äê ****)
let rec shadow_check_one_or_matrix ofs or_matrix =
  let head = or_matrix.(ofs) in
  let range_primitive = head.(0) in
  if range_primitive = -1 then (* OR¹ÔÎó¤Î½ªÎ»¥Ş¡¼¥¯ *)
    false 
  else
    if (* range primitive ¤¬Ìµ¤¤¤«¡¢¤Ş¤¿¤Ïrange_primitive¤È¸ò¤ï¤ë»ö¤ò³ÎÇ§ *)
      if range_primitive = 99 then      (* range primitive ¤¬Ìµ¤¤ *)
	true
      else              (* range_primitive¤¬¤¢¤ë *)
	let t = solver_fast range_primitive light_dirvec intersection_point in
        (* range primitive ¤È¤Ö¤Ä¤«¤é¤Ê¤±¤ì¤Ğ *)
        (* or group ¤È¤Î¸òÅÀ¤Ï¤Ê¤¤            *)
	if t <> 0 then
          if fless solver_dist.(0) (-0.1) then
            if shadow_check_one_or_group 1 head then
              true
	    else false
	  else false
	else false
    then
      if (shadow_check_one_or_group 1 head) then 
	true (* ¸òÅÀ¤¬¤¢¤ë¤Î¤Ç¡¢±Æ¤ËÆş¤ë»ö¤¬È½ÌÀ¡£Ãµº÷½ªÎ» *)
      else 
	shadow_check_one_or_matrix (ofs + 1) or_matrix (* ¼¡¤ÎÍ×ÁÇ¤ò»î¤¹ *)
    else 
      shadow_check_one_or_matrix (ofs + 1) or_matrix (* ¼¡¤ÎÍ×ÁÇ¤ò»î¤¹ *)
	
in

(******************************************************************************
   ¸÷Àş¤ÈÊªÂÎ¤Î¸òº¹È½Äê
 *****************************************************************************)

(**** ¤¢¤ëAND¥Í¥Ã¥È¥ï¡¼¥¯¤¬¡¢¥ì¥¤¥È¥ì¡¼¥¹¤ÎÊı¸ş¤ËÂĞ¤·¡¢****)
(**** ¸òÅÀ¤¬¤¢¤ë¤«¤É¤¦¤«¤òÄ´¤Ù¤ë¡£                     ****)
let rec solve_each_element iand_ofs and_group dirvec =
  let iobj = and_group.(iand_ofs) in
  if iobj = -1 then ()
  else (
    let t0 = solver iobj dirvec startp in
    if t0 <> 0 then
      (
       (* ¸òÅÀ¤¬¤¢¤ë»ş¤Ï¡¢¤½¤Î¸òÅÀ¤¬Â¾¤ÎÍ×ÁÇ¤ÎÃæ¤Ë´Ş¤Ş¤ì¤ë¤«¤É¤¦¤«Ä´¤Ù¤ë¡£*)
       (* º£¤Ş¤Ç¤ÎÃæ¤ÇºÇ¾®¤Î t ¤ÎÃÍ¤ÈÈæ¤Ù¤ë¡£*)
       let t0p = solver_dist.(0) in

       if (fless 0.0 t0p) then
	 if (fless t0p tmin.(0)) then
	   (
	    let t = t0p +. 0.01 in
	    let q0 = dirvec.(0) *. t +. startp.(0) in
	    let q1 = dirvec.(1) *. t +. startp.(1) in
	    let q2 = dirvec.(2) *. t +. startp.(2) in
	    if check_all_inside 0 and_group q0 q1 q2 then 
	      ( 
		tmin.(0) <- t;
		vecset intersection_point q0 q1 q2;
		intersected_object_id.(0) <- iobj;
		intsec_rectside.(0) <- t0
	       )
	    else ()
	   )
	 else ()
       else ();
       solve_each_element (iand_ofs + 1) and_group dirvec 
      )
    else
      (* ¸òÅÀ¤¬¤Ê¤¯¡¢¤·¤«¤â¤½¤ÎÊªÂÎ¤ÏÆâÂ¦¤¬¿¿¤Ê¤é¤³¤ì°Ê¾å¸òÅÀ¤Ï¤Ê¤¤ *)
      if o_isinvert (objects.(iobj)) then 
	solve_each_element (iand_ofs + 1) and_group dirvec
      else ()
	  
   )
in

(**** 1¤Ä¤Î OR-group ¤Ë¤Ä¤¤¤Æ¸òÅÀ¤òÄ´¤Ù¤ë ****)
let rec solve_one_or_network ofs or_group dirvec =
  let head = or_group.(ofs) in
  if head <> -1 then (
    let and_group = and_net.(head) in
    solve_each_element 0 and_group dirvec;
    solve_one_or_network (ofs + 1) or_group dirvec
   ) else ()
in

(**** OR¥Ş¥È¥ê¥¯¥¹Á´ÂÎ¤Ë¤Ä¤¤¤Æ¸òÅÀ¤òÄ´¤Ù¤ë¡£****)
let rec trace_or_matrix ofs or_network dirvec =
  let head = or_network.(ofs) in
  let range_primitive = head.(0) in
  if range_primitive = -1 then (* Á´¥ª¥Ö¥¸¥§¥¯¥È½ªÎ» *)
    ()
  else ( 
    if range_primitive = 99 (* range primitive ¤Ê¤· *)
    then (solve_one_or_network 1 head dirvec)
    else 
      (
	(* range primitive ¤Î¾×ÆÍ¤·¤Ê¤±¤ì¤Ğ¸òÅÀ¤Ï¤Ê¤¤ *)
       let t = solver range_primitive dirvec startp in
       if t <> 0 then
	 let tp = solver_dist.(0) in
	 if fless tp tmin.(0)
	 then (solve_one_or_network 1 head dirvec)
	 else ()
       else ()
      );
    trace_or_matrix (ofs + 1) or_network dirvec
  )
in

(**** ¥È¥ì¡¼¥¹ËÜÂÎ ****)
(* ¥È¥ì¡¼¥¹³«»ÏÅÀ ViewPoint ¤È¡¢¤½¤ÎÅÀ¤«¤é¤Î¥¹¥­¥ã¥óÊı¸ş¥Ù¥¯¥È¥ë *)
(* Vscan ¤«¤é¡¢¸òÅÀ crashed_point ¤È¾×ÆÍ¤·¤¿¥ª¥Ö¥¸¥§¥¯¥È         *)
(* crashed_object ¤òÊÖ¤¹¡£´Ø¿ô¼«ÂÎ¤ÎÊÖ¤êÃÍ¤Ï¸òÅÀ¤ÎÍ­Ìµ¤Î¿¿µ¶ÃÍ¡£ *)
let rec judge_intersection dirvec = (
  tmin.(0) <- (1000000000.0);
  trace_or_matrix 0 (or_net.(0)) dirvec;
  let t = tmin.(0) in

  if (fless (-0.1) t) then
    (fless t 100000000.0)
  else false
 )
in

(******************************************************************************
   ¸÷Àş¤ÈÊªÂÎ¤Î¸òº¹È½Äê ¹âÂ®ÈÇ
 *****************************************************************************)

let rec solve_each_element_fast iand_ofs and_group dirvec =
  let vec = (d_vec dirvec) in
  let iobj = and_group.(iand_ofs) in
  if iobj = -1 then ()
  else (
    let t0 = solver_fast2 iobj dirvec in
    if t0 <> 0 then
      (
        (* ¸òÅÀ¤¬¤¢¤ë»ş¤Ï¡¢¤½¤Î¸òÅÀ¤¬Â¾¤ÎÍ×ÁÇ¤ÎÃæ¤Ë´Ş¤Ş¤ì¤ë¤«¤É¤¦¤«Ä´¤Ù¤ë¡£*)
        (* º£¤Ş¤Ç¤ÎÃæ¤ÇºÇ¾®¤Î t ¤ÎÃÍ¤ÈÈæ¤Ù¤ë¡£*)
       let t0p = solver_dist.(0) in

       if (fless 0.0 t0p) then
	 if (fless t0p tmin.(0)) then
	   (
	    let t = t0p +. 0.01 in
	    let q0 = vec.(0) *. t +. startp_fast.(0) in
	    let q1 = vec.(1) *. t +. startp_fast.(1) in
	    let q2 = vec.(2) *. t +. startp_fast.(2) in
	    if check_all_inside 0 and_group q0 q1 q2 then 
	      ( 
		tmin.(0) <- t;
		vecset intersection_point q0 q1 q2;
		intersected_object_id.(0) <- iobj;
		intsec_rectside.(0) <- t0
	       )
	    else ()
	   )
	 else ()
       else ();
       solve_each_element_fast (iand_ofs + 1) and_group dirvec
      )
    else 
       (* ¸òÅÀ¤¬¤Ê¤¯¡¢¤·¤«¤â¤½¤ÎÊªÂÎ¤ÏÆâÂ¦¤¬¿¿¤Ê¤é¤³¤ì°Ê¾å¸òÅÀ¤Ï¤Ê¤¤ *)
       if o_isinvert (objects.(iobj)) then 
	 solve_each_element_fast (iand_ofs + 1) and_group dirvec
       else ()
   )   
in

(**** 1¤Ä¤Î OR-group ¤Ë¤Ä¤¤¤Æ¸òÅÀ¤òÄ´¤Ù¤ë ****)
let rec solve_one_or_network_fast ofs or_group dirvec =
  let head = or_group.(ofs) in
  if head <> -1 then (
    let and_group = and_net.(head) in
    solve_each_element_fast 0 and_group dirvec;
    solve_one_or_network_fast (ofs + 1) or_group dirvec
   ) else ()
in

(**** OR¥Ş¥È¥ê¥¯¥¹Á´ÂÎ¤Ë¤Ä¤¤¤Æ¸òÅÀ¤òÄ´¤Ù¤ë¡£****)
let rec trace_or_matrix_fast ofs or_network dirvec =
  let head = or_network.(ofs) in
  let range_primitive = head.(0) in
  if range_primitive = -1 then (* Á´¥ª¥Ö¥¸¥§¥¯¥È½ªÎ» *)
    ()
  else ( 
    if range_primitive = 99 (* range primitive ¤Ê¤· *)
    then solve_one_or_network_fast 1 head dirvec
    else 
      (
	(* range primitive ¤Î¾×ÆÍ¤·¤Ê¤±¤ì¤Ğ¸òÅÀ¤Ï¤Ê¤¤ *)
       let t = solver_fast2 range_primitive dirvec in
       if t <> 0 then
	 let tp = solver_dist.(0) in
	 if fless tp tmin.(0)
	 then (solve_one_or_network_fast 1 head dirvec)
	 else ()
       else ()
      );
    trace_or_matrix_fast (ofs + 1) or_network dirvec
   )
in

(**** ¥È¥ì¡¼¥¹ËÜÂÎ ****)
let rec judge_intersection_fast dirvec =
( 
  tmin.(0) <- (1000000000.0);
  trace_or_matrix_fast 0 (or_net.(0)) dirvec;
  let t = tmin.(0) in

  if (fless (-0.1) t) then
    (fless t 100000000.0)
  else false
)
in

(******************************************************************************
   ÊªÂÎ¤È¸÷¤Î¸òº¹ÅÀ¤ÎË¡Àş¥Ù¥¯¥È¥ë¤òµá¤á¤ë´Ø¿ô
 *****************************************************************************)

(**** ¸òÅÀ¤«¤éË¡Àş¥Ù¥¯¥È¥ë¤ò·×»»¤¹¤ë ****)
(* ¾×ÆÍ¤·¤¿¥ª¥Ö¥¸¥§¥¯¥È¤òµá¤á¤¿ºİ¤Î solver ¤ÎÊÖ¤êÃÍ¤ò *)
(* ÊÑ¿ô intsec_rectside ·ĞÍ³¤ÇÅÏ¤·¤Æ¤ä¤ëÉ¬Í×¤¬¤¢¤ë¡£  *)
(* nvector ¤â¥°¥í¡¼¥Ğ¥ë¡£ *)

let rec get_nvector_rect dirvec =
  let rectside = intsec_rectside.(0) in
  (* solver ¤ÎÊÖ¤êÃÍ¤Ï¤Ö¤Ä¤«¤Ã¤¿ÌÌ¤ÎÊı¸ş¤ò¼¨¤¹ *)
  vecbzero nvector;
  nvector.(rectside-1) <- fneg (sgn (dirvec.(rectside-1)))
in

(* Ê¿ÌÌ *)
let rec get_nvector_plane m = 
  (* m_invert ¤Ï¾ï¤Ë true ¤Î¤Ï¤º *)
  nvector.(0) <- fneg (o_param_a m); (* if m_invert then fneg m_a else m_a *)
  nvector.(1) <- fneg (o_param_b m);
  nvector.(2) <- fneg (o_param_c m)
in

(* 2¼¡¶ÊÌÌ :  grad x^t A x = 2 A x ¤òÀµµ¬²½¤¹¤ë *)
let rec get_nvector_second m =
  let p0 = intersection_point.(0) -. o_param_x m in
  let p1 = intersection_point.(1) -. o_param_y m in
  let p2 = intersection_point.(2) -. o_param_z m in

  let d0 = p0 *. o_param_a m in
  let d1 = p1 *. o_param_b m in
  let d2 = p2 *. o_param_c m in

  if o_isrot m = 0 then (
    nvector.(0) <- d0;
    nvector.(1) <- d1;
    nvector.(2) <- d2
   ) else (
    nvector.(0) <- d0 +. fhalf (p1 *. o_param_r3 m +. p2 *. o_param_r2 m);
    nvector.(1) <- d1 +. fhalf (p0 *. o_param_r3 m +. p2 *. o_param_r1 m);
    nvector.(2) <- d2 +. fhalf (p0 *. o_param_r2 m +. p1 *. o_param_r1 m)
   );
  vecunit_sgn nvector (o_isinvert m)

in

let rec get_nvector m dirvec =
  let m_shape = o_form m in
  if m_shape = 1 then
    get_nvector_rect dirvec
  else if m_shape = 2 then
    get_nvector_plane m
  else (* 2¼¡¶ÊÌÌ or ¿íÂÎ *)
    get_nvector_second m
  (* retval = nvector *)
in

(******************************************************************************
   ÊªÂÎÉ½ÌÌ¤Î¿§(¿§ÉÕ¤­³È»¶È¿¼ÍÎ¨)¤òµá¤á¤ë
 *****************************************************************************)

(**** ¸òÅÀ¾å¤Î¥Æ¥¯¥¹¥Á¥ã¤Î¿§¤ò·×»»¤¹¤ë ****)
let rec utexture m p =
  let m_tex = o_texturetype m in
  (* ´ğËÜ¤Ï¥ª¥Ö¥¸¥§¥¯¥È¤Î¿§ *)
  texture_color.(0) <- o_color_red m;
  texture_color.(1) <- o_color_green m;
  texture_color.(2) <- o_color_blue m;
  if m_tex = 1 then
    (
     (* zxÊı¸ş¤Î¥Á¥§¥Ã¥«¡¼ÌÏÍÍ (G) *)
     let w1 = p.(0) -. o_param_x m in
     let flag1 =
       let d1 = (floor (w1 *. 0.05)) *. 20.0 in
      fless (w1 -. d1) 10.0
     in
     let w3 = p.(2) -. o_param_z m in
     let flag2 =
       let d2 = (floor (w3 *. 0.05)) *. 20.0 in
       fless (w3 -. d2) 10.0 
     in
     texture_color.(1) <-
       if flag1 
       then (if flag2 then 255.0 else 0.0)
       else (if flag2 then 0.0 else 255.0)
    )
  else if m_tex = 2 then
    (* y¼´Êı¸ş¤Î¥¹¥È¥é¥¤¥× (R-G) *)
    (
      let w2 = fsqr (sin (p.(1) *. 0.25)) in
      texture_color.(0) <- 255.0 *. w2;
      texture_color.(1) <- 255.0 *. (1.0 -. w2)
    )
  else if m_tex = 3 then 
    (* ZXÌÌÊı¸ş¤ÎÆ±¿´±ß (G-B) *)
    ( 
      let w1 = p.(0) -. o_param_x m in
      let w3 = p.(2) -. o_param_z m in
      let w2 = sqrt (fsqr w1 +. fsqr w3) /. 10.0 in
      let w4 =  (w2 -. floor w2) *. 3.1415927 in
      let cws = fsqr (cos w4) in
      texture_color.(1) <- cws *. 255.0;
      texture_color.(2) <- (1.0 -. cws) *. 255.0
    )
  else if m_tex = 4 then (
    (* µåÌÌ¾å¤ÎÈÃÅÀ (B) *)
    let w1 = (p.(0) -. o_param_x m) *. (sqrt (o_param_a m)) in
    let w3 = (p.(2) -. o_param_z m) *. (sqrt (o_param_c m)) in
    let w4 = (fsqr w1) +. (fsqr w3) in
    let w7 = 
      if fless (fabs w1) 1.0e-4 then
	15.0 (* atan +infty = pi/2 *)
      else
	let w5 = fabs (w3 /. w1)
	in
	((atan w5) *. 30.0) /. 3.1415927 
    in
    let w9 = w7 -. (floor w7) in

    let w2 = (p.(1) -. o_param_y m) *. (sqrt (o_param_b m)) in
    let w8 =
      if fless (fabs w4) 1.0e-4 then
	15.0
      else 
	let w6 = fabs (w2 /. w4)
	in ((atan w6) *. 30.0) /. 3.1415927 
    in
    let w10 = w8 -. (floor w8) in
    let w11 = 0.15 -. (fsqr (0.5 -. w9)) -. (fsqr (0.5 -. w10)) in
    let w12 = if fisneg w11 then 0.0 else w11 in
    texture_color.(2) <- (255.0 *. w12) /. 0.3
   )
  else ()
in

(******************************************************************************
   ¾×ÆÍÅÀ¤ËÅö¤¿¤ë¸÷¸»¤ÎÄ¾ÀÜ¸÷¤ÈÈ¿¼Í¸÷¤ò·×»»¤¹¤ë´Ø¿ô·² 
 *****************************************************************************)

(* Åö¤¿¤Ã¤¿¸÷¤Ë¤è¤ë³È»¶¸÷¤ÈÉÔ´°Á´¶ÀÌÌÈ¿¼Í¸÷¤Ë¤è¤ë´óÍ¿¤òRGBÃÍ¤Ë²Ã»» *)
let rec add_light bright hilight hilight_scale =

  (* ³È»¶¸÷ *)
  if fispos bright then
    vecaccum rgb bright texture_color
  else ();

  (* ÉÔ´°Á´¶ÀÌÌÈ¿¼Í cos ^4 ¥â¥Ç¥ë *)
  if fispos hilight then (
    let ihl = fsqr (fsqr hilight) *. hilight_scale in
    rgb.(0) <- rgb.(0) +. ihl;
    rgb.(1) <- rgb.(1) +. ihl;
    rgb.(2) <- rgb.(2) +. ihl
  ) else ()
in

(* ³ÆÊªÂÎ¤Ë¤è¤ë¸÷¸»¤ÎÈ¿¼Í¸÷¤ò·×»»¤¹¤ë´Ø¿ô(Ä¾ÊıÂÎ¤ÈÊ¿ÌÌ¤Î¤ß) *)
let rec trace_reflections index diffuse hilight_scale dirvec =

  if index >= 0 then (
    let rinfo = reflections.(index) in (* ¶ÀÊ¿ÌÌ¤ÎÈ¿¼Í¾ğÊó *)
    let dvec = r_dvec rinfo in    (* È¿¼Í¸÷¤ÎÊı¸ş¥Ù¥¯¥È¥ë(¸÷¤ÈµÕ¸ş¤­ *)

    (*È¿¼Í¸÷¤òµÕ¤Ë¤¿¤É¤ê¡¢¼Âºİ¤Ë¤½¤Î¶ÀÌÌ¤ËÅö¤¿¤ì¤Ğ¡¢È¿¼Í¸÷¤¬ÆÏ¤¯²ÄÇ½À­Í­¤ê *)
    if judge_intersection_fast dvec then
      let surface_id = intersected_object_id.(0) * 4 + intsec_rectside.(0) in
      if surface_id = r_surface_id rinfo then
	(* ¶ÀÌÌ¤È¤Î¾×ÆÍÅÀ¤¬¸÷¸»¤Î±Æ¤Ë¤Ê¤Ã¤Æ¤¤¤Ê¤±¤ì¤ĞÈ¿¼Í¸÷¤ÏÆÏ¤¯ *)
        if not (shadow_check_one_or_matrix 0 or_net.(0)) then
	  (* ÆÏ¤¤¤¿È¿¼Í¸÷¤Ë¤è¤ë RGBÀ®Ê¬¤Ø¤Î´óÍ¿¤ò²Ã»» *)
          let p = veciprod nvector (d_vec dvec) in
          let scale = r_bright rinfo in
          let bright = scale *. diffuse *. p in
          let hilight = scale *. veciprod dirvec (d_vec dvec) in
          add_light bright hilight hilight_scale
        else ()
      else ()
    else ();
    trace_reflections (index - 1) diffuse hilight_scale dirvec
  ) else ()

in

(******************************************************************************
   Ä¾ÀÜ¸÷¤òÄÉÀ×¤¹¤ë
 *****************************************************************************)
let rec trace_ray nref energy dirvec pixel dist =
  if nref <= 4 then (
    let surface_ids = p_surface_ids pixel in
    if judge_intersection dirvec then (
    (* ¥ª¥Ö¥¸¥§¥¯¥È¤Ë¤Ö¤Ä¤«¤Ã¤¿¾ì¹ç *)
      let obj_id = intersected_object_id.(0) in
      let obj = objects.(obj_id) in
      let m_surface = o_reflectiontype obj in
      let diffuse = o_diffuse obj *. energy in

      get_nvector obj dirvec; (* Ë¡Àş¥Ù¥¯¥È¥ë¤ò get *)
      veccpy startp intersection_point;  (* ¸òº¹ÅÀ¤ò¿·¤¿¤Ê¸÷¤ÎÈ¯¼ÍÅÀ¤È¤¹¤ë *)
      utexture obj intersection_point; (*¥Æ¥¯¥¹¥Á¥ã¤ò·×»» *)
      
      (* pixel tuple¤Ë¾ğÊó¤ò³ÊÇ¼¤¹¤ë *)
      surface_ids.(nref) <- obj_id * 4 + intsec_rectside.(0);
      let intersection_points = p_intersection_points pixel in
      veccpy intersection_points.(nref) intersection_point;
      
      (* ³È»¶È¿¼ÍÎ¨¤¬0.5°Ê¾å¤Î¾ì¹ç¤Î¤ß´ÖÀÜ¸÷¤Î¥µ¥ó¥×¥ê¥ó¥°¤ò¹Ô¤¦ *)
      let calc_diffuse = p_calc_diffuse pixel in
      if fless (o_diffuse obj) 0.5 then 
	calc_diffuse.(nref) <- false
      else (
	calc_diffuse.(nref) <- true;
	let energya = p_energy pixel in
	veccpy energya.(nref) texture_color;
	vecscale energya.(nref) ((1.0 /. 256.0) *. diffuse);
	let nvectors = p_nvectors pixel in
	veccpy nvectors.(nref) nvector
       );

      let w = (-2.0) *. veciprod dirvec nvector in
      (* È¿¼Í¸÷¤ÎÊı¸ş¤Ë¥È¥ì¡¼¥¹Êı¸ş¤òÊÑ¹¹ *)
      vecaccum dirvec w nvector;

      let hilight_scale = energy *. o_hilight obj in

      (* ¸÷¸»¸÷¤¬Ä¾ÀÜÆÏ¤¯¾ì¹ç¡¢RGBÀ®Ê¬¤Ë¤³¤ì¤ò²ÃÌ£¤¹¤ë *)
      if not (shadow_check_one_or_matrix 0 or_net.(0)) then
        let bright = fneg (veciprod nvector light) *. diffuse in
        let hilight = fneg (veciprod dirvec light) in
        add_light bright hilight hilight_scale
      else ();

      (* ¸÷¸»¸÷¤ÎÈ¿¼Í¸÷¤¬Ìµ¤¤¤«Ãµ¤¹ *)
      setup_startp intersection_point;
      trace_reflections (n_reflections.(0)-1) diffuse hilight_scale dirvec;

      (* ½Å¤ß¤¬ 0.1¤è¤êÂ¿¤¯»Ä¤Ã¤Æ¤¤¤¿¤é¡¢¶ÀÌÌÈ¿¼Í¸µ¤òÄÉÀ×¤¹¤ë *)
      if fless 0.1 energy then ( 
	
	if(nref < 4) then
	  surface_ids.(nref+1) <- -1
	else ();
	
	if m_surface = 2 then (   (* ´°Á´¶ÀÌÌÈ¿¼Í *)
	  let energy2 = energy *. (1.0 -. o_diffuse obj) in
	  trace_ray (nref+1) energy2 dirvec pixel (dist +. tmin.(0))
	 ) else ()
	
       ) else ()
      
     ) else ( 
      (* ¤É¤ÎÊªÂÎ¤Ë¤âÅö¤¿¤é¤Ê¤«¤Ã¤¿¾ì¹ç¡£¸÷¸»¤«¤é¤Î¸÷¤ò²ÃÌ£ *)

      surface_ids.(nref) <- -1;

      if nref <> 0 then (
	let hl = fneg (veciprod dirvec light) in
        (* 90¡ë¤òÄ¶¤¨¤ë¾ì¹ç¤Ï0 (¸÷¤Ê¤·) *)
	if fispos hl then
	  (
	   (* ¥Ï¥¤¥é¥¤¥È¶¯ÅÙ¤Ï³ÑÅÙ¤Î cos^3 ¤ËÈæÎã *)
	   let ihl = fsqr hl *. hl *. energy *. beam.(0) in
	   rgb.(0) <- rgb.(0) +. ihl;
	   rgb.(1) <- rgb.(1) +. ihl;
	   rgb.(2) <- rgb.(2) +. ihl
          )
	else ()
       ) else ()
     )
   ) else ()
in


(******************************************************************************
   ´ÖÀÜ¸÷¤òÄÉÀ×¤¹¤ë
 *****************************************************************************)

(* ¤¢¤ëÅÀ¤¬ÆÃÄê¤ÎÊı¸ş¤«¤é¼õ¤±¤ë´ÖÀÜ¸÷¤Î¶¯¤µ¤ò·×»»¤¹¤ë *)
(* ´ÖÀÜ¸÷¤ÎÊı¸ş¥Ù¥¯¥È¥ë dirvec¤Ë´Ø¤·¤Æ¤ÏÄê¿ô¥Æ¡¼¥Ö¥ë¤¬ºî¤é¤ì¤Æ¤ª¤ê¡¢¾×ÆÍÈ½Äê
   ¤¬¹âÂ®¤Ë¹Ô¤ï¤ì¤ë¡£ÊªÂÎ¤ËÅö¤¿¤Ã¤¿¤é¡¢¤½¤Î¸å¤ÎÈ¿¼Í¤ÏÄÉÀ×¤·¤Ê¤¤ *)
let rec trace_diffuse_ray dirvec energy =
 
  (* ¤É¤ì¤«¤ÎÊªÂÎ¤ËÅö¤¿¤ë¤«Ä´¤Ù¤ë *)
  if judge_intersection_fast dirvec then
    let obj = objects.(intersected_object_id.(0)) in
    get_nvector obj (d_vec dirvec); 
    utexture obj intersection_point;      

    (* ¤½¤ÎÊªÂÎ¤¬Êü¼Í¤¹¤ë¸÷¤Î¶¯¤µ¤òµá¤á¤ë¡£Ä¾ÀÜ¸÷¸»¸÷¤Î¤ß¤ò·×»» *)
    if not (shadow_check_one_or_matrix 0 or_net.(0)) then 
      let br =  fneg (veciprod nvector light) in
      let bright = (if fispos br then br else 0.0) in
      vecaccum diffuse_ray (energy *. bright *. o_diffuse obj) texture_color
    else ()
  else ()
in

(* ¤¢¤é¤«¤¸¤á·è¤á¤é¤ì¤¿Êı¸ş¥Ù¥¯¥È¥ë¤ÎÇÛÎó¤ËÂĞ¤·¡¢³Æ¥Ù¥¯¥È¥ë¤ÎÊı³Ñ¤«¤éÍè¤ë
   ´ÖÀÜ¸÷¤Î¶¯¤µ¤ò¥µ¥ó¥×¥ê¥ó¥°¤·¤Æ²Ã»»¤¹¤ë *)
let rec iter_trace_diffuse_rays dirvec_group nvector org index = 
  if index >= 0 then (
    let p = veciprod (d_vec dirvec_group.(index)) nvector in

    (* ÇÛÎó¤Î 2n ÈÖÌÜ¤È 2n+1 ÈÖÌÜ¤Ë¤Ï¸ß¤¤¤ËµÕ¸ş¤ÎÊı¸ş¥Ù¥¯¥È¥ë¤¬Æş¤Ã¤Æ¤¤¤ë
       Ë¡Àş¥Ù¥¯¥È¥ë¤ÈÆ±¤¸¸ş¤­¤ÎÊª¤òÁª¤ó¤Ç»È¤¦ *)
    if fisneg p then
      trace_diffuse_ray dirvec_group.(index + 1) (p /. -150.0)
    else 
      trace_diffuse_ray dirvec_group.(index) (p /. 150.0);
	
    iter_trace_diffuse_rays dirvec_group nvector org (index - 2)
   ) else ()
in

(* Í¿¤¨¤é¤ì¤¿Êı¸ş¥Ù¥¯¥È¥ë¤Î½¸¹ç¤ËÂĞ¤·¡¢¤½¤ÎÊı¸ş¤Î´ÖÀÜ¸÷¤ò¥µ¥ó¥×¥ê¥ó¥°¤¹¤ë *)
let rec trace_diffuse_rays dirvec_group nvector org =
  setup_startp org;
  (* ÇÛÎó¤Î 2n ÈÖÌÜ¤È 2n+1 ÈÖÌÜ¤Ë¤Ï¸ß¤¤¤ËµÕ¸ş¤ÎÊı¸ş¥Ù¥¯¥È¥ë¤¬Æş¤Ã¤Æ¤¤¤Æ¡¢
     Ë¡Àş¥Ù¥¯¥È¥ë¤ÈÆ±¤¸¸ş¤­¤ÎÊª¤Î¤ß¥µ¥ó¥×¥ê¥ó¥°¤Ë»È¤ï¤ì¤ë *)
  (* Á´Éô¤Ç 120 / 2 = 60ËÜ¤Î¥Ù¥¯¥È¥ë¤òÄÉÀ× *)
  iter_trace_diffuse_rays dirvec_group nvector org 118
in

(* È¾µåÊı¸ş¤ÎÁ´Éô¤Ç300ËÜ¤Î¥Ù¥¯¥È¥ë¤Î¤¦¤Á¡¢¤Ş¤ÀÄÉÀ×¤·¤Æ¤¤¤Ê¤¤»Ä¤ê¤Î240ËÜ¤Î
   ¥Ù¥¯¥È¥ë¤Ë¤Ä¤¤¤Æ´ÖÀÜ¸÷ÄÉÀ×¤¹¤ë¡£60ËÜ¤Î¥Ù¥¯¥È¥ëÄÉÀ×¤ò4¥»¥Ã¥È¹Ô¤¦ *)
let rec trace_diffuse_ray_80percent group_id nvector org = 

  if group_id <> 0 then 
    trace_diffuse_rays dirvecs.(0) nvector org
  else ();

  if group_id <> 1 then
    trace_diffuse_rays dirvecs.(1) nvector org
  else ();
  
  if group_id <> 2 then
    trace_diffuse_rays dirvecs.(2) nvector org
  else ();
  
  if group_id <> 3 then
    trace_diffuse_rays dirvecs.(3) nvector org
  else ();
  
  if group_id <> 4 then
    trace_diffuse_rays dirvecs.(4) nvector org
  else ()
  
in

(* ¾å²¼º¸±¦4ÅÀ¤Î´ÖÀÜ¸÷ÄÉÀ×·ë²Ì¤ò»È¤ï¤º¡¢300ËÜÁ´Éô¤Î¥Ù¥¯¥È¥ë¤òÄÉÀ×¤·¤Æ´ÖÀÜ¸÷¤ò
   ·×»»¤¹¤ë¡£20%(60ËÜ)¤ÏÄÉÀ×ºÑ¤Ê¤Î¤Ç¡¢»Ä¤ê80%(240ËÜ)¤òÄÉÀ×¤¹¤ë *)
let rec calc_diffuse_using_1point pixel nref = 
  
  let ray20p = p_received_ray_20percent pixel in
  let nvectors = p_nvectors pixel in
  let intersection_points = p_intersection_points pixel in
  let energya = p_energy pixel in

  veccpy diffuse_ray ray20p.(nref);
  trace_diffuse_ray_80percent 
    (p_group_id pixel)
    nvectors.(nref)
    intersection_points.(nref);
  vecaccumv rgb energya.(nref) diffuse_ray
    
in

(* ¼«Ê¬¤È¾å²¼º¸±¦4ÅÀ¤ÎÄÉÀ×·ë²Ì¤ò²Ã»»¤·¤Æ´ÖÀÜ¸÷¤òµá¤á¤ë¡£ËÜÍè¤Ï 300 ËÜ¤Î¸÷¤ò
   ÄÉÀ×¤¹¤ëÉ¬Í×¤¬¤¢¤ë¤¬¡¢5ÅÀ²Ã»»¤¹¤ë¤Î¤Ç1ÅÀ¤¢¤¿¤ê60ËÜ(20%)ÄÉÀ×¤¹¤ë¤À¤±¤ÇºÑ¤à *)
   
let rec calc_diffuse_using_5points x prev cur next nref =

  let r_up = p_received_ray_20percent prev.(x) in
  let r_left = p_received_ray_20percent cur.(x-1) in
  let r_center = p_received_ray_20percent cur.(x) in
  let r_right = p_received_ray_20percent cur.(x+1) in
  let r_down = p_received_ray_20percent next.(x) in
  
  veccpy diffuse_ray r_up.(nref);
  vecadd diffuse_ray r_left.(nref);
  vecadd diffuse_ray r_center.(nref);
  vecadd diffuse_ray r_right.(nref);
  vecadd diffuse_ray r_down.(nref);
  
  let energya = p_energy cur.(x) in
  vecaccumv rgb energya.(nref) diffuse_ray
  
in

(* ¾å²¼º¸±¦4ÅÀ¤ò»È¤ï¤º¤ËÄ¾ÀÜ¸÷¤Î³Æ¾×ÆÍÅÀ¤Ë¤ª¤±¤ë´ÖÀÜ¼õ¸÷¤ò·×»»¤¹¤ë *)
let rec do_without_neighbors pixel nref = 
  if nref <= 4 then
    (* ¾×ÆÍÌÌÈÖ¹æ¤¬Í­¸ú(ÈóÉé)¤«¥Á¥§¥Ã¥¯ *)
    let surface_ids = p_surface_ids pixel in
    if surface_ids.(nref) >= 0 then (
      let calc_diffuse = p_calc_diffuse pixel in
      if calc_diffuse.(nref) then
	calc_diffuse_using_1point pixel nref
      else ();
      do_without_neighbors pixel (nref + 1)
     ) else ()
  else ()
in

(* ²èÁü¾å¤Ç¾å²¼º¸±¦¤ËÅÀ¤¬¤¢¤ë¤«(Í×¤¹¤ë¤Ë¡¢²èÁü¤ÎÃ¼¤ÇÌµ¤¤»ö)¤ò³ÎÇ§ *)
let rec neighbors_exist x y next =
  if (y + 1) < image_size.(1) then 
    if y > 0 then
      if (x + 1) < image_size.(0) then
	if x > 0 then
	  true
	else false
      else false
    else false
  else false
in

let rec get_surface_id pixel index =
  let surface_ids = p_surface_ids pixel in
  surface_ids.(index)
in

(* ¾å²¼º¸±¦4ÅÀ¤ÎÄ¾ÀÜ¸÷ÄÉÀ×¤Î·ë²Ì¡¢¼«Ê¬¤ÈÆ±¤¸ÌÌ¤Ë¾×ÆÍ¤·¤Æ¤¤¤ë¤«¤ò¥Á¥§¥Ã¥¯
   ¤â¤·Æ±¤¸ÌÌ¤Ë¾×ÆÍ¤·¤Æ¤¤¤ì¤Ğ¡¢¤³¤ì¤é4ÅÀ¤Î·ë²Ì¤ò»È¤¦¤³¤È¤Ç·×»»¤ò¾ÊÎ¬½ĞÍè¤ë *)
let rec neighbors_are_available x prev cur next nref =
  let sid_center = get_surface_id cur.(x) nref in

  if get_surface_id prev.(x) nref = sid_center then
    if get_surface_id next.(x) nref = sid_center then
      if get_surface_id cur.(x-1) nref = sid_center then
	if get_surface_id cur.(x+1) nref = sid_center then
	  true
	else false
      else false
    else false
  else false
in

(* Ä¾ÀÜ¸÷¤Î³Æ¾×ÆÍÅÀ¤Ë¤ª¤±¤ë´ÖÀÜ¼õ¸÷¤Î¶¯¤µ¤ò¡¢¾å²¼º¸±¦4ÅÀ¤Î·ë²Ì¤ò»ÈÍÑ¤·¤Æ·×»»
   ¤¹¤ë¡£¤â¤·¾å²¼º¸±¦4ÅÀ¤Î·×»»·ë²Ì¤ò»È¤¨¤Ê¤¤¾ì¹ç¤Ï¡¢¤½¤Î»şÅÀ¤Ç
   do_without_neighbors¤ËÀÚ¤êÂØ¤¨¤ë *)

let rec try_exploit_neighbors x y prev cur next nref =
  let pixel = cur.(x) in
  if nref <= 4 then

    (* ¾×ÆÍÌÌÈÖ¹æ¤¬Í­¸ú(ÈóÉé)¤« *)
    if get_surface_id pixel nref >= 0 then
      (* ¼ş°Ï4ÅÀ¤òÊä´°¤Ë»È¤¨¤ë¤« *)
      if neighbors_are_available x prev cur next nref then (

	(* ´ÖÀÜ¼õ¸÷¤ò·×»»¤¹¤ë¥Õ¥é¥°¤¬Î©¤Ã¤Æ¤¤¤ì¤Ğ¼Âºİ¤Ë·×»»¤¹¤ë *)
	let calc_diffuse = p_calc_diffuse pixel in
        if calc_diffuse.(nref) then
	  calc_diffuse_using_5points x prev cur next nref
	else ();

	(* ¼¡¤ÎÈ¿¼Í¾×ÆÍÅÀ¤Ø *)
	try_exploit_neighbors x y prev cur next (nref + 1)
      ) else
	(* ¼ş°Ï4ÅÀ¤òÊä´°¤Ë»È¤¨¤Ê¤¤¤Î¤Ç¡¢¤³¤ì¤é¤ò»È¤ï¤Ê¤¤ÊıË¡¤ËÀÚ¤êÂØ¤¨¤ë *)
	do_without_neighbors cur.(x) nref
    else ()
  else ()
in

(******************************************************************************
   PPM¥Õ¥¡¥¤¥ë¤Î½ñ¤­¹ş¤ß´Ø¿ô
 *****************************************************************************)
let rec write_ppm_header _ =
  ( 
    print_char 80; (* 'P' *)
    print_char (48 + 3); (* +6 if binary *) (* 48 = '0' *)
    print_char 10;
    print_int image_size.(0);
    print_char 32;
    print_int image_size.(1);
    print_char 32;
    print_int 255;
    print_char 10
  )
in

let rec write_rgb_element x =
  let ix = int_of_float x in
  let elem = if ix > 255 then 255 else if ix < 0 then 0 else ix in
  print_int elem
in

let rec write_rgb _ =
   write_rgb_element rgb.(0); (* Red   *)
   print_char 32;
   write_rgb_element rgb.(1); (* Green *)
   print_char 32;
   write_rgb_element rgb.(2); (* Blue  *)
   print_char 10
in

(******************************************************************************
   ¤¢¤ë¥é¥¤¥ó¤Î·×»»¤ËÉ¬Í×¤Ê¾ğÊó¤ò½¸¤á¤ë¤¿¤á¼¡¤Î¥é¥¤¥ó¤ÎÄÉÀ×¤ò¹Ô¤Ã¤Æ¤ª¤¯´Ø¿ô·²
 *****************************************************************************)

(* ´ÖÀÜ¸÷¤Î¥µ¥ó¥×¥ê¥ó¥°¤Ç¤Ï¾å²¼º¸±¦4ÅÀ¤Î·ë²Ì¤ò»È¤¦¤Î¤Ç¡¢¼¡¤Î¥é¥¤¥ó¤Î·×»»¤ò
   ¹Ô¤ï¤Ê¤¤¤ÈºÇ½ªÅª¤Ê¥Ô¥¯¥»¥ë¤ÎÃÍ¤ò·×»»¤Ç¤­¤Ê¤¤ *)

(* ´ÖÀÜ¸÷¤ò 60ËÜ(20%)¤À¤±·×»»¤·¤Æ¤ª¤¯´Ø¿ô *)
let rec pretrace_diffuse_rays pixel nref =
  if nref <= 4 then

    (* ÌÌÈÖ¹æ¤¬Í­¸ú¤« *)
    let sid = get_surface_id pixel nref in
    if sid >= 0 then (
      (* ´ÖÀÜ¸÷¤ò·×»»¤¹¤ë¥Õ¥é¥°¤¬Î©¤Ã¤Æ¤¤¤ë¤« *)
      let calc_diffuse = p_calc_diffuse pixel in
      if calc_diffuse.(nref) then (
	let group_id = p_group_id pixel in
	vecbzero diffuse_ray;

	(* 5¤Ä¤ÎÊı¸ş¥Ù¥¯¥È¥ë½¸¹ç(³Æ60ËÜ)¤«¤é¼«Ê¬¤Î¥°¥ë¡¼¥×ID¤ËÂĞ±ş¤¹¤ëÊª¤ò
	   °ì¤ÄÁª¤ó¤ÇÄÉÀ× *)
	let nvectors = p_nvectors pixel in
	let intersection_points = p_intersection_points pixel in
	trace_diffuse_rays 
	  dirvecs.(group_id) 
	  nvectors.(nref)
	  intersection_points.(nref);
	let ray20p = p_received_ray_20percent pixel in
	veccpy ray20p.(nref) diffuse_ray
       ) else ();
      pretrace_diffuse_rays pixel (nref + 1)
     ) else ()
  else ()
in

(* ³Æ¥Ô¥¯¥»¥ë¤ËÂĞ¤·¤ÆÄ¾ÀÜ¸÷ÄÉÀ×¤È´ÖÀÜ¼õ¸÷¤Î20%Ê¬¤Î·×»»¤ò¹Ô¤¦ *)

let rec pretrace_pixels line x group_id lc0 lc1 lc2 = 
  if x >= 0 then (

    let xdisp = scan_pitch.(0) *. float_of_int (x - image_center.(0)) in
    ptrace_dirvec.(0) <- xdisp *. screenx_dir.(0) +. lc0;
    ptrace_dirvec.(1) <- xdisp *. screenx_dir.(1) +. lc1;
    ptrace_dirvec.(2) <- xdisp *. screenx_dir.(2) +. lc2;
    vecunit_sgn ptrace_dirvec false;
    vecbzero rgb;
    veccpy startp viewpoint;

    (* Ä¾ÀÜ¸÷ÄÉÀ× *)
    trace_ray 0 1.0 ptrace_dirvec line.(x) 0.0;
    veccpy (p_rgb line.(x)) rgb;
    p_set_group_id line.(x) group_id;
    
    (* ´ÖÀÜ¸÷¤Î20%¤òÄÉÀ× *)
    pretrace_diffuse_rays line.(x) 0;
    
    pretrace_pixels line (x-1) (add_mod5 group_id 1) lc0 lc1 lc2
    
   ) else ()
in

(* ¤¢¤ë¥é¥¤¥ó¤Î³Æ¥Ô¥¯¥»¥ë¤ËÂĞ¤·Ä¾ÀÜ¸÷ÄÉÀ×¤È´ÖÀÜ¼õ¸÷20%Ê¬¤Î·×»»¤ò¤¹¤ë *)
let rec pretrace_line line y group_id = 
  let ydisp = scan_pitch.(0) *. float_of_int (y - image_center.(1)) in
 
  (* ¥é¥¤¥ó¤ÎÃæ¿´¤Ë¸ş¤«¤¦¥Ù¥¯¥È¥ë¤ò·×»» *)
  let lc0 = ydisp *. screeny_dir.(0) +. screenz_dir.(0) in
  let lc1 = ydisp *. screeny_dir.(1) +. screenz_dir.(1) in
  let lc2 = ydisp *. screeny_dir.(2) +. screenz_dir.(2) in
  pretrace_pixels line (image_size.(0) - 1) group_id lc0 lc1 lc2
in


(******************************************************************************
   Ä¾ÀÜ¸÷ÄÉÀ×¤È´ÖÀÜ¸÷20%ÄÉÀ×¤Î·ë²Ì¤«¤éºÇ½ªÅª¤Ê¥Ô¥¯¥»¥ëÃÍ¤ò·×»»¤¹¤ë´Ø¿ô
 *****************************************************************************)

(* ³Æ¥Ô¥¯¥»¥ë¤ÎºÇ½ªÅª¤Ê¥Ô¥¯¥»¥ëÃÍ¤ò·×»» *)
let rec scan_pixel x y prev cur next = 
  if x < image_size.(0) then (

    (* ¤Ş¤º¡¢Ä¾ÀÜ¸÷ÄÉÀ×¤ÇÆÀ¤é¤ì¤¿RGBÃÍ¤òÆÀ¤ë *)
    veccpy rgb (p_rgb cur.(x));

    (* ¼¡¤Ë¡¢Ä¾ÀÜ¸÷¤Î³Æ¾×ÆÍÅÀ¤Ë¤Ä¤¤¤Æ¡¢´ÖÀÜ¼õ¸÷¤Ë¤è¤ë´óÍ¿¤ò²ÃÌ£¤¹¤ë *)
    if neighbors_exist x y next then
      try_exploit_neighbors x y prev cur next 0
    else
      do_without_neighbors cur.(x) 0;

    (* ÆÀ¤é¤ì¤¿ÃÍ¤òPPM¥Õ¥¡¥¤¥ë¤Ë½ĞÎÏ *)
    write_rgb ();

    scan_pixel (x + 1) y prev cur next
   ) else ()
in

(* °ì¥é¥¤¥óÊ¬¤Î¥Ô¥¯¥»¥ëÃÍ¤ò·×»» *)
let rec scan_line y prev cur next group_id = (

  if y < image_size.(1) then (

    if y < image_size.(1) - 1 then
      pretrace_line next (y + 1) group_id
    else ();
    scan_pixel 0 y prev cur next;
    scan_line (y + 1) cur next prev (add_mod5 group_id 2)
   ) else ()      
)
in

(******************************************************************************
   ¥Ô¥¯¥»¥ë¤Î¾ğÊó¤ò³ÊÇ¼¤¹¤ë¥Ç¡¼¥¿¹½Â¤¤Î³ä¤êÅö¤Æ´Ø¿ô·²
 *****************************************************************************)

(* 3¼¡¸µ¥Ù¥¯¥È¥ë¤Î5Í×ÁÇÇÛÎó¤ò³ä¤êÅö¤Æ *)
let rec create_float5x3array _ = (
  let vec = Array.create 3 0.0 in
  let array = Array.create 5 vec in
  array.(1) <- Array.create 3 0.0;
  array.(2) <- Array.create 3 0.0;
  array.(3) <- Array.create 3 0.0;
  array.(4) <- Array.create 3 0.0;
  array
)
in

(* ¥Ô¥¯¥»¥ë¤òÉ½¤¹tuple¤ò³ä¤êÅö¤Æ *)
let rec create_pixel _ =
  let m_rgb = Array.create 3 0.0 in
  let m_isect_ps = create_float5x3array() in
  let m_sids = Array.create 5 0 in
  let m_cdif = Array.create 5 false in
  let m_engy = create_float5x3array() in
  let m_r20p = create_float5x3array() in
  let m_gid = Array.create 1 0 in
  let m_nvectors = create_float5x3array() in
  (m_rgb, m_isect_ps, m_sids, m_cdif, m_engy, m_r20p, m_gid, m_nvectors)
in

(* ²£Êı¸ş1¥é¥¤¥óÃæ¤Î³Æ¥Ô¥¯¥»¥ëÍ×ÁÇ¤ò³ä¤êÅö¤Æ¤ë *)
let rec init_line_elements line n =
  if n >= 0 then (
    line.(n) <- create_pixel();
    init_line_elements line (n-1)
   ) else
    line
in

(* ²£Êı¸ş1¥é¥¤¥óÊ¬¤Î¥Ô¥¯¥»¥ëÇÛÎó¤òºî¤ë *)
let rec create_pixelline _ = 
  let line = Array.create image_size.(0) (create_pixel()) in
  init_line_elements line (image_size.(0)-2)
in

(******************************************************************************
   ´ÖÀÜ¸÷¤Î¥µ¥ó¥×¥ê¥ó¥°¤Ë¤Ä¤«¤¦Êı¸ş¥Ù¥¯¥È¥ë·²¤ò·×»»¤¹¤ë´Ø¿ô·²
 *****************************************************************************)

(* ¥Ù¥¯¥È¥ëÃ£¤¬½ĞÍè¤ë¤À¤±°ìÍÍ¤ËÊ¬ÉÛ¤¹¤ë¤è¤¦¡¢600ËÜ¤ÎÊı¸ş¥Ù¥¯¥È¥ë¤Î¸ş¤­¤òÄê¤á¤ë
   Î©ÊıÂÎ¾å¤Î³ÆÌÌ¤Ë100ËÜ¤º¤ÄÊ¬ÉÛ¤µ¤»¡¢¤µ¤é¤Ë¡¢100ËÜ¤¬Î©ÊıÂÎ¾å¤ÎÌÌ¾å¤Ç10 x 10 ¤Î
   ³Ê»Ò¾õ¤ËÊÂ¤Ö¤è¤¦¤ÊÇÛÎó¤ò»È¤¦¡£¤³¤ÎÇÛÎó¤Ç¤ÏÊı³Ñ¤Ë¤è¤ë¥Ù¥¯¥È¥ë¤ÎÌ©ÅÙ¤Îº¹¤¬
   Âç¤­¤¤¤Î¤Ç¡¢¤³¤ì¤ËÊäÀµ¤ò²Ã¤¨¤¿¤â¤Î¤òºÇ½ªÅª¤ËÍÑ¤¤¤ë *)
(*
let rec tan x =
  sin(x) /. cos(x)
in
*)
(* ¥Ù¥¯¥È¥ëÃ£¤¬½ĞÍè¤ë¤À¤±µåÌÌ¾õ¤Ë°ìÍÍ¤ËÊ¬ÉÛ¤¹¤ë¤è¤¦ºÂÉ¸¤òÊäÀµ¤¹¤ë *)
let rec adjust_position h ratio =
  let l = sqrt(h*.h +. 0.1) in
  let tan_h = 1.0 /. l in
  let theta_h = atan tan_h in
   let tan_m = tan (theta_h *. ratio) in
  tan_m *. l
in

(* ¥Ù¥¯¥È¥ëÃ£¤¬½ĞÍè¤ë¤À¤±µåÌÌ¾õ¤Ë°ìÍÍ¤ËÊ¬ÉÛ¤¹¤ë¤è¤¦¤Ê¸ş¤­¤ò·×»»¤¹¤ë *)
let rec calc_dirvec icount x y rx ry group_id index =
  if icount >= 5 then (
    let l = sqrt(fsqr x +. fsqr y +. 1.0) in
    let vx = x /. l in
    let vy = y /. l in
    let vz = 1.0 /. l in

    (* Î©ÊıÂÎÅª¤ËÂĞ¾Î¤ËÊ¬ÉÛ¤µ¤»¤ë *)
    let dgroup = dirvecs.(group_id) in
    vecset (d_vec dgroup.(index))    vx vy vz;
    vecset (d_vec dgroup.(index+40)) vx vz (fneg vy);
    vecset (d_vec dgroup.(index+80)) vz (fneg vx) (fneg vy);
    vecset (d_vec dgroup.(index+1)) (fneg vx) (fneg vy) (fneg vz);
    vecset (d_vec dgroup.(index+41)) (fneg vx) (fneg vz) vy;
    vecset (d_vec dgroup.(index+81)) (fneg vz) vx vy
   ) else 
    let x2 = adjust_position y rx in
    calc_dirvec (icount + 1) x2 (adjust_position x2 ry) rx ry group_id index
in

(* Î©ÊıÂÎ¾å¤Î 10x10³Ê»Ò¤Î¹ÔÃæ¤Î³Æ¥Ù¥¯¥È¥ë¤ò·×»»¤¹¤ë *)
let rec calc_dirvecs col ry group_id index =
  if col >= 0 then (
    (* º¸È¾Ê¬ *)
    let rx = (float_of_int col) *. 0.2 -. 0.9 in (* Îó¤ÎºÂÉ¸ *)
    calc_dirvec 0 0.0 0.0 rx ry group_id index;
    (* ±¦È¾Ê¬ *)
    let rx2 = (float_of_int col) *. 0.2 +. 0.1 in (* Îó¤ÎºÂÉ¸ *)
    calc_dirvec 0 0.0 0.0 rx2 ry group_id (index + 2);

    calc_dirvecs (col - 1) ry (add_mod5 group_id 1) index
   ) else ()
in

(* Î©ÊıÂÎ¾å¤Î10x10³Ê»Ò¤Î³Æ¹Ô¤ËÂĞ¤·¥Ù¥¯¥È¥ë¤Î¸ş¤­¤ò·×»»¤¹¤ë *)
let rec calc_dirvec_rows row group_id index =
  if row >= 0 then (
    let ry = (float_of_int row) *. 0.2 -. 0.9 in (* ¹Ô¤ÎºÂÉ¸ *)
    calc_dirvecs 4 ry group_id index; (* °ì¹ÔÊ¬·×»» *)
    calc_dirvec_rows (row - 1) (add_mod5 group_id 2) (index + 4) 
   ) else ()
in

(******************************************************************************
   dirvec ¤Î¥á¥â¥ê³ä¤êÅö¤Æ¤ò¹Ô¤¦
 *****************************************************************************)


let rec create_dirvec _ =
  let v3 = Array.create 3 0.0 in
  let consts = Array.create n_objects.(0) v3 in
  (v3, consts)
in

let rec create_dirvec_elements d index =
  if index >= 0 then (
    d.(index) <- create_dirvec();
    create_dirvec_elements d (index - 1)
   ) else ()
in

let rec create_dirvecs index =
  if index >= 0 then (
    dirvecs.(index) <- Array.create 120 (create_dirvec());
    create_dirvec_elements dirvecs.(index) 118;
    create_dirvecs (index-1)
   ) else ()
in

(******************************************************************************
   Êä½õ´Ø¿ôÃ£¤ò¸Æ¤Ó½Ğ¤·¤Ædirvec¤Î½é´ü²½¤ò¹Ô¤¦ 
 *****************************************************************************)

let rec init_dirvec_constants vecset index =
  if index >= 0 then (
    setup_dirvec_constants vecset.(index);
    init_dirvec_constants vecset (index - 1)
   ) else ()
in

let rec init_vecset_constants index =
  if index >= 0 then (
    init_dirvec_constants dirvecs.(index) 119;
    init_vecset_constants (index - 1)
   ) else ()
in

let rec init_dirvecs _ =
  create_dirvecs 4;
  calc_dirvec_rows 9 0 0;
  init_vecset_constants 4
in

(******************************************************************************
   ´°Á´¶ÀÌÌÈ¿¼ÍÀ®Ê¬¤ò»ı¤ÄÊªÂÎ¤ÎÈ¿¼Í¾ğÊó¤ò½é´ü²½¤¹¤ë
 *****************************************************************************)

(* È¿¼ÍÊ¿ÌÌ¤òÄÉ²Ã¤¹¤ë *)
let rec add_reflection index surface_id bright v0 v1 v2 =
  let dvec = create_dirvec() in
  vecset (d_vec dvec) v0 v1 v2; (* È¿¼Í¸÷¤Î¸ş¤­ *)
  setup_dirvec_constants dvec;

  reflections.(index) <- (surface_id, dvec, bright)
in

(* Ä¾ÊıÂÎ¤Î³ÆÌÌ¤Ë¤Ä¤¤¤Æ¾ğÊó¤òÄÉ²Ã¤¹¤ë *)
let rec setup_rect_reflection obj_id obj =
  let sid = obj_id * 4 in
  let nr = n_reflections.(0) in
  let br = 1.0 -. o_diffuse obj in
  let n0 = fneg light.(0) in
  let n1 = fneg light.(1) in
  let n2 = fneg light.(2) in
  add_reflection nr (sid+1) br light.(0) n1 n2;
  add_reflection (nr+1) (sid+2) br n0 light.(1) n2;
  add_reflection (nr+2) (sid+3) br n0 n1 light.(2);
  n_reflections.(0) <- nr + 3
in

(* Ê¿ÌÌ¤Ë¤Ä¤¤¤Æ¾ğÊó¤òÄÉ²Ã¤¹¤ë *)
let rec setup_surface_reflection obj_id obj =
  let sid = obj_id * 4 + 1 in
  let nr = n_reflections.(0) in
  let br = 1.0 -. o_diffuse obj in
  let p = veciprod light (o_param_abc obj) in

  add_reflection nr sid br
    (2.0 *. o_param_a obj *. p -. light.(0))
    (2.0 *. o_param_b obj *. p -. light.(1))
    (2.0 *. o_param_c obj *. p -. light.(2));
  n_reflections.(0) <- nr + 1
in


(* ³Æ¥ª¥Ö¥¸¥§¥¯¥È¤ËÂĞ¤·¡¢È¿¼Í¤¹¤ëÊ¿ÌÌ¤¬¤¢¤ì¤Ğ¤½¤Î¾ğÊó¤òÄÉ²Ã¤¹¤ë *)
let rec setup_reflections obj_id = 
  if obj_id >= 0 then
    let obj = objects.(obj_id) in
    if o_reflectiontype obj = 2 then
      if fless (o_diffuse obj) 1.0 then
	let m_shape = o_form obj in
	(* Ä¾ÊıÂÎ¤ÈÊ¿ÌÌ¤Î¤ß¥µ¥İ¡¼¥È *)
	if m_shape = 1 then 
	  setup_rect_reflection obj_id obj
	else if m_shape = 2 then
	  setup_surface_reflection obj_id obj
	else ()
      else ()
    else ()
  else ()
in

(*****************************************************************************
   Á´ÂÎ¤ÎÀ©¸æ
 *****************************************************************************)

(* ¥ì¥¤¥È¥ì¤Î³Æ¥¹¥Æ¥Ã¥×¤ò¹Ô¤¦´Ø¿ô¤ò½ç¼¡¸Æ¤Ó½Ğ¤¹ *)
let rec rt size_x size_y =
(
 image_size.(0) <- size_x;
 image_size.(1) <- size_y;
 image_center.(0) <- size_x / 2;
 image_center.(1) <- size_y / 2;
 scan_pitch.(0) <- 128.0 /. float_of_int size_x;
 let prev = create_pixelline () in
 let cur  = create_pixelline () in
 let next = create_pixelline () in
 read_parameter();
 write_ppm_header ();
 init_dirvecs();
 veccpy (d_vec light_dirvec) light;
 setup_dirvec_constants light_dirvec;
 setup_reflections (n_objects.(0) - 1);
 pretrace_line cur 0 0;
 scan_line 0 prev cur next 2 
)
in

let _ = rt 128 128

in 0
