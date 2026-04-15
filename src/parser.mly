%{
  open Ast
%}

%token <float> NUMBER
%token <string> ID
%token LET PRINT ST TRUE FALSE
%token CALL PUT LONGSTOCK SHORTSTOCK SELLCALL SELLPUT COLLAR STRADDLE SELLSTRADDLE BULLCALLSPREAD COLLARWITHENTRY SHORT
%token PLUS MINUS MULT DIV ASSIGN EQUAL
%token LPAREN RPAREN COMMA SEMICOLON
%token EOF

%nonassoc EQUAL
%left PLUS MINUS
%left MULT DIV
%nonassoc LPAREN

%start <Ast.program> program

%%

program:
  | s = stmt_list EOF { s }

stmt_list:
  | { [] }
  | s = stmt sl = stmt_list { s :: sl }

stmt:
  | LET id = ID ASSIGN e = expr SEMICOLON { Let(id, e) }
  | PRINT LPAREN e = expr RPAREN SEMICOLON { Print(e) }
  | ST ASSIGN el = expr_list SEMICOLON { StAssign(el) }

expr_list:
  | e = expr { [e] }
  | e = expr COMMA el = expr_list { e :: el }

expr:
  | n = NUMBER { Float n }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | id = ID { Id id }
  | e1 = expr PLUS e2 = expr { BinOp(Add, e1, e2) }
  | e1 = expr MINUS e2 = expr { BinOp(Sub, e1, e2) }
  | e1 = expr MULT e2 = expr { BinOp(Mult, e1, e2) }
  | e1 = expr DIV e2 = expr { BinOp(Div, e1, e2) }
  | e1 = expr EQUAL e2 = expr { BinOp(Equal, e1, e2) }
  | LPAREN e = expr RPAREN { e }
  | CALL LPAREN e = expr RPAREN { Call("Call", [e]) }
  | PUT LPAREN e = expr RPAREN { Call("Put", [e]) }
  | LONGSTOCK LPAREN e = expr RPAREN { Call("LongStock", [e]) }
  | SHORTSTOCK LPAREN e = expr RPAREN { Call("ShortStock", [e]) }
  | SELLCALL LPAREN e = expr RPAREN { Call("SellCall", [e]) }
  | SELLPUT LPAREN e = expr RPAREN { Call("SellPut", [e]) }
  | COLLAR LPAREN e1 = expr COMMA e2 = expr RPAREN { Call("Collar", [e1; e2]) }
  | STRADDLE LPAREN e = expr RPAREN { Call("Straddle", [e]) }
  | SELLSTRADDLE LPAREN e = expr RPAREN { Call("SellStraddle", [e]) }
  | BULLCALLSPREAD LPAREN e1 = expr COMMA e2 = expr RPAREN { Call("BullCallSpread", [e1; e2]) }
  | COLLARWITHENTRY LPAREN e1 = expr COMMA e2 = expr COMMA e3 = expr RPAREN { Call("CollarWithEntry", [e1; e2; e3]) }
  | SHORT LPAREN e = expr RPAREN { Call("Short", [e]) }
  | e1 = expr LPAREN e2 = expr RPAREN { Eval(e1, e2) }
%%
