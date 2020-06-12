(** Counting commands *)

(** Count how many syllables a string has.
   More precisely, how many syllables-time a string needs to be pronounced.
   In particular, commas and dots are considered to lasts some additional time. *)
val syllables : string -> int

(** Count the number of pauses in a string. *)
val pauses : string -> int

