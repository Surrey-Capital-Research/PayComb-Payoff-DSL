{
  open Parser
}

let white = [' ' '\t']+
let digit = ['0'-'9']
let int = '-'? digit+
let float = '-'? digit+ '.' digit*
let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule read =
  parse
  | white    { read lexbuf }
  | "//" [^ '\n']* { read lexbuf }
  | "\n"     { Lexing.new_line lexbuf; read lexbuf }
  | int      { NUMBER (float_of_string (Lexing.lexeme lexbuf)) }
  | float    { NUMBER (float_of_string (Lexing.lexeme lexbuf)) }
  | "let"    { LET }
  | "print"  { PRINT }
  | "ST"     { ST }
  | "True"   { TRUE }
  | "False"  { FALSE }
  | "Call"   { CALL }
  | "Put"    { PUT }
  | "LongStock" { LONGSTOCK }
  | "ShortStock" { SHORTSTOCK }
  | "SellCall" { SELLCALL }
  | "SellPut" { SELLPUT }
  | "Collar" { COLLAR }
  | "Straddle" { STRADDLE }
  | "SellStraddle" { SELLSTRADDLE }
  | "BullCallSpread" { BULLCALLSPREAD }
  | "CollarWithEntry" { COLLARWITHENTRY }
  | "Short" { SHORT }
  | "+"      { PLUS }
  | "-"      { MINUS }
  | "*"      { MULT }
  | "/"      { DIV }
  | "=="     { EQUAL }
  | "="      { ASSIGN }
  | "("      { LPAREN }
  | ")"      { RPAREN }
  | ","      { COMMA }
  | ";"      { SEMICOLON }
  | id       { ID (Lexing.lexeme lexbuf) }
  | eof      { EOF }
