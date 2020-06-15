
open ExtLib

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


(** Program modes, stating how lines should be counted. *)
type counting_mode =
  | Syllables (** Count syllables, default *)
  | SimpleLength (** Count the number of characters *)
  | Equality (** Just always return one *)

let count_function = function
  | Syllables -> Count.syllables
  | SimpleLength -> Count.length
  | Equality -> (fun _ -> 1)

let count_word = function
  | Syllables -> "syllable"
  | SimpleLength -> "character"
  | Equality -> "sentence"

(** Arguments of the program. *)

let input = ref "-"
let output = ref "-"
let length = ref (Time.minutes 0)
let pause = ref (Time.milliseconds 500)
let quiet = ref false
let group = ref 1
let mode = ref Syllables
let subrip = ref false

let set_time r str =
  match Time.parse str with
  | None -> failwith ("Can’t parse “" ^ str ^ "” as a time.")
  | Some t -> r := t

let set = (:=)

let arguments = [
    ("-l", Arg.String (set_time length), "Set the total length of the talk (example: “10m”)") ;
    ("-p", Arg.String (set_time pause), "Set the length of a pause (example: “300ms”)") ;
    ("-g", Arg.Int (set group), "Group the N consecutive lines in each subtitle") ;
    ("-y", Arg.Unit (fun _ -> mode := Syllables), "Weight sentences by syllables (default)") ;
    ("-s", Arg.Unit (fun _ -> mode := SimpleLength), "Weight sentences by their length") ;
    ("-e", Arg.Unit (fun _ -> mode := Equality), "Weight all sentences the same way") ;
    ("-q", Arg.Set quiet, "Do not display any information") ;
    ("-r", Arg.Set subrip, "The input is itself a SubRip file") ;
    ("-i", Arg.String (set input), "Set the input file (“-” for standard input)") ;
    ("-o", Arg.String (set output), "Set the output file (“-” for standard output)")
  ]

let usage = "Available options:"

(** Main program. *)

let _ = Arg.parse arguments print_endline usage

let _ =
  let quiet = !quiet in
  let input =
    if !input = "-" then stdin else open_in !input in
  let output =
    if !output = "-" then stdout else open_out !output in
  (** Reading the input. *)
  let file =
    recode (Std.input_all input) in
  close_in input ;
  let sentences =
    if !subrip then (
      List.concat (List.map (fun i ->
        String.split_on_char '\n' i.Subrip.message) (Subrip.import file))
    ) else (
      List.fold_left (fun l line ->
        if Re.Str.string_match (Re.Str.regexp "\\(.*[^ \t\n\r]\\)[ \t\n\r]*$") line 0 then
          let line =
            try Re.Str.matched_group 1 line
            with Not_found -> assert false in
          line :: l
        else l) [] (String.split_on_char '\n' file)
    ) in
  (** Counting how many syllables there are. *)
  let count = count_function !mode in
  let sentences =
    List.map (fun sentence ->
      (Count.pauses sentence, count sentence, sentence)) sentences in
  let (_, sentences) =
    let group_state = !group - 1 in
    List.fold_left (fun (next, sentences) (pause, syllable, sentence) ->
      let next = sentence :: List.take group_state next in
      let sentence = String.concat " /\n" next in
      (next, (pause, syllable, sentence) :: sentences)) ([], []) sentences in
  let (pauses, syllables) =
    List.fold_left (fun (pauses, syllables) (pause, syllable, sentence) ->
      (pauses + pause, syllables + syllable)) (0, 0) sentences in
  (** Computing the length of a syllable. *)
  let length = !length in
  let pause = !pause in
  if not quiet then (
    Printf.printf "Total length: %s\n" (Time.print length) ;
    Printf.printf "Length of a pause: %s\n" (Time.print pause) ;
    Printf.printf "Total pauses: %d\n" pauses ;
    Printf.printf "Total %ss: %d\n" (count_word !mode) syllables ;
  ) ;
  let time_left = Time.sub length (Time.mult pause pauses) in
  if not (Time.positive time_left) && not quiet then
    Printf.eprintf "Warning: There are more pauses than total time.\n%!" ;
  let base =
    match Time.div time_left syllables with
    | None ->
      if not quiet then
        Printf.eprintf "Warning: No syllable found.\n%!" ;
      Time.milliseconds 0
    | Some t ->
      if not quiet then
        Printf.printf "Length of a %s: %s\n" (count_word !mode) (Time.print t) ;
      t in
  (** Creating the subtitles *)
  let (end_time, subrip) =
    List.fold_left (fun (time, acc) (pauses, syllables, sentence) ->
      let length =
        Time.add (Time.mult pause pauses) (Time.mult base syllables) in
      let time' = Time.add time length in
      (time', Subrip.create time time' sentence :: acc)) (Time.milliseconds 0, []) sentences in
  let subrip = List.rev subrip in
  if not quiet then
    Printf.printf "Actual end time: %s\n" (Time.print end_time) ;
  Printf.fprintf output "%s" (Subrip.print subrip) ;
  close_out output

