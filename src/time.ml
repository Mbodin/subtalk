
open ExtLib

(** We simply store the number of milliseconds. *)
type t = int

type t' = {
    hours : int ;
    minutes : int ;
    seconds : int ;
    milliseconds : int
  }

(** Factors *)
let second = 1000
let minute = 60 * second
let hour = 60 * minute

let hours h = hour * h 
let minutes m = minute * m
let seconds s = second * s
let milliseconds m = m

let explode t =
  let ms = t mod 1000 in
  let t = t / 1000 in
  let s = t mod 60 in
  let t = t / 60 in
  let m = t mod 60 in
  let h = t / 60 in {
    hours = h ;
    minutes = m ;
    seconds = s ;
    milliseconds = ms
  }

let implode t =
  hours t.hours + minutes t.minutes + seconds t.seconds + milliseconds t.milliseconds

let positive t = t >= 0

let add = (+)

let sub = (-)

let opp = (~-)

let mult = ( * )

let div t i =
  if i = 0 then None else Some (t / i)

let parse_int = function
  | '0' -> Some 0
  | '1' -> Some 1
  | '2' -> Some 2
  | '3' -> Some 3
  | '4' -> Some 4
  | '5' -> Some 5
  | '6' -> Some 6
  | '7' -> Some 7
  | '8' -> Some 8
  | '9' -> Some 9
  | _ -> None

let print t =
  if t = 0 then "0s"
  else
    let t = explode t in
    let p v u =
      if v <> 0 then Printf.sprintf "%d%s" v u
      else "" in
    String.concat "" [
        p t.hours "h" ;
        p t.minutes "m" ;
        p t.seconds "s" ;
        p t.milliseconds "ms"
      ]

let parse str =
  let rec aux acc = function
    | None, [] -> Some acc
    | _, [] -> None
    | i, (' ' | '\t') :: l -> aux acc (i, l)
    | i, c :: l ->
      let i = Option.default 0 i in
      match parse_int c with
      | Some c -> aux acc (Some (10 * i + c), l)
      | None ->
        match c :: l with
        | 'm' :: 's' :: l -> aux (acc + milliseconds i) (None, l)
        | 's' :: l -> aux (acc + seconds i) (None, l)
        | 'm' :: l -> aux (acc + minutes i) (None, l)
        | 'h' :: l -> aux (acc + hours i) (None, l)
        | _ -> None in
  aux 0 (None, String.explode str)

