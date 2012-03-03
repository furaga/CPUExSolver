%{
(* parser¤¬ÍøÍÑ¤¹¤ëÊÑ¿ô¡¢´Ø¿ô¡¢·¿¤Ê¤É¤ÎÄêµÁ *)
open Syntax
open Lexing
let addtyp x = (x, Type.gentyp ())
let get_syntax x = (x, (Global.get_position (Parsing.symbol_start ()), Global.get_position (Parsing.symbol_start ())))
(* log_2^x¤òµá¤á¤ë *)
let rec is_log2 x = 
  if x = 0 then
  	false
  else if x = 1 then
  	true
  else
  	(if x > 0 && x mod 2 = 0 then is_log2 (x / 2) else false)
let rec log2 x =
  if x = 1 then
  	0
  else
  	(assert (x mod 2 = 0); (log2 (x / 2)) + 1)
  	
let is_log2_exp e =
	match e with
	| (Int n, _) when is_log2 n -> true
	| (Neg (Int n, _), _) when is_log2 n -> true
	| _ -> false
	
let sll_of_mul e1 e2 =
	match e2 with
	| (Int n, line) -> SLL (e1, (Int (log2 n), line))
	| (Neg (Int n, _), line) -> SLL ((Neg e1, snd e1), (Int (log2 n), line))
	| _ -> Mul (e1, e2)
	
(* sll¤ÎÉé¤Î¿ô¥Ð¡¼¥¸¥ç¥ó¤Ï»»½Ñ±¦¥·¥Õ¥È *)
let sll_of_div e1 e2 =
	match e2 with
	| (Int n, line) -> SLL (e1, (Int (-(log2 n)), line))
	| (Neg (Int n, _), line) -> SLL ((Neg e1, snd e1), (Int (-(log2 n)), line))
	| _ -> assert false (*Div (e1, e2)*)
%}

/* »ú¶ç¤òÉ½¤¹¥Ç¡¼¥¿·¿¤ÎÄêµÁ (caml2html: parser_token) */
%token <bool> BOOL
%token <int> INT
%token <float> FLOAT
%token NOT
%token MINUS
%token PLUS
%token AST
%token SLASH
%token MINUS_DOT
%token PLUS_DOT
%token AST_DOT
%token SLASH_DOT
%token EQUAL
%token LESS_GREATER
%token LESS_EQUAL
%token GREATER_EQUAL
%token LESS
%token GREATER
%token IF
%token THEN
%token ELSE
%token <Id.t> IDENT
%token LET
%token IN
%token REC
%token COMMA
%token ARRAY_CREATE
%token DOT
%token LESS_MINUS
%token SEMICOLON
%token LPAREN
%token RPAREN
%token EOF

/* Í¥Àè½ç°Ì¤Èassociativity¤ÎÄêµÁ¡ÊÄã¤¤Êý¤«¤é¹â¤¤Êý¤Ø¡Ë (caml2html: parser_prior) */
%right prec_let
%right SEMICOLON
%right prec_if
%right LESS_MINUS
%left COMMA
%left EQUAL LESS_GREATER LESS GREATER LESS_EQUAL GREATER_EQUAL
%left PLUS MINUS PLUS_DOT MINUS_DOT
%left AST SLASH AST_DOT SLASH_DOT
%right prec_unary_minus
%left prec_app
%left DOT

/* ³«»Ïµ­¹æ¤ÎÄêµÁ */
%type <Syntax.t> exp
%start exp

%%

simple_exp: /* ³ç¸Ì¤ò¤Ä¤±¤Ê¤¯¤Æ¤â´Ø¿ô¤Î°ú¿ô¤Ë¤Ê¤ì¤ë¼° (caml2html: parser_simple) */
| LPAREN exp RPAREN
    { $2 }
| LPAREN RPAREN
    { get_syntax Unit }
| BOOL
    { get_syntax (Bool($1)) }
| INT
    { get_syntax (Int($1)) }
| FLOAT
    { get_syntax (Float($1)) }
| IDENT
    { get_syntax (Var($1)) }
| simple_exp DOT LPAREN exp RPAREN
    { get_syntax (Get($1, $4)) }

exp: /* °ìÈÌ¤Î¼° (caml2html: parser_exp) */
| simple_exp
    { $1 }
| NOT exp
    %prec prec_app
    { get_syntax (Not($2)) }
