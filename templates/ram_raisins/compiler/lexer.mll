{
(* lexerが利用する変数、関数、型などの定義 *)
open Lexing
open Parser
open Type
let lnum = ref 0
}
(* 正規表現の略記 *)
let newline = ['\n']
let space = [' ' '\t' '\r']
let nl = ['\n' '\r']
let digit = ['0'-'9']
let lower = ['a'-'z']
let upper = ['A'-'Z']

rule token = parse

| newline
    {	Global.current_line := !Global.current_line + 1;
		Global.current_cols := (Lexing.lexeme_end lexbuf) :: !Global.current_cols;
		token lexbuf }
| space+
    { token lexbuf }
| "(*"
    { comment lexbuf; (* ネストしたコメントのためのトリック *)
      token lexbuf }
| '('
    { LPAREN }
| ')'
    { RPAREN }
| "true"
    { BOOL(true) }
| "false"
    { BOOL(false) }
| "not"
    { NOT }
| digit+ (* 整数を字句解析するルール (caml2html: lexer_int) *)
    { INT(int_of_string (Lexing.lexeme lexbuf)) }
| digit+ ('.' digit*)? (['e' 'E'] ['+' '-']? digit+)?
    { FLOAT(float_of_string (Lexing.lexeme lexbuf)) }
| '-' (* -.より後回しにしなくても良い? 最長一致? *)
    { MINUS }
| '+' (* +.より後回しにしなくても良い? 最長一致? *)
    { PLUS }
| "*"
    { AST }
| "/"
    { SLASH }
| "-."
    { MINUS_DOT }
| "+."
    { PLUS_DOT }
| "*."
    { AST_DOT }
| "/."
    { SLASH_DOT }
| '='
    { EQUAL }
| "<>"
    { LESS_GREATER }
| "<="
    { LESS_EQUAL }
| ">="
    { GREATER_EQUAL }
| '<'
    { LESS }
| '>'
    { GREATER }
| "if"
    { IF }
| "then"
    { THEN }
| "else"
    { ELSE }
| "let"
    { LET }
| "in"
    { IN }
| "rec"
    { REC }
| ','
    { COMMA }
| '_'
    { IDENT(Id.gentmp Type.Unit) }
| "create_array" (* [XX] ad hoc *)
    { ARRAY_CREATE }
| "Array.create" (* [XX] ad hoc *)
    { ARRAY_CREATE }
| '.'
    { DOT }
| "<-"
    { LESS_MINUS }
| ';'
    { SEMICOLON }
| eof
    { EOF }
| lower (digit|lower|upper|'_')* (* 他の「予約語」より後でないといけない *)
    { IDENT(Lexing.lexeme lexbuf) }
| _
    { 	let (sy, sx) = Global.get_position (Lexing.lexeme_start lexbuf) in
		let (ey, ex) = Global.get_position (Lexing.lexeme_end lexbuf) in
		failwith
		(Printf.sprintf "unknown token %s near characters (%d,%d) - (%d,%d)"
		   (Lexing.lexeme lexbuf)
		   sy sx ey ex) }
and comment = parse
| newline
    {	Global.current_line := !Global.current_line + 1;
		Global.current_cols := (Lexing.lexeme_end lexbuf) :: !Global.current_cols;
		comment lexbuf }
| "*)"
    { () }
| "(*"
    { comment lexbuf;
      comment lexbuf }
| eof
    { Format.eprintf "warning: unterminated comment@." }
| _
    { comment lexbuf }

