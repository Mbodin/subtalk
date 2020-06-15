
open ExtLib

type item = {
    begin_time : Time.t ;
    end_time : Time.t ;
    message : string
  }

type t = item list

let create b e m = {
    begin_time = b ;
    end_time = e ;
    message = m
  }


let print_time t =
  let t = Time.explode t in
  Printf.sprintf "%d:%d:%d,%d" t.hours t.minutes t.seconds t.milliseconds

let print_duration b e =
  Printf.sprintf "%s --> %s" (print_time b) (print_time e)

let print_item i =
  Printf.sprintf "%s\n%s\n" (print_duration i.begin_time i.end_time) i.message

let print l =
  String.concat "\n" (List.mapi (fun i it ->
    Printf.sprintf "%d\n%s\n" (1 + i) (print_item it)) l)

let parse_time str =
  try Scanf.sscanf str "%d:%d:%d,%d%!"
        (fun h m s ms ->
          Some (Time.implode {
              Time.hours = h ;
              Time.minutes = m ;
              Time.seconds = s ;
              Time.milliseconds = ms
            }))
  with Scanf.Scan_failure _ -> None

(** The state of the importation *)
type import_state =
  | Number (** Expect a number *)
  | Duration (** Expect a duration *)
  | Message of item (** Expect a message, which will be added to this item. *)

let import str =
  let file = String.split_on_char '\n' str in
  let file = List.map String.trim file in
  let (st, r) =
    List.fold_left (fun (st, t) str ->
      match st with
      | Number ->
        if str = "" then (Number, t)
        else (
          try ignore (int_of_string str) ;
              (Duration, t)
          with Failure _ -> invalid_arg ("Expected a number, but got “" ^ str ^ "”.")
        )
      | Duration ->
        (match try Scanf.sscanf str "%s --> %s%!" (fun b e -> (parse_time b, parse_time e))
               with Scanf.Scan_failure _ -> (None, None) with
         | Some b, Some e ->
           (Message { begin_time = b ; end_time = e ; message = "" }, t)
         | _ -> invalid_arg ("Unexpected string: “" ^ str ^ "”"))
      | Message item ->
        if str = "" then (Number, item :: t)
        else (Message {item with message = item.message ^ "\n" ^ str }, t)
      ) (Number, []) file in
  let r = List.rev r in
  match st with
  | Message item -> item :: r
  | _ -> r

