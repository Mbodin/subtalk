
(** We simply store the number of milliseconds. *)
type t = int

(** Factors *)
let second = 1000
let minute = 60 * second
let hour = 60 * minute

let hours h = hour * h 
let minutes m = minute * m
let seconds s = second * s

let get t =
  let ms = t mod second in
  let t = t / second in
  let s = t mod minute in
  let t = t / minute in
  let m = t mod hour in
  let h = t / hour in {
    hours = h ;
    minutes = m ;
    seconds = s ;
    milliseconds = ms
  }

let add = (+)

let opp = (~-)

let mult = ( * )

let div t i =
  if i = 0 then None else Some (t / i)

let explode s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

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

let parse str =
  let rec aux acc = function
    | None, [] -> Some acc
    | _, [] -> None
    | i, ' ' :: l -> aux acc (i, l)
    | i, c :: l ->
      let i = value i ~default=0 in
      match parse_int c with
      | Some c -> aux acc (Some (10 * i + c), l)
      | None ->
        match c :: l with
        | 'm' :: 's' :: l -> aux (acc + milliseconds i) (None, l)
        | 's' :: l -> aux (acc + seconds i) (None, l)
        | 'm' :: l -> aux (acc + minutes i) (None, l)
        | 'h' :: l -> aux (acc + hours i) (None, l)
        | _ -> None in
  aux 0 (None, explode str)

