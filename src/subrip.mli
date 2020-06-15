(** SubRip format *)

(** A subtitle item. *)
type item = {
    begin_time : Time.t ; (** Start time of the subtitle. *)
    end_time : Time.t ; (** End time of the subtitle. *)
    message : string (** Message displayed (may spans over several lines) *)
  }

(** The whole subtitle is just a list of items. *)
type t = item list

(** Create an item, given its beginning and ending time, as well as the associated message. *)
val create : Time.t -> Time.t -> string -> item

(** Print a set of subtitles. *)
val print : t -> string

(** Import a SubRip file from a string. *)
val import : string -> t

(** Parse a time as shown in a SubRip file. *)
val parse_time : string -> Time.t option

