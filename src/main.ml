
(** Reencoding a string to UTF-8. *)
let recode ?encoding src =
  let rec loop d e = match Uutf.decode d with
  | `Uchar _ as u -> ignore (Uutf.encode e u); loop d e
  | `End -> ignore (Uutf.encode e `End)
  | `Malformed _ -> ignore (Uutf.encode e (`Uchar Uutf.u_rep)); loop d e
  | `Await -> assert false in
  let nln = Some (`NLF (Uchar.of_char '\n')) in
  let d = Uutf.decoder ?nln ?encoding (`String src) in
  let dst = Buffer.create (String.length src) in
  let e = Uutf.encoder `UTF_8 (`Buffer dst) in
  loop d e ;
  Buffer.contents dst


(** SubRip-related functions. *)

let print_time t =
  let t = Time.explode t in
  Printf.sprintf "%02d:%02d:%02d,%03d" t.hours t.minutes t.seconds t.milliseconds

let print_duration (b, e) =
  Printf.sprintf "%s --> %s" (print_time b) (print_time e)

let print_subrib l =
  String.concat "\n" (List.mapi (fun i (b, e, str) ->
    Printf.sprintf "%d\n%s\n%s\n" i (print_duration (b, e)) str) l)


(** Arguments of the program. *)

let input = ref "-"
let output = ref "-"
let length = ref (Time.minutes 0)

let set_length str =
  match Time.parse str with
  | None -> failwith ("Can’t parse “" ^ str ^ "” as a time.  Please use metric units.")
  | Some t -> length := t

let set r str = r := str

let arguments = [
    ("-l", Arg.String set_length, "Set the total length of the talk (example: “10m45s”)") ;
    ("-i", Arg.String (set input), "Set the input file (“-” for standard input)") ;
    ("-o", Arg.String (set output), "Set the output file (“-” for standard output)")
  ]

let usage = "Available options:"

(** Main program. *)

let _ = Arg.parse arguments print_endline usage

let _ =
  let input =
    if !input = "-" then stdin else open_in !input in
  let output =
    if !output = "-" then stdout else open_out !output in
  let file =
    recode (Std.input_all input) in
  close_in input ;
  let sentences =
    Uuseg_string.fold_utf_8 `Line_break (fun l line ->
      if Re.Str.string_match (Re.Str.regexp "[ \t\n\r]*") line 0 then l
      else line :: l) [] file in
  ignore sentences ; (* TODO *)
  Printf.fprintf output "%s" (print_time !length) ;
  close_out output ;
  ()

