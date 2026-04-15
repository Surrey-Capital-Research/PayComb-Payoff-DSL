type payoff =
  | Underlying
  | Const of float
  | Add of payoff * payoff
  | Scale of float * payoff
  | Max of payoff * payoff
  | Pos of payoff

val put : float -> payoff
val call : float -> payoff
val eval : payoff -> float -> float
val short : payoff -> payoff
val long_underlying : payoff
val short_call : float -> payoff
val long_put : float -> payoff
val collar : float -> float -> payoff
val long_call : float -> payoff
val straddle : float -> payoff
val short_put : float -> payoff
val long_stock : float -> payoff
val short_stock : float -> payoff
val short_straddle : float -> payoff
val bull_call_spread : float -> float -> payoff
val collar_with_entry : float -> float -> float -> payoff
