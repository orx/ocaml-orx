module type S = sig
  type ptr
  type handle
  val default_handle : handle
  val make_handle : unit -> handle
  val retain : handle -> ptr -> unit
  val release : handle -> (ptr -> Orx_gen.Status.t) -> unit
  val release_all : (ptr -> Orx_gen.Status.t) -> unit
end

module Make (Ptr : Foreign.Funptr) : S with type ptr := Ptr.t
