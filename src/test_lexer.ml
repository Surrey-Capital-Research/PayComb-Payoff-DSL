open Payoff_lib
open Lexer
open Parser

let rec print_tokens lexbuf =
  let token = read lexbuf in
  match token with
  | EOF -> print_endline "EOF"
  | _ ->
    let s = match token with
      | NUMBER f -> "NUMBER(" ^ string_of_float f ^ ")"
      | ID id -> "ID(" ^ id ^ ")"
      | LET -> "LET"
      | PRINT -> "PRINT"
      | ST -> "ST"
      | TRUE -> "TRUE"
      | FALSE -> "FALSE"
      | CALL -> "CALL"
      | PUT -> "PUT"
      | LONGSTOCK -> "LONGSTOCK"
      | SHORTSTOCK -> "SHORTSTOCK"
      | SELLCALL -> "SELLCALL"
      | SELLPUT -> "SELLPUT"
      | COLLAR -> "COLLAR"
      | STRADDLE -> "STRADDLE"
      | SELLSTRADDLE -> "SELLSTRADDLE"
      | BULLCALLSPREAD -> "BULLCALLSPREAD"
      | COLLARWITHENTRY -> "COLLARWITHENTRY"
      | SHORT -> "SHORT"
      | PLUS -> "PLUS"
      | MINUS -> "MINUS"
      | MULT -> "MULT"
      | DIV -> "DIV"
      | EQUAL -> "EQUAL"
      | ASSIGN -> "ASSIGN"
      | LPAREN -> "LPAREN"
      | RPAREN -> "RPAREN"
      | COMMA -> "COMMA"
      | SEMICOLON -> "SEMICOLON"
      | _ -> "UNKNOWN"
    in
    print_endline s;
    print_tokens lexbuf

let () =
  let input = "let strike = 5;\nlet strad = Call(strike) + Put(strike);\nST = 1,2,3,4,5;\nprint(strad);" in
  let lexbuf = Lexing.from_string input in
  print_tokens lexbuf
