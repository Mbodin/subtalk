
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
  () (* TODO *)

