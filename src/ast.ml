type binop = Add | Sub | Mult | Div | Equal

type expr =
  | Float of float
  | Bool of bool
  | Id of string
  | BinOp of binop * expr * expr
  | Call of string * expr list
  | Eval of expr * expr

type stmt =
  | Let of string * expr
  | Print of expr
  | StAssign of expr list

type program = stmt list
