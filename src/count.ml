
open ExtLib

let length =
  Uuseg_string.fold_utf_8 `Grapheme_cluster (fun x _ -> x + 1) 0

(** The state of the automaton to count on syllables.
 * It describes what kind of character was the previous character: *)
type state =
  | Vowel (** A vowel *)
  | Consonant (** A consonant *)
  | Other (** Another kind *)

(** Return the kind of a character. *)
let get_kind c =
  let c = Char.lowercase_ascii c in
  if c < 'a' || c > 'z' then Other
  else if List.mem c ['a'; 'e'; 'i'; 'o'; 'u'; 'y'] then Vowel
  else Consonant

let syllables str =
  let str = String.explode str in
  (** We first prune off the string a little. *)
  let (_, str) =
    List.fold_left (fun (b, str) c ->
      match b, c with
      | Some '\195', _ ->
        (None, 'a' :: str) (** Wild guess here: if it starts with '\195',
                               it’s possibly an accentuated vowel. *)
      | _, c -> (Some c, c :: str)) (None, []) str in
  (** We then enter the main function. *)
  let (n, _) =
    List.fold_left (fun (n, state) -> function
        | ',' | ';' -> (1 + n, Other) (** Commas and semicolons are worth one syllable. *)
        | ':' | '(' -> (2 + n, Other) (** Colons and (beginning of) parenthesese are worth two syllables. *)
        | '.' | '?' | '!' -> (3 + n, Other) (** A dot is worth three syllables. *)
        | c ->
          let s = get_kind c in
          let n =
            match state, s with
            | (Consonant | Other), Vowel -> 1 + n
            | _, _ -> n in
          (n, s)) (0, Other) str in
  max 1 n

let pauses str =
  let str = String.explode str in
  List.fold_left (fun n -> function
    | '*' -> 1 + n
    | _ -> n) 0 str

