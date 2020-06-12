
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
  Printf.sprintf "%02d:%02d:%02d,%03d" t.hours t.minutes t.seconds t.milliseconds

let print_duration b e =
  Printf.sprintf "%s --> %s" (print_time b) (print_time e)

let print_item i =
  Printf.sprintf "%s\n%s\n" (print_duration i.begin_time i.end_time) i.message

let print l =
  String.concat "\n" (List.mapi (fun i it ->
    Printf.sprintf "%d\n%s\n" (1 + i) (print_item it)) l)

