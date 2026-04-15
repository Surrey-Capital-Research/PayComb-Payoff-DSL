open Payoff_lib

let read_file filename =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let () =
  let args = Sys.argv in
  if Array.length args < 2 then
    Printf.printf "Usage: %s <filename>\n" args.(0)
  else
    let filename = args.(1) in
    let content = read_file filename in
    let lexbuf = Lexing.from_string content in
    try
      let prog = Parser.program Lexer.read lexbuf in
      Interpreter.eval_program prog
    with
    | Parser.Error ->
        let pos = lexbuf.Lexing.lex_curr_p in
        Printf.printf "Syntax error at line %d, column %d\n"
          pos.Lexing.pos_lnum (pos.Lexing.pos_cnum - pos.Lexing.pos_bol)
    | e ->
        Printf.printf "Error: %s\n" (Printexc.to_string e)
