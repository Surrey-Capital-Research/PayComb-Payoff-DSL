theory Scratch
  imports Complex_Main
begin

(* \<midarrow>\<midarrow> Helpers for code generation \<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow> *)

definition real_max :: "real \<Rightarrow> real \<Rightarrow> real" where
  "real_max a b = max a b"

definition real_min :: "real \<Rightarrow> real \<Rightarrow> real" where
  "real_min a b = min a b"

(* \<midarrow>\<midarrow> Payoff datatype \<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow> *)

datatype Payoff =
  Underlying |
  Const real |
  Add Payoff Payoff |
  Scale real Payoff |
  Max Payoff Payoff |
  Pos Payoff

fun eval :: "Payoff \<Rightarrow> real \<Rightarrow> real" where
  "eval Underlying    s = s" |
  "eval (Const c)     _ = c" |
  "eval (Add p q)     s = eval p s + eval q s" |
  "eval (Scale c p)   s = c * eval p s" |
  "eval (Max p q)     s = real_max (eval p s) (eval q s)" |
  "eval (Pos p)       s = real_max (eval p s) 0"

definition call :: "real \<Rightarrow> Payoff" where
  "call k = Pos (Add Underlying (Scale (-1) (Const k)))"

definition put :: "real \<Rightarrow> Payoff" where
  "put k = Pos (Add (Const k) (Scale (-1) Underlying))"

definition short :: "Payoff \<Rightarrow> Payoff" where
  "short p = Scale (-1) p"

definition long_underlying :: Payoff where
  "long_underlying = Underlying"

(* \<midarrow>\<midarrow> Positions \<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow> *)

definition long_stock :: "real \<Rightarrow> Payoff" where
  "long_stock S0 = Add Underlying (Scale (-1) (Const S0))"

definition short_stock :: "real \<Rightarrow> Payoff" where
  "short_stock S0 = short (long_stock S0)"

definition long_call :: "real \<Rightarrow> Payoff" where
  "long_call k = call k"

definition short_call :: "real \<Rightarrow> Payoff" where
  "short_call K = short (call K)"

definition long_put :: "real \<Rightarrow> Payoff" where
  "long_put K = put K"

definition short_put :: "real \<Rightarrow> Payoff" where
  "short_put K = short (put K)"

definition bull_call_spread :: "real \<Rightarrow> real \<Rightarrow> Payoff" where
  "bull_call_spread K1 K2 =
     Add (long_call K1) (short_call K2)"

definition straddle :: "real \<Rightarrow> Payoff" where
  "straddle K = Add (long_call K) (long_put K)"

definition short_straddle :: "real \<Rightarrow> Payoff" where
  "short_straddle K = short (straddle K)"

definition collar :: "real \<Rightarrow> real \<Rightarrow> Payoff" where
  "collar K1 K2 =
     Add long_underlying (Add (long_put K1) (short_call K2))"

definition collar_with_entry :: "real \<Rightarrow> real \<Rightarrow> real \<Rightarrow> Payoff" where
  "collar_with_entry S0 K1 K2 =
     Add (long_stock S0)
       (Add (put K1) (short_call K2))"

(* \<midarrow>\<midarrow> Sanity-Check Lemmas \<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow> *)

lemma eval_short: "eval (short p) s = - eval p s"
  unfolding short_def
  by simp

lemma eval_long_stock: "eval (long_stock S0) S = S - S0"
  unfolding long_stock_def
  by simp

lemma eval_short_stock: "eval (short_stock S0) S = - eval (long_stock S0) S"
  unfolding short_stock_def
  using eval_short
  by simp

lemma eval_short_call: "eval (short_call K) S = - eval (long_call K) S"
  unfolding short_call_def long_call_def
  using eval_short
  by simp

lemma eval_short_put: "eval (short_put K) S = - eval (long_put K) S"
  unfolding short_put_def long_put_def
  using eval_short
  by simp

lemma eval_straddle: "eval (straddle K) S = eval (call K) S + eval (put K) S"
  unfolding straddle_def long_call_def long_put_def
  by simp

lemma eval_short_straddle: "eval (short_straddle K) S = - eval (straddle K) S"
  unfolding short_straddle_def
  using eval_short
  by simp

lemma eval_long_underlying: "eval long_underlying S = S"
  unfolding long_underlying_def
  by simp

lemma eval_collar_with_entry:
  "eval (collar_with_entry S0 K1 K2) S =
     (S - S0) + eval (put K1) S - eval (call K2) S"
  unfolding collar_with_entry_def long_stock_def short_call_def short_def
  by simp





(*
  ###################
    Export to OCaml
  ###################
*)

(* \<midarrow>\<midarrow> Map real to OCaml float \<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow> *)

code_printing
  type_constructor real    => (OCaml) "float"
| constant "0 :: real"                   => (OCaml) "0.0"
| constant "1 :: real"                   => (OCaml) "1.0"
| constant "(+) :: real => real => real" => (OCaml) "(_ +. _)"
| constant "(-) :: real => real => real" => (OCaml) "(_ -. _)"
| constant "(*) :: real => real => real" => (OCaml) "(_ *. _)"
| constant "(/) :: real => real => real" => (OCaml) "(_ /. _)"
| constant "uminus :: real => real"      => (OCaml) "(-. _)"
| constant "abs :: real => real"         => (OCaml) "Float.abs _"
| constant real_max                      => (OCaml) "Float.max _ _"
| constant real_min                      => (OCaml) "Float.min _ _"

(* \<midarrow>\<midarrow> Export \<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow>\<midarrow> *)

export_code
  (* core datatype and evaluator *)
  eval

  (* primitive instruments *)
  call
  put
  short
  long_underlying

  (* stock positions *)
  long_stock
  short_stock

  (* option positions *)
  long_call
  short_call
  long_put
  short_put

  (* strategies *)
  bull_call_spread
  straddle
  short_straddle
  collar
  collar_with_entry

in OCaml
  module_name Payoff
  file_prefix "payoff_codegen"


end