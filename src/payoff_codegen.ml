type payoff = Underlying | Const of float | Add of payoff * payoff |
  Scale of float * payoff | Max of payoff * payoff | Pos of payoff;;

let put k = Pos (Add (Const k, Scale ((-. 1.0), Underlying)));;

let call k = Pos (Add (Underlying, Scale ((-. 1.0), Const k)));;

let rec eval x0 s = match x0, s with Underlying, s -> s
               | Const c, _ -> c
               | Add (p, q), s -> ((eval p s) +. (eval q s))
               | Scale (c, p), s -> (c *. (eval p s))
               | Max (p, q), s -> Float.max (eval p s) (eval q s)
               | Pos p, s -> Float.max (eval p s) 0.0;;

let short p = Scale ((-. 1.0), p);;

let long_underlying : payoff = Underlying;;

let short_call k = short (call k);;

let long_put k = put k;;

let collar k1 k2 = Add (long_underlying, Add (long_put k1, short_call k2));;

let long_call k = call k;;

let straddle k = Add (long_call k, long_put k);;

let short_put k = short (put k);;

let long_stock s0 = Add (Underlying, Scale ((-. 1.0), Const s0));;

let short_stock s0 = short (long_stock s0);;

let short_straddle k = short (straddle k);;

let bull_call_spread k1 k2 = Add (long_call k1, short_call k2);;

let collar_with_entry
  s0 k1 k2 = Add (long_stock s0, Add (put k1, short_call k2));;
