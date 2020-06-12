(** SubRip format *)

(** A subtitle item. *)
type item

(** The whole subtitle is just a list of items. *)
type t = item list

(** Create an item, given its beginning and ending time, as well as the associated message. *)
val create : Time.t -> Time.t -> string -> item

(** Print a set of subtitles. *)
val print : t -> string

