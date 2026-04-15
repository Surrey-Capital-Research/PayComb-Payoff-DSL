open Payoff_lib
open Ast

let rec expr_to_string = function
  | Float f -> string_of_float f
  | Bool b -> string_of_bool b
  | Id id -> id
  | BinOp (op, e1, e2) ->
      let op_s = match op with
        | Add -> "+" | Sub -> "-" | Mult -> "*" | Div -> "/" | Equal -> "=="
      in
      "(" ^ expr_to_string e1 ^ " " ^ op_s ^ " " ^ expr_to_string e2 ^ ")"
  | Call (name, args) ->
      name ^ "(" ^ (String.concat ", " (List.map expr_to_string args)) ^ ")"
  | Eval (e1, e2) ->
      expr_to_string e1 ^ "(" ^ expr_to_string e2 ^ ")"

let stmt_to_string = function
  | Let (id, e) -> "Let(" ^ id ^ ", " ^ expr_to_string e ^ ")"
  | Print e -> "Print(" ^ expr_to_string e ^ ")"
  | StAssign el -> "StAssign([" ^ (String.concat ", " (List.map expr_to_string el)) ^ "])"

let () =
  let input = "let strike = 5;\nlet strad = Call(strike) + Put(strike);\nST = 1,2,3,4,5;\nprint(strad);" in
  let lexbuf = Lexing.from_string input in
  try
    let prog = Parser.program Lexer.read lexbuf in
    List.iter (fun s -> print_endline (stmt_to_string s)) prog
  with
  | Parser.Error ->
      let pos = lexbuf.Lexing.lex_curr_p in
      Printf.printf "Syntax error at line %d, column %d\n"
        pos.Lexing.pos_lnum (pos.Lexing.pos_cnum - pos.Lexing.pos_bol)
  | e ->
      print_endline ("Error: " ^ Printexc.to_string e)