| MINUS exp
    %prec prec_unary_minus
    { match fst $2 with
    | Int(n) -> get_syntax (Int(-n)) (* -1.23¤Ê¤É¤Ï·¿¥¨¥é¡¼¤Ç¤Ï¤Ê¤¤¤Î¤ÇÊÌ°·¤¤ *)
    | Float(f) -> get_syntax (Float(-.f)) (* -1.23¤Ê¤É¤Ï·¿¥¨¥é¡¼¤Ç¤Ï¤Ê¤¤¤Î¤ÇÊÌ°·¤¤ *)
    | e -> get_syntax (Neg($2)) }
| exp PLUS exp /* Â­¤·»»¤ò¹½Ê¸²òÀÏ¤¹¤ë¥ë¡¼¥ë (caml2html: parser_add) */
    { get_syntax (Add($1, $3)) }
| exp MINUS exp
    { get_syntax (Sub($1, $3)) }
| exp AST exp
    { if is_log2_exp $3 then get_syntax (sll_of_mul $1 $3) else get_syntax (Mul($1, $3)) }
| exp SLASH exp
    { if is_log2_exp $3 then get_syntax (sll_of_div $1 $3) else assert false(*get_syntax (Div($1, $3))*) }
| exp EQUAL exp
    { get_syntax (Eq($1, $3)) }
| exp LESS_GREATER exp
    { get_syntax (Not(get_syntax (Eq($1, $3)))) }
| exp LESS exp
    { get_syntax (Not(get_syntax (LE($3, $1)))) }
| exp GREATER exp
    { get_syntax (Not(get_syntax (LE($1, $3)))) }
| exp LESS_EQUAL exp
    { get_syntax (LE($1, $3)) }
| exp GREATER_EQUAL exp
    { get_syntax (LE($3, $1)) }
| IF exp THEN exp ELSE exp
    %prec prec_if
    { get_syntax (If($2, $4, $6)) }
| MINUS_DOT exp
    %prec prec_unary_minus
    { get_syntax (FNeg($2)) }
| exp PLUS_DOT exp
    { get_syntax (FAdd($1, $3)) }
| exp MINUS_DOT exp
    { get_syntax (FSub($1, $3)) }
| exp AST_DOT exp
    { get_syntax (FMul($1, $3)) }
| exp SLASH_DOT exp
    { get_syntax (FDiv($1, $3)) }
| LET IDENT EQUAL exp IN exp
    %prec prec_let
    { get_syntax (Let(addtyp $2, $4, $6)) }
| LET REC fundef IN exp
    %prec prec_let
    {
		(* ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ *)
		let fundef = $3 in
		let name = fst fundef.name in
		match name with
			| "read_int" | "read_float" (*| "print_int" | "print_float"*) when !Global.use_binary_data -> $5
			| _ -> get_syntax (LetRec($3, $5)) 
	}
| exp actual_args
    %prec prec_app
    { get_syntax (App($1, $2)) }
| elems
    { get_syntax (Tuple($1)) }
| LET LPAREN pat RPAREN EQUAL exp IN exp
    { get_syntax (LetTuple($3, $6, $8)) }
| simple_exp DOT LPAREN exp RPAREN LESS_MINUS exp
    { get_syntax (Put($1, $4, $7)) }
| exp SEMICOLON exp
    { get_syntax (Let((Id.gentmp Type.Unit, Type.Unit), $1, $3)) }
| exp SEMICOLON
    { $1 (*¤³¤ì¤¬¤Ê¤¤¤Èmin-rt.ml¤Ï¥³¥ó¥Ñ¥¤¥ë¤Ç¤­¤Ê¤¤¤È¤¤¤¦*) }
| ARRAY_CREATE simple_exp simple_exp
    %prec prec_app
    { get_syntax (Array($2, $3)) }
| error
    { 	let (sy, sx) = Global.get_position (Parsing.symbol_start ()) in
		let (ey, ex) = Global.get_position (Parsing.symbol_end ()) in
		failwith (Printf.sprintf "parse error near characters (%d,%d) - (%d,%d)" sy sx ey ex) }

fundef:
| IDENT formal_args EQUAL exp
    { { name = addtyp $1; args = $2; body = $4 } }

formal_args:
| IDENT formal_args
    { addtyp $1 :: $2 }
| IDENT
    { [addtyp $1] }

actual_args:
| actual_args simple_exp
    %prec prec_app
    { $1 @ [$2] }
| simple_exp
    %prec prec_app
    { [$1] }

elems:
| elems COMMA exp
    { $1 @ [$3] }
| exp COMMA exp
    { [$1; $3] }

pat:
| pat COMMA IDENT
    { $1 @ [addtyp $3] }
| IDENT COMMA IDENT
    { [addtyp $1; addtyp $3] }
    
    
