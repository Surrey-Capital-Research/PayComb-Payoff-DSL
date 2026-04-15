open Ast

type value =
  | VFloat of float
  | VBool of bool
  | VPayoff of Payoff_codegen.payoff

module Env = Map.Make(String)
type env = value Env.t

type state = {
  env: env;
  st_values: float list;
}

let empty_state = {
  env = Env.empty;
  st_values = [];
}

let rec eval_expr env = function
  | Float f -> VFloat f
  | Bool b -> VBool b
  | Id id ->
      (match Env.find_opt id env with
       | Some v -> v
       | None -> failwith ("Undefined variable: " ^ id))
  | BinOp (op, e1, e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match op, v1, v2 with
       | Add, VFloat f1, VFloat f2 -> VFloat (f1 +. f2)
       | Add, VPayoff p1, VPayoff p2 -> VPayoff (Payoff_codegen.Add (p1, p2))
       | Sub, VFloat f1, VFloat f2 -> VFloat (f1 -. f2)
       | Mult, VFloat f1, VFloat f2 -> VFloat (f1 *. f2)
       | Mult, VFloat f1, VPayoff p1 -> VPayoff (Payoff_codegen.Scale (f1, p1))
       | Mult, VPayoff p1, VFloat f1 -> VPayoff (Payoff_codegen.Scale (f1, p1))
       | Div, VFloat f1, VFloat f2 -> VFloat (f1 /. f2)
       | Equal, VFloat f1, VFloat f2 -> VBool (f1 = f2)
       | Equal, VBool b1, VBool b2 -> VBool (b1 = b2)
       | Equal, VPayoff p1, VPayoff p2 -> VBool (p1 = p2)
       | _ -> failwith "Invalid operation or types")
  | Call (name, args) ->
      let arg_values = List.map (eval_expr env) args in
      (match name, arg_values with
       | "Call", [VFloat k] -> VPayoff (Payoff_codegen.call k)
       | "Put", [VFloat k] -> VPayoff (Payoff_codegen.put k)
       | "LongStock", [VFloat s] -> VPayoff (Payoff_codegen.long_stock s)
       | "ShortStock", [VFloat s] -> VPayoff (Payoff_codegen.short_stock s)
       | "SellCall", [VFloat k] -> VPayoff (Payoff_codegen.short_call k)
       | "SellPut", [VFloat k] -> VPayoff (Payoff_codegen.short_put k)
       | "Collar", [VFloat k1; VFloat k2] -> VPayoff (Payoff_codegen.collar k1 k2)
       | "Straddle", [VFloat k] -> VPayoff (Payoff_codegen.straddle k)
       | "SellStraddle", [VFloat k] -> VPayoff (Payoff_codegen.short_straddle k)
       | "BullCallSpread", [VFloat k1; VFloat k2] -> VPayoff (Payoff_codegen.bull_call_spread k1 k2)
       | "CollarWithEntry", [VFloat s0; VFloat k1; VFloat k2] -> VPayoff (Payoff_codegen.collar_with_entry s0 k1 k2)
       | "Short", [VPayoff p] -> VPayoff (Payoff_codegen.short p)
       | _ -> failwith ("Unknown function or incorrect arguments: " ^ name))
  | Eval (e1, e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VPayoff p, VFloat s -> VFloat (Payoff_codegen.eval p s)
       | _ -> failwith "Evaluation requires a payoff and a number")

let print_value st_values = function
  | VFloat f -> Printf.printf "%.2f\n" f
  | VBool b -> Printf.printf "%b\n" b
  | VPayoff p ->
      if st_values = [] then
        print_endline "Error: No ST values defined for payoff printing."
      else
        begin
          Printf.printf "ST\t";
          List.iter (fun s -> Printf.printf "\t%.2f" s) st_values;
          Printf.printf "\noutput\t";
          List.iter (fun s -> Printf.printf "\t%.2f" (Payoff_codegen.eval p s)) st_values;
          Printf.printf "\n"
        end

let eval_stmt state = function
  | Let (id, e) ->
      let v = eval_expr state.env e in
      { state with env = Env.add id v state.env }
  | Print e ->
      let v = eval_expr state.env e in
      print_value state.st_values v;
      state
  | StAssign el ->
      let values = List.map (fun e ->
        match eval_expr state.env e with
        | VFloat f -> f
        | _ -> failwith "ST values must be numbers") el
      in
      { state with st_values = values }

let eval_program prog =
  ignore (List.fold_left eval_stmt empty_state prog)
