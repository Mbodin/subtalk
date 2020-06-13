(** Counting commands *)

(** Count the (Unicode) length of a string. *)
val length : string -> int

(** Count how many syllables a string has.
   More precisely, how many syllables-time a string needs to be pronounced.
   In particular, commas and other symbols are considered to last some additional time. *)
val syllables : string -> int

(** Count the number of pauses in a string. *)
val pauses : string -> int

