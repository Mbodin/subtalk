(** Time manipulation *)

(** A (possibly negative) duration. *)
type t

(** Create a duration from hours, minutes, seconds, or milliseconds.
   They may be negative. *)
val hours : int -> t
val minutes : int -> t
val seconds : int -> t
val milliseconds : int -> t

(** The return type of [explode]. *)
type t' = {
    hours : int ;
    minutes : int ;
    seconds : int ;
    milliseconds : int
  }

(** Convert a duration into hours, minutes, seconds, and milliseconds. *)
val explode : t -> t'

(** Reverse [explode]. *)
val implode : t' -> t

(** Add two durations. *)
val add : t -> t -> t

(** Takes the opposite of a duration (changing its sign). *)
val opp : t -> t

(** Divides a duration.
   Returns [None] if the integer is zero. *)
val div : t -> int -> t option

(** Multiply a duration. *)
val mult : t -> int -> t

(** Parse a time in a string. *)
val parse : string -> t option

