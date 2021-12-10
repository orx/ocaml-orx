type camera
type obj

module Status : sig
  (** {1 Specialization of {!Stdlib.result} values for orx} *)

  type 'ok result = ('ok, [ `Orx ]) Stdlib.result
  (** Errors are all grouped as [`Orx]. *)

  type t = unit result
  (** Status of a side effect only operation. *)

  val ok : t
  (** Success! *)

  val error : t
  (** Not success! *)

  val open_error : 'ok result -> ('ok, [> `Orx ]) Stdlib.result
  (** Convenience function to open the [`Orx] type to make composing results
      from other libraries easier. *)

  val get : t -> unit
  (** [get result] is [()] if [result] is [Ok ()], otherwise it raises
      {!Invalid_argument}. *)

  val get_ok : 'ok result -> 'ok
  (** [get_ok result] is [o] if [result] is [Ok o], otherwise it raises
      {!Invalid_argument}. *)

  val ignore : t -> unit
  (** [ignore result] is {!Stdlib.ignore} constrained for more precise type
      checking. *)
end

module Log : sig
  (** {!Logging using the orx engine's logger}

      These functions use orx's logging functionality. Log output will only be
      shown when building against a debug build of orx. Release builds disable
      logging. *)

  type 'a format_logger =
    ('a, Format.formatter, unit, unit, unit, unit) format6 -> 'a
  (** All formatting functions act as standard {!Stdlib.Format} formatters. *)

  val log : 'a format_logger
  (** Log with output going to all of Orx's log targets. *)

  val terminal : 'a format_logger
  (** Log with output going to the terminal. *)

  val file : 'a format_logger
  (** Log with output going to Orx's log file(s). *)

  val console : 'a format_logger
  (** Log with output going to the Orx console. *)
end

module String_id : sig
  (** {1 Locally unique IDs for registered strings} *)

  type t
  (** A unique ID for a registered string. *)

  val undefined : t
  (** ID used to represent undefined/unregistered strings. *)

  val get_id : string -> t
  (** [get_id s] registers [s] if it has not been registered already and returns
      the ID associated with [s]. *)

  val get_from_id : t -> string
  (** [get_from_id id] returns the string associated with [id]. If no string is
      associated with [id] then the return value is an empty string. *)
end

module Parent : sig
  (** {1 Parent values for nesting structures} *)

  (** Possible parents *)
  type t =
    | Camera of camera
    | Object of obj
end

module Structure : sig
  (** {1 General orx engine structures}

      From https://orx-project.org/orx/doc/html/group__orx_structure.html *)

  type t
  (** A structure *)

  module Guid : sig
    type t
    (** {1 Unique IDs for structures}

        These IDs are unique for a single process. They are a safe way to track
        stuctures such as objects across time. *)

    val compare : t -> t -> int
    (** A total order comparison for {!t} values. The actual order does not hold
        important semantic meaning but this does allow for easy use of
        {!Stdlib.Set.Make} and {!Stdlib.Map.Make}. *)

    val equal : t -> t -> bool
    (** Equality for {!t} values. *)

    val pp : Format.formatter -> t -> unit
    (** Pretty-printer for {!t} values with an unspecified respresentation. *)

    val to_string : t -> string
    (** [to_string id] is a string representation of [id]. It can be used for
        logging, storing in config, commands or anywhere else a {!t} value might
        be persisted. *)

    val of_string : string -> t
    (** [of_string s] is {!t} parsed from [s].

        @raise Failure
          if [s] is not a valid {!t}. Note that a valid {!t} does not
          necessarily mean that value is an active GUID in the current orx
          session. *)
  end
end

module Vector : sig
  (** {1 Three dimensional vectors}

      From https://orx-project.org/orx/doc/html/group__orx_vector.html *)

  type t
  (** A three dimensional [(x, y, z)] vector *)

  val pp : Format.formatter -> t -> unit
  (** Pretty-printer for vector values *)

  val equal : t -> t -> bool
  (** Equality across all three dimensions *)

  val equal_2d : t -> t -> bool
  (** Equality in [(x, y)] only. [z] is ignored. *)

  val get_x : t -> float
  (** [get_x v] is the [x] element of [v]. *)

  val get_y : t -> float
  (** [get_y v] is the [y] element of [v]. *)

  val get_z : t -> float
  (** [get_z v] is the [z] element of [v]. *)

  val get_size : t -> float
  (** [get_size v] is the vector magnitude of [v]. *)

  val make : x:float -> y:float -> z:float -> t
  (** [make ~x ~y ~z] is the vector [(x, y, z)]. *)

  val set_x : t -> float -> unit
  (** [set_x v x'] modifies [v] in place by assigning the magnitude of [v]'s [x]
      as [x']. *)

  val set_y : t -> float -> unit
  (** [set_y v y'] modifies [v] in place by assigning the magnitude of [v]'s [y]
      as [y']. *)

  val set_z : t -> float -> unit
  (** [set_z v z'] modifies [v] in place by assigning the magnitude of [v]'s [z]
      as [z']. *)

  (** {2 Vector operations}

      Each of the following operations has a [f] and [f'] form. The [f] form
      returns a freshly allocated vector with the result of the specified
      operation. The [f'] form takes a [target] which will be modified to
      contain the results of the operation performed by [f'].

      In the case of [f'] functions, the target and source vector can be the
      same value, in which case the source vector will be modified in place. *)

  val copy' : target:t -> t -> unit

  val copy : t -> t

  val normalize' : target:t -> t -> unit

  val normalize : t -> t

  val reciprocal' : target:t -> t -> unit

  val reciprocal : t -> t

  val round' : target:t -> t -> unit

  val round : t -> t

  val floor' : target:t -> t -> unit

  val floor : t -> t

  val neg' : target:t -> t -> unit

  val neg : t -> t

  val add' : target:t -> t -> t -> unit

  val add : t -> t -> t

  val sub' : target:t -> t -> t -> unit

  val sub : t -> t -> t

  val mul' : target:t -> t -> t -> unit

  val mul : t -> t -> t

  val div' : target:t -> t -> t -> unit

  val div : t -> t -> t

  val dot : t -> t -> float

  val dot_2d : t -> t -> float

  val cross' : target:t -> t -> t -> unit

  val cross : t -> t -> t

  val mulf' : target:t -> t -> float -> unit

  val mulf : t -> float -> t

  val divf' : target:t -> t -> float -> unit

  val divf : t -> float -> t

  val rotate_2d' : target:t -> t -> float -> unit

  val rotate_2d : t -> float -> t

  val lerp' : target:t -> t -> t -> float -> unit

  val lerp : t -> t -> float -> t

  val move_x : t -> float -> unit

  val move_y : t -> float -> unit

  val move_z : t -> float -> unit

  val of_rotation : float -> t

  val to_rotation : t -> float
end

module Obox : sig
  (** {1 Oriented boxes}

      From https://orx-project.org/orx/doc/html/group__orx_o_box.html *)

  type t

  val make : pos:Vector.t -> pivot:Vector.t -> size:Vector.t -> float -> t

  val copy : t -> t

  val get_center : t -> Vector.t

  val move : t -> Vector.t -> t

  val rotate_2d : t -> float -> t

  val is_inside : t -> Vector.t -> bool

  val is_inside_2d : t -> Vector.t -> bool
end

module Module_id : sig
  (** {1 Engine module IDs}

      From https://orx-project.org/orx/doc/html/group__orx_module.html *)

  type t =
    | Clock
    | Main
end

module Clock_modifier : sig
  (** {1 Game clock modifiers}

      From https://orx-project.org/orx/doc/html/group__orx_clock.html *)

  type t =
    | Fixed
    | Multiply
    | Maxed
    | Average
end

module Clock_priority : sig
  (** {1 Clock callback priorities}

      From https://orx-project.org/orx/doc/html/group__orx_clock.html *)

  type t =
    | Lowest
    | Lower
    | Low
    | Normal
    | High
    | Higher
    | Highest
end

module Clock : sig
  (** {1 Engine clocks}

      From https://orx-project.org/orx/doc/html/group__orx_clock.html *)

  type t
  (** A game clock. Clocks are unique by name within a process. *)

  module Info : sig
    (** {1 Clock information}

        From https://orx-project.org/orx/doc/html/group__orx_clock.html *)

    type clock = t

    type t
    (** Clock information passed to a clock's callback function *)

    val get_tick_size : t -> float
    (** Tick size of the clock associated with this clock info *)

    val get_dt : t -> float
    (** Time since the last clock tick *)

    val get_time : t -> float
    (** Current overall time for a clock *)

    val get_clock : t -> clock option
    (** Get the clock associated with a clock info value *)
  end

  val compare : t -> t -> int
  (** A total order comparison for {!t} values. The actual order does not hold
      important semantic meaning but this does allow for easy use of
      {!Stdlib.Set.Make} and {!Stdlib.Map.Make}. *)

  val equal : t -> t -> bool
  (** Equality for {!t} values *)

  val create_from_config : string -> t option
  (** [create_from_config name] creates and returns the clock under config
      section [name], or [None] if a valid clock is not defined under [name]. *)

  val create_from_config_exn : string -> t
  (** [create_from_config_exn name] creates and returns the clock under config
      section [name].

      @raise Invalid_argument if a valid clock is not defined under [name]. *)

  val create : float -> t
  (** [create tick_size] creates a new clock with [tick_size] defined in
      seconds. *)

  val get : string -> t option
  (** [get name] gets the clock named [name] if it exists. *)

  val get_exn : string -> t
  (** [get_exn name] gets the clock named [name].

      @raise Invalid_argument if [name] is not a valid clock. *)

  val get_core : unit -> t
  (** [get_core ()] returns the core engine clock. *)

  val get_name : t -> string
  (** [get_name clock] is [clock]'s config name. *)

  val get_info : t -> Info.t

  val get_modifier : t -> Clock_modifier.t -> float

  val set_modifier : t -> Clock_modifier.t -> float -> unit

  val set_tick_size : t -> float -> unit

  val restart : t -> Status.t

  val pause : t -> unit

  val unpause : t -> unit

  val is_paused : t -> bool

  (** {2 Callbacks}

      Clock callbacks fire on each tick of a clock. *)

  module Callback_handle : sig
    (** {1 Callback handles}

        Callbacks are associated with handles. These handles may be used to
        unregister callbacks associated with them. *)

    type t

    val default : t
    (** The default handle for all callbacks registered to a clock without an
        explicitly provided callback handle. *)

    val make : unit -> t
    (** [make ()] is a fresh callback handle with no callbacks associated with
        it. *)
  end

  val register :
    ?handle:Callback_handle.t ->
    ?module_id:Module_id.t ->
    ?priority:Clock_priority.t ->
    t ->
    (Info.t -> unit) ->
    unit
  (** [register ?handle ?module_id ?priority clock callback] registers
      [callback] so that it will be called on each tick of [clock].

      @param handle
        Can be provided when a callback should not exist for the entire
        remaining lifetime of a clock, allowing callbacks to be unregistered.
        Defaults to {!Callback_handle.default}.
      @param orx_module
        ID of the module related to this callback. Defaults to
        {!Module_id.Main}.
      @param priority
        Priority of callback. Defaults to {!Clock_priority.Normal}. *)

  val unregister : t -> Callback_handle.t -> unit
  (** [unregister clock handle] unregisters all callbacks associated with
      [clock] and [handle]. *)

  val unregister_all : t -> unit
  (** [unregister_all clock] unregisters all callbacks associated with [clock]. *)

  (** {2 Timers}

      Timers fire one or more times, after a specified delay. *)

  module Timer_handle : sig
    (** {1 Callback handles}

        Callbacks are associated with handles. These handles may be used to
        unregister callbacks associated with them. *)

    type t

    val default : t
    (** The default handle for all callbacks registered to a clock without an
        explicitly provided callback handle. *)

    val make : unit -> t
    (** [make ()] is a fresh callback handle with no callbacks associated with
        it. *)
  end

  val add_timer :
    ?handle:Timer_handle.t -> t -> (Info.t -> unit) -> float -> int -> unit
  (** [add_timer ?handle clock callback delay repetition] registers [callback]
      with [clock] as a timer callback.

      @param delay Specifies the delay between calls to [callback]
      @param repetition
        Specifies the number of times [callback] should be called before it's
        deregistered. Use [-1] to specify that [timer] should keep being called
        forever. *)

  val remove_timer : t -> Timer_handle.t -> unit
  (** [remove_timer clock handle] removes the timers associated with [handle]
      from [clock]. Timers with a finite number of repetitions will be
      automatically removed once they have run out of repetitions. *)

  val remove_all_timers : t -> unit
  (** [remove_all_timers clock] removes all timers associated with [clock]. *)
end

module Texture : sig
  (** {1 Textures for in game graphics}

      From https://orx-project.org/orx/doc/html/group__orx_texture.html *)

  type t
  (** A single texture *)

  val create_from_file : string -> bool -> t option
  (** [create_from_file path keep_in_cache] creates a texture from the file at
      [path].

      @param keep_in_cache
        Specifies if a texture should be kept active in orx's cache even when
        there are no more active references to it. *)

  val delete : t -> Status.t
  (** [delete texture] deletes [texture]. *)

  val clear_cache : unit -> Status.t
  (** [clear_cache ()] will clear any unreferenced textures from orx's cache. *)

  val get_size : t -> float * float
  (** [get_size texture] retrieves the dimensions of [texture]. *)
end

module Graphic : sig
  (** {1 Graphic module for 2D graphics}

      From https://orx-project.org/orx/doc/html/group__orx_graphic.html *)

  type t
  (** An in engine graphic *)

  val create : unit -> t option
  (** [create ()] creates a fresh graphic. *)

  val create_from_config : string -> t option
  (** [create_from_config section_name] createes the graphic defined under
      [section_name] in config if it's properly defined. *)

  val delete : t -> Status.t

  val set_size : t -> Vector.t -> unit

  val get_size : t -> Vector.t

  val set_origin : t -> Vector.t -> unit

  val get_origin : t -> Vector.t

  val set_flip : t -> x:bool -> y:bool -> unit

  val set_pivot : t -> Vector.t -> unit

  val set_data : t -> Structure.t -> Status.t

  val to_structure : t -> Structure.t
end

module Sound_status : sig
  type t =
    | Play
    | Pause
    | Stop
end

module Sound : sig
  (** {1 Sound playback}

      From https://orx-project.org/orx/doc/html/group__orx_sound.html *)

  type t
  (** A sound *)

  val create_from_config : string -> t option
  (** [create_from_config section_name] creates a sound from the configuration
      in [section_name] from config if it defines a valid sound. *)

  val get_name : t -> string
  (** [get_name sound] is the config section name of [sound]. *)

  val get_status : t -> Sound_status.t
  (** [get_status sound] is the playback status of [sound]. *)

  val play : t -> unit

  val pause : t -> unit

  val stop : t -> unit

  val get_duration : t -> float

  val get_pitch : t -> float

  val set_pitch : t -> float -> unit

  val get_volume : t -> float

  val set_volume : t -> float -> unit
end

module Resource : sig
  (** {1 Engine resources}

      From https://orx-project.org/orx/doc/html/group__orx_resource.html *)

  type group =
    | Config
    | Sound
    | Texture
    | Custom of string

  val group_of_string : string -> group
  val string_of_group : group -> string

  val add_storage : group -> string -> bool -> Status.t
  (** [add_storage group description add_first] adds [description] as a storage
      source for [group]. Storage sources depend on the type of storage being
      used. By default this will be a filesystem path, but other resource
      systems can be defined and used with orx.

      @param add_first
        If [true] then [description] will be checked before all previously
        defined storage systems. If [false] then [description] will be checked
        after. *)

  val remove_storage : group option -> string option -> Status.t
  (** [remove_storage group description] removes [description] from [group].

      @param group
        If [group] is [None] then [description] will be removed from all groups.
      @param description
        If [description] is [None] then all storages will be removed from
        [group]. *)

  val reload_storage : unit -> Status.t
  (** [reload_storage ()] forces orx to reload all storages from config. *)

  val sync : group option -> Status.t
  (** [sync group] synchronizes all storages associated with [group] with their
      source material.

      @param group
        If [group] is [None] then all resource groups are synchronized. *)
end

module Mouse_button : sig
  type t =
    | Left
    | Right
    | Middle
    | Extra_1
    | Extra_2
    | Extra_3
    | Extra_4
    | Extra_5
    | Wheel_up
    | Wheel_down
end

module Mouse_axis : sig
  type t =
    | X
    | Y
end

module Mouse : sig
  (** {1 Read mouse state}

      From https://orx-project.org/orx/doc/html/group__orx_mouse.html *)

  val is_button_pressed : Mouse_button.t -> bool

  val get_position : unit -> Vector.t option
  (** [get_position ()] is the current mouse screen position. *)

  val get_move_delta : unit -> Vector.t option
  (** [get_move_delta ()] is the position change since the last call to this
      function. *)

  val get_wheel_delta : unit -> float
  (** [get_wheel_delta ()] is the position change since the last call to this
      function. *)

  val show_cursor : bool -> Status.t

  val set_cursor : string -> Vector.t option -> Status.t
  (** [set_cursor name pivot] sets the mouse's cursor display to [name] and its
      hotspot to [pivot].

      @param name
        Can be standard names (arrow, ibeam, hand, crosshair, hresize or
        vresize) or a file name
      @param pivot
        Can be an offset for the hotspot or [None] to default to [(0, 0)] *)

  val get_button_name : Mouse_button.t -> string
  (** [get_button_name button] is a canonical name for [button] if one exists. *)

  val get_axis_name : Mouse_axis.t -> string
  (** [get_axis_name axis] is a canonical name for [axis] if one exists. *)
end

module Input_type : sig
  type t =
    | Keyboard_key
    | Mouse_button
    | Mouse_axis
    | Joystick_button
    | Joystick_axis
    | External
end

module Input_mode : sig
  type t =
    | Full
    | Positive
    | Negative
end

module Input : sig
  (** {1 General user input handling}

      Orx inputs are defined by name in config. This module allows querying the
      state of inputs.

      From https://orx-project.org/orx/doc/html/group__orx_input.html *)

  val is_active : string -> bool
  (** [is_active input] is [true] if [input] is currently active. *)

  val has_new_status : string -> bool
  (** [has_new_status input] is [true] if [input] has changed status since the
      last time it was checked. *)

  val has_been_activated : string -> bool
  (** [has_been_activated input] is [true] if [input] has been activated since
      the last time it was checked. *)

  val has_been_deactivated : string -> bool
  (** [has_been_deactivated input] is [true] if [input] has been deactivated
      since the last time it was checked. *)

  val get_value : string -> float
  (** [get_value input] is the current value of [input]. For keypresses, this
      will generally be [0.0] or [1.0]. For a joystick the value will scale
      according to the position of the stick along the queried axis. *)

  val get_binding :
    string -> int -> (Input_type.t * int * Input_mode.t) Status.result
  (** [get_binding input index] gives information on [input]'s type and mode. *)

  val get_binding_name : Input_type.t -> int -> Input_mode.t -> string
  (** [get_binding_name input_type binding_id mode] give the name associated
      with [input_type], [binding_id] and [mode]. *)
end

module Physics : sig
  (** {1 General physics engine settings and values}

      From https://orx-project.org/orx/doc/html/group__orx_physics.html *)

  val get_collision_flag_name : Unsigned.UInt32.t -> string
  (** [get_collision_flag_name flag] is the name defined in config matching
      [flag] if one exists, otherwise an empty string. *)

  val get_collision_flag_value : string -> Unsigned.UInt32.t
  (** [get_collision_flag_value name] is the value associated with the named
      collision flag [name] or {!Unsigned.UInt32.zero} if [name] is not a
      defined collision flag. *)

  val check_collision_flag :
    mask:Unsigned.UInt32.t -> flag:Unsigned.UInt32.t -> bool
  (** [check_collision_flag ~mask ~flag] indicates if [mask] and [flag] would
      collide. *)

  val get_gravity : unit -> Vector.t
  (** [get_gravity ()] is the current world gravity. *)

  val set_gravity : Vector.t -> unit
  (** [set_gravity v] sets the current world gravity to [v]. *)

  val enable_simulation : bool -> unit
  (** [enable_simulation enabled] enables or disables the world physics
      simulation. Can be used when the game simulation is paused, for example. *)
end

module Body_part : sig
  (** {1 Body parts for physics simulation}

      For physics body parts, flags specify the collision bitmask for a part. A
      mask specifies the flags for other bodies which a part should collide
      with.

      From https://orx-project.org/orx/doc/html/group__orx_body.html *)

  type t
  (** A single body part *)

  val get_name : t -> string
  (** [get_name part] is the config name associated with [part]. *)

  val set_self_flags : t -> int -> unit
  (** [set_self_flags part flags] sets the collision flags for [part] to
      [flags]. *)

  val get_self_flags : t -> int
  (** [get_self_flags part] is the current collision flags for [part]. *)

  val set_check_mask : t -> int -> unit
  (** [set_check_mask part mask] sets the check mask for [part]. *)

  val get_check_mask : t -> int
  (** [get_check_mask part] is the current check mask for [part]. *)
end

module Body : sig
  (** {1 Physics bodies}

      A physics body may be made up of one or more parts a defined in
      {!Body_part}.

      From https://orx-project.org/orx/doc/html/group__orx_body.html *)

  type t
  (** A single physics body *)

  val get_parts : t -> Body_part.t Seq.t
  (** [get_parts body] is the sequence of parts which make up [body]. *)
end

module Object : sig
  (** {1 Objects in the orx engine world}

      From https://orx-project.org/orx/doc/html/group__orx_object.html *)

  type t = obj
  (** An Orx object *)

  val compare : t -> t -> int
  (** Comparison defining a total ordering over objects. This is primarily
      useful for defining containers like {!Stdlib.Map} and {!Stdlib.Set}. *)

  val equal : t -> t -> bool
  (** Object equality *)

  (** {2 Object creation} *)

  val create_from_config : string -> t option

  val create_from_config_exn : string -> t

  (** {2 Enabling/disabling objects} *)

  val enable : t -> bool -> unit

  val enable_recursive : t -> bool -> unit

  val is_enabled : t -> bool

  val pause : t -> bool -> unit

  val is_paused : t -> bool

  (** {2 Object ownership} *)

  val set_owner : t -> Parent.t option -> unit

  val get_owner : t -> Parent.t option

  val set_parent : t -> Parent.t option -> unit

  val get_parent : t -> Parent.t option

  type _ child =
    | Child_object : t child
    | Owned_object : t child
    | Child_camera : camera child

  val get_children : t -> 'a child -> 'a Seq.t

  val get_first_child : t -> 'a child -> 'a option

  val get_children_recursive : t -> t child -> t Seq.t

  val iter_children_recursive : (t -> unit) -> t -> t child -> unit

  val iter_recursive : (t -> unit) -> t -> t child -> unit

  (** {2 Basic object properties} *)

  val get_name : t -> string

  val get_bounding_box : t -> Obox.t

  (** {2 Clock association} *)

  val set_clock : t -> Clock.t option -> Status.t

  val set_clock_recursive : t -> Clock.t option -> unit

  (** {2 FX} *)

  val add_fx : t -> string -> Status.t

  val add_fx_exn : t -> string -> unit

  val add_unique_fx : t -> string -> Status.t

  val add_unique_fx_exn : t -> string -> unit

  val add_fx_recursive : t -> string -> float -> unit

  val add_unique_fx_recursive : t -> string -> float -> unit

  val remove_fx : t -> string -> Status.t

  val remove_fx_exn : t -> string -> unit

  val remove_fx_recursive : t -> string -> unit

  val remove_all_fxs : t -> Status.t

  val remove_all_fxs_exn : t -> unit

  val remove_all_fxs_recursive : t -> Status.t

  val remove_all_fxs_recursive_exn : t -> unit

  (*** {2 Shaders} *)

  val add_shader : t -> string -> Status.t

  val add_shader_exn : t -> string -> unit

  val add_shader_recursive : t -> string -> unit

  val remove_shader : t -> string -> Status.t

  val remove_shader_exn : t -> string -> unit

  val remove_shader_recursive : t -> string -> unit

  (** {2 Placement and dimensions} *)

  val get_rotation : t -> float

  val set_rotation : t -> float -> unit

  val get_world_position : t -> Vector.t

  val set_world_position : t -> Vector.t -> unit

  val get_position : t -> Vector.t

  val set_position : t -> Vector.t -> unit

  val get_scale : t -> Vector.t

  val set_scale : t -> Vector.t -> unit

  (** {2 Repetition} *)

  val get_repeat : t -> float * float

  val set_repeat : t -> float -> float -> unit

  (** {2 Text} *)

  val set_text_string : t -> string -> unit

  val get_text_string : t -> string

  (** {2 Lifetime} *)

  val set_life_time : t -> float -> unit

  val get_life_time : t -> float

  val get_active_time : t -> float

  (** {2 Timeline tracks} *)

  val add_time_line_track : t -> string -> Status.t

  val add_time_line_track_exn : t -> string -> unit

  val add_time_line_track_recursive : t -> string -> unit

  val remove_time_line_track : t -> string -> Status.t

  val remove_time_line_track_exn : t -> string -> unit

  val remove_time_line_track_recursive : t -> string -> unit

  val enable_time_line : t -> bool -> unit

  val is_time_line_enabled : t -> bool

  (** {2 Speed} *)

  val set_speed : t -> Vector.t -> unit

  val get_speed : t -> Vector.t

  val set_relative_speed : t -> Vector.t -> unit

  val get_relative_speed : t -> Vector.t

  (** {2 Physics} *)

  val apply_force : ?location:Vector.t -> t -> Vector.t -> unit

  val apply_impulse : ?location:Vector.t -> t -> Vector.t -> unit

  val apply_torque : t -> float -> unit

  val set_angular_velocity : t -> float -> unit

  val get_angular_velocity : t -> float

  val set_custom_gravity : t -> Vector.t option -> unit

  val get_custom_gravity : t -> Vector.t option

  val get_mass : t -> float

  val get_mass_center : t -> Vector.t

  type collision = {
    colliding_object : t;
    contact : Vector.t;
    normal : Vector.t;
  }

  val raycast :
    ?self_flags:int ->
    ?check_mask:int ->
    ?early_exit:bool ->
    Vector.t ->
    Vector.t ->
    collision option

  (** {2 Color} *)

  val set_rgb : t -> Vector.t -> unit

  val set_rgb_recursive : t -> Vector.t -> unit

  val set_alpha : t -> float -> unit

  val set_alpha_recursive : t -> float -> unit

  (** {2 Animation} *)

  val set_target_anim : t -> string -> Status.t

  val set_target_anim_exn : t -> string -> unit

  val set_target_anim_recursive : t -> string -> unit

  val get_target_anim : t -> string

  val set_current_anim : t -> string -> Status.t

  val set_current_anim_exn : t -> string -> unit

  val set_current_anim_recursive : t -> string -> unit

  val get_current_anim : t -> string

  (** {2 Sound} *)

  val add_sound : t -> string -> Status.t

  val add_sound_exn : t -> string -> unit

  val remove_sound : t -> string -> Status.t

  val remove_sound_exn : t -> string -> unit

  val get_last_added_sound : t -> Sound.t option

  val set_volume : t -> float -> unit

  val set_pitch : t -> float -> unit

  val play : t -> unit

  val stop : t -> unit

  (** {2 Associated structures} *)

  type 'a associated_structure =
    | Body : Body.t associated_structure
    | Graphic : Graphic.t associated_structure
    | Sound : Sound.t associated_structure

  val link_structure : t -> Structure.t -> unit

  val get_structure : t -> 'a associated_structure -> 'a option

  (** {2 Spatial selection} *)

  type group =
    | All_groups
    | Group of string
    | Group_id of String_id.t

  val get_neighbor_list : Obox.t -> group -> t list

  val get_group : group -> t Seq.t

  val get_enabled : group -> t Seq.t

  val pick : Vector.t -> group -> t option

  val box_pick : Obox.t -> group -> t option

  (** {2 Groups} *)

  val get_default_group_id : unit -> String_id.t

  val get_group_id : t -> String_id.t

  val set_group_id : t -> group -> unit

  val set_group_id_recursive : t -> group -> unit

  (** {2 Object GUIDs} *)

  val to_guid : t -> Structure.Guid.t

  val get_guid : t -> Structure.Guid.t

  val of_guid : Structure.Guid.t -> t option

  val of_guid_exn : Structure.Guid.t -> t

  (** {2 Structure conversion} *)

  val of_structure : Structure.t -> t option
end

module Shader_param_type : sig
  type t =
    | Float
    | Texture
    | Vector
    | Time
end

module Shader : sig
  (** {1 Shaders}

      From https://orx-project.org/orx/doc/html/group__orx_shader.html *)

  type t
  (** Runtime representation of a shader *)

  val set_float_param_exn : t -> string -> float -> unit
  (** [set_float_param_exn shader name value] sets the parameter [name] to
      [value] for [shader]. *)

  val set_vector_param_exn : t -> string -> Vector.t -> unit
  (** [set_vector_param_exn shade name value] sets the parameter [name] to
      [value] for [shader]. *)

  val get_name : t -> string
  (** [get_name shader] gets the config name for [shader]. *)
end

module Shader_pointer : sig
  (** {1 Pointers to shaders}

      From https://orx-project.org/orx/doc/html/group__orx_shader_pointer.html *)

  type t

  val get_shader : t -> int -> Shader.t option
  (** [get_shader ptr index] gets the shader associated with [ptr] at index
      [index]. *)
end

module Config_event : sig
  (** {1 Configuration events} *)

  type t =
    | Reload_start
    | Reload_stop

  val compare : t -> t -> int
end

module Fx_event : sig
  (** {1 FX events} *)

  type t =
    | Start
    | Stop
    | Add
    | Remove
    | Loop

  val compare : t -> t -> int

  type payload
  (** Event payload *)

  val get_name : payload -> string
  (** [get_name payload] is the name of the event which sent [payload]. *)
end

module Input_event : sig
  (** {1 Input events} *)

  type t =
    | On
    | Off
    | Select_set

  val compare : t -> t -> int

  type payload
  (** Event payload *)

  val get_set_name : payload -> string
  (** [get_set_name payload] is the input set name for the input event which
      sent [payload]. *)

  val get_input_name : payload -> string
  (** [get_input_name payload] is the input name for the input event which sent
      [payload]. *)
end

module Object_event : sig
  (** {1 Object events} *)

  type t =
    | Create
    | Delete
    | Prepare
    | Enable
    | Disable
    | Pause
    | Unpause

  val compare : t -> t -> int

  type payload
  (** Event payload *)
end

module Physics_event : sig
  (** {1 Physics events} *)

  type t =
    | Contact_add
    | Contact_remove

  val compare : t -> t -> int

  type payload
  (** Event payload *)

  val get_position : payload -> Vector.t
  (** [get_position payload] is the location of the contact for the physics
      event that sent [payload]. *)

  val get_normal : payload -> Vector.t
  (** [get_normal payload] is the normal vector of the contact for the physics
      event that sent [payload]. *)

  val get_sender_part_name : payload -> string
  (** [get_sender_part_name payload] is the name of the body part which sent the
      event which sent [payload]. *)

  val get_recipient_part_name : payload -> string
  (** [get_recipient_part_name payload] is the name of the body part which
      recieved the event which sent [payload]. *)
end

module Shader_event : sig
  (** {1 Shader events}

      Shader events can be used to set dynamic parameters for shaders. *)

  type t = Set_param

  val compare : t -> t -> int

  type payload
  (** Event payload *)

  val get_shader : payload -> Shader.t
  (** [get_shader payload] is the shader associated with the event. *)

  val get_shader_name : payload -> string
  (** [get_shader_name payload] is the name of the shader associated with the
      event. *)

  val get_param_name : payload -> string
  (** [get_param_name payload] is the name of the shader parameter associated
      with the event. *)

  val get_param_type : payload -> Shader_param_type.t
  (** [get_param_type payload] is the type of the shader parameter associated
      with the event. *)

  val get_param_index : payload -> int
  (** [get_param_index payload] is the index of the shader parameter associated
      with the event. *)

  val set_param_float : payload -> float -> unit
  (** [set_param_float payload v] sets the shader parameter for this event to
      [v]. *)

  val set_param_vector : payload -> Vector.t -> unit
  (** [set_param_vector payload v] sets the shader parameter for this event to
      [v]. *)
end

module Sound_event : sig
  (** {1 Sound events} *)

  type t =
    | Start
    | Stop
    | Add
    | Remove

  val compare : t -> t -> int

  type payload
  (** Event payload *)

  val get_sound : payload -> Sound.t
  (** [get_sound payload] is the sound associated with this event. *)
end

module Time_line_event : sig
  (** {1 Time line track events} *)

  type t =
    | Track_start
    | Track_stop
    | Track_add
    | Track_remove
    | Loop
    | Trigger

  val compare : t -> t -> int

  type payload
  (** Event payload *)

  val get_track_name : payload -> string
  (** [get_track_name payload] is the config name of the track associated with
      the event. *)

  val get_event : payload -> string
  (** [get_event payload] is the event text associated with the event. *)

  val get_time_stamp : payload -> float
  (** [get_time_stamp payload] is the time associated with the event. *)
end

module Anim_event : sig
	type t =
		| Start
		| Stop
		| Cut
		| Loop
		| Update
		| Custom_event

	val compare : t -> t -> int

	type payload

	(* val get_animation : payload -> Animation *)

	val get_name : payload -> string

	(* val get_count : payload -> int *)

	(* val get_time : payload -> float *)

	(* val get_custom_event : payload -> Custom_event *)

end

module Event : sig
  (** {1 Events} *)

  type t
  (** Engine events *)

  module Event_type : sig
    type ('event, 'payload) t =
      | Fx : (Fx_event.t, Fx_event.payload) t
      | Input : (Input_event.t, Input_event.payload) t
      | Object : (Object_event.t, Object_event.payload) t
      | Physics : (Physics_event.t, Physics_event.payload) t
      | Shader : (Shader_event.t, Shader_event.payload) t
      | Sound : (Sound_event.t, Sound_event.payload) t
      | Time_line : (Time_line_event.t, Time_line_event.payload) t
	  | Animation : (Anim_event.t, 
	  Anim_event.payload) t

    type any = Any : (_, _) t -> any
  end

  val to_type : t -> Event_type.any

  val to_event : t -> ('event, _) Event_type.t -> 'event

  val get_sender_object : t -> Object.t option
  (** [get_sender_object t] is the sending object for the event [t] if there is
      one. *)

  val get_recipient_object : t -> Object.t option
  (** [get_recipient_object t] is the receiving object for the event [t] if
      there is one. *)

  val get_sender_structure : t -> Structure.t option
  (** [get_sender_structure t] is the sending structure for the event [t] if
      there is one. *)

  val get_recipient_structure : t -> Structure.t option
  (** [get_recipient_structure t] is the receiving structure for the event [t]
      if there is one. *)

  module Handle : sig
    (** {1 Callback/handler handles}

        Handles track registered callbacks/handlers so they can be explicitly
        released. *)

    type t
    (** Handle for tracking callbacks/handlers *)

    val default : t
    (** Default handle when none is specified *)

    val make : unit -> t
    (** [make ()] is a fresh handle with no associated callbacks/handlers *)
  end

  val add_handler :
    ?handle:Handle.t ->
    ?events:'event list ->
    ('event, 'payload) Event_type.t ->
    (t -> 'event -> 'payload -> Status.t) ->
    unit
  (** [add_handler ?events event_type handler_callback] associates
      [handler_callback] with [events] from [event_type].

      @param events defaults to all events matching [event_type]. *)

  val remove_handler : (_, _) Event_type.t -> Handle.t -> unit
  (** [remove_handler event_type handle] removes and releases all handlers for
      [event_type] associated with [handler]. *)

  val remove_all_handlers : (_, _) Event_type.t -> unit
  (** [remove_all_handlers event_type] removes and releases all handlers for
      [event_type]. *)
end

module Camera : sig
  (** {1 In-game cameras}

      From https://orx-project.org/orx/doc/html/group__orx_camera.html *)

  type t = camera
  (** Game camera *)

  val create_from_config : string -> t option
  (** [create_from_config section] creates the camera under config [section] if
      [section] exists and correctly defines a camera. *)

  val create_from_config_exn : string -> t
  (** [create_from_config section] creates the camera under config [section].

      @raise Invalid_argument
        if [section] does not exist or does not correctly define a camera. *)

  val get : string -> t option
  (** [get name] gets the camera [name] if one exists. *)

  val get_name : t -> string
  (** [get_name camera] is the name of [camera]. *)

  val get_parent : t -> Parent.t option
  (** [get_parent camera] gets the parent of [camera] if it has one. *)

  val set_parent : t -> Parent.t option -> unit
  (** [set_parent camera parent] sets the parent of [camera] to [parent]. If
      [parent] is [None] then the parent is [cleared]. *)

  val get_position : t -> Vector.t
  (** [get_position camera] is the position of [camera]. *)

  val set_position : t -> Vector.t -> unit
  (** [get_position camera pos] sets [camera]'s position to [pos]. *)

  val get_rotation : t -> float
  (** [get_rotation camera] is the rotation of [camera] in radians. *)

  val set_rotation : t -> float -> unit
  (** [set_rotation camera angle] sets the rotation of [camera] to [angle].

      @param angle Angle in radians *)

  val get_zoom : t -> float
  (** [get_zoom camera] is the zoom multiplier for [camera]. *)

  val set_zoom : t -> float -> unit
  (** [set_zoom camera zoom] sets [camera]'s zoom multiplier to [zoom]. *)

  val set_frustum :
    t -> width:float -> height:float -> near:float -> far:float -> unit
  (** [set_frustum camera ~width ~height ~near ~far] sets the frustum - the
      visible volume - for [camera]. *)
end

module Viewport : sig
  (** {1 Game world viewports}

      From https://orx-project.org/orx/doc/html/group__orx_viewport.html *)

  type t
  (** Viewport *)

  val create_from_config : string -> t option
  (** [create_from_config section] creates the viewport under config [section]
      if [section] exists and correctly defines a viewport. *)

  val create_from_config_exn : string -> t
  (** [create_from_config section] creates the viewport under config [section].

      @raise Invalid_argument
        if [section] does not exist or does not correctly define a viewport. *)

  val get_camera : t -> Camera.t option
  (** [get_camera viewport] is the camera associated with [viewport] if one
      exists. *)

  val get_shader_pointer : t -> Shader_pointer.t option
  (** [get_shader_pointer viewport] is the shader pointer associated with
      [viewport] if one exists. *)

  val get_shader_exn : ?index:int -> t -> Shader.t
  (** [get_shader_exn ?index viewport] is the shader associated with [viewport]. *)

  val get_name : t -> string
  (** [get_name viewport] is the name of [viewport]. *)

  val get : string -> t option
  (** [get name] is the viewport associated with [name] if one exists. *)

  val get_exn : string -> t
  (** [get_exn name] is the viewport associated with [name].

      @raise Invalid_argument if [name] does name match a valid viewport. *)

  val of_structure : Structure.t -> t option
  (** [of_structure s] casts a {!t} from [s] if [s] is a viewport. *)
end

module Render : sig
  (** {1 Rendering}

      From https://orx-project.org/orx/doc/html/group__orx_render.html *)

  val get_world_position : Vector.t -> Viewport.t -> Vector.t option
  (** [get_world_position screen_position viewport] is the world position
      matching [screen_position] in [viewport] if [screen_position] falls within
      the display surface. Otherwise, [None]. *)

  val get_screen_position : Vector.t -> Viewport.t -> Vector.t option
  (** [get_screen_position world_position viewport] is the screen position
      matching [world_position] in [viewport] if [world_position] is found. The
      result may be offscreen. Otherwise, [None]. *)
end

module Config : sig
  (** {1 Config values} *)

  module Value : sig
    (** {1 Config convenience get/set functions} *)

    type _ t =
      | String : string t
      | Int : int t
      | Float : float t
      | Bool : bool t
      | Vector : Vector.t t
      | Guid : Structure.Guid.t t

    val to_string : _ t -> string
    val to_proper_string : _ t -> string

    val set : 'a t -> 'a -> section:string -> key:string -> unit
    (** [set value_type value ~section ~key] sets the config [section] [key] to
        [value].

        @param value_type
          indicates the type of value to store under [section] [key] *)

    val get : 'a t -> section:string -> key:string -> 'a
    (** [get value_type ~section ~key] is the value under [section] [key]. *)

    val find : 'a t -> section:string -> key:string -> 'a option
    (** [find value_type ~section ~key] is the value under [section] [key] if it
        exists, else [None]. *)

    val clear : section:string -> key:string -> unit
    (** [clear ~section ~key] clears any value under [section] [key]. *)

    val update :
      'a t -> ('a option -> 'a option) -> section:string -> key:string -> unit
    (** [update value_type f ~section ~key] sets [section] [key] to
        [f old_value]. If [f old_value] is [None] then the value is cleared. *)
  end

  val set_basename : string -> unit
  (** [set_basename name] set [name] as the base name for the default config
      file. *)

  val load : string -> Status.t
  (** [load name] loads config from the file [name]. *)

  val load_from_memory : string -> Status.t
  (** [load_from_memory config] loads config from the config in buffer [config]. *)

  val push_section : string -> unit
  (** [push_section section] pushes [section] to the top of the active section
      stack. *)

  val pop_section : unit -> unit
  (** [pop_section section] pops the top active section from the active section
      stack. *)

  val get_current_section : unit -> string
  (** [get_current_section ()] is the currently active config section. *)

  val select_section : string -> unit
  (** [select_section section] makes [section] the currently active config
      section without modifying the stack. *)

  val get_section_count : unit -> int
  (** [get_section_count ()] gets the total number of config sections. *)

  val get_section : int -> string
  (** [get_section i] gets the name of the section at index [i]. *)

  val get_key_count : unit -> int
  (** [get_key_count ()] gets the number of keys from the current section. *)

  val get_key : int -> string
  (** [get_key i] gets the key at index [i] from the current section. *)

  val get_parent : string -> string option
  (** [get_parent section] gets the parent of [section] if it has one. *)

  val has_section : string -> bool
  (** [has_section name] indicates if [name] exists as a config section. *)

  val has_value : string -> bool
  (** [has_value name] indicates if [name] is a key in the current config
      section. *)

  val clear_section : string -> Status.t
  (** [clear_section name] clears the section [name]. *)

  val clear_value : string -> Status.t
  (** [clear_value key] clears [key] from the currently active section. *)

  (** {2 Get/set values in the current section} *)

  val get_string : string -> string

  val set_string : string -> string -> unit

  val get_bool : string -> bool

  val set_bool : string -> bool -> unit

  val get_float : string -> float

  val set_float : string -> float -> unit

  val get_int : string -> int

  val set_int : string -> int -> unit

  val get_vector : string -> Vector.t

  val set_vector : string -> Vector.t -> unit

  val get_list_vector : string -> int option -> Vector.t

  val set_list_string : string -> string list -> unit

  val append_list_string : string -> string list -> unit

  val if_has_value : string -> (string -> 'a) -> 'a option
  (** [if_has_value key getter] is [Some (getter key)] if [key] exists in the
      currently selected config section or [None] if [key] does not exist in the
      current section. *)

  val exists : section:string -> key:string -> bool
  (** [exists ~section ~key] is [true] if [key] exists in [section]. *)

  val get : (string -> 'a) -> section:string -> key:string -> 'a

  val set : (string -> 'a -> unit) -> 'a -> section:string -> key:string -> unit

  val get_seq : (string -> 'a) -> section:string -> key:string -> 'a Seq.t
  (** [get_seq getter ~section ~key] is a sequence of values pulled repeatedly
      from the same [section] and [key].

      If the values are random then a new random value will be returned for
      every element of the sequence.

      If the [section] and [key] represent a constant value then the sequence
      will return the same value for every element.

      If [section] and [key] do not exist then the result will be [Seq.empty]. *)

  val get_list_item :
    (string -> int option -> 'a) ->
    int option ->
    section:string ->
    key:string ->
    'a

  val get_list :
    (string -> int option -> 'a) -> section:string -> key:string -> 'a list

  val is_list : string -> bool

  val get_sections : unit -> string list
  (** [get_sections ()] is all section names defined in config. *)

  val get_current_section_keys : unit -> string list
  (** [get_current_section_keys ()] is all keys in the active section. *)

  val get_section_keys : string -> string list
  (** [get_section_keys section] is all the keys in [section]. *)

  val get_guid : string -> Structure.Guid.t

  val set_guid : string -> Structure.Guid.t -> unit

  val with_section : string -> (unit -> 'a) -> 'a
  (** [with_section section f] calls [f ()] with [section] as the active
      section, then restores the previously active section. *)

  val set_bootstrap : (unit -> Status.t) -> unit
  (** [set_bootstrap f] sets [f] as the config bootstrap function. *)
end

module Command : sig
  (** {1 Define and run custom engine commands} *)

  module Var_def : sig
    (** {1 Command variable definitions} *)

    type t
    (** Command variable definition *)

    val make : string -> _ Config.Value.t -> t
    (** [make name value_type] creates a new {!t} named [name] of type
        [value_type]. *)
  end

  module Var : sig
    (** {1 Command variables} *)

    type t
    (** Command variable *)

    val make : 'a Config.Value.t -> 'a -> t
    (** [make value_type value] creates a command variable containing [value]. *)

    val set : t -> 'a Config.Value.t -> 'a -> unit
    (** [set v value_type value] sets [v] to [value]. *)

    val get : t -> 'a Config.Value.t -> 'a
    (** [get v value_type] is the value in [v]. *)
  end

  val register :
    string ->
    (Var.t array -> Var.t -> unit) ->
    Var_def.t list * Var_def.t list ->
    Var_def.t ->
    Status.t

  val register_exn :
    string ->
    (Var.t array -> Var.t -> unit) ->
    Var_def.t list * Var_def.t list ->
    Var_def.t ->
    unit

  val unregister : string -> Status.t

  val unregister_exn : string -> unit

  val unregister_all : unit -> unit
  (** [unregister_all ()] will unregister all custom orx commands registered
      from OCaml. *)

  val is_registered : string -> bool

  val evaluate : string -> Var.t option

  val evaluate_with_guid : string -> Structure.Guid.t -> Var.t option
end

module Orx_thread : sig
  (** {1 OCaml support for orx's threading} *)

  val set_ocaml_callbacks : unit -> unit
  (** [set_ocaml_callbacks ()] initializes the support necessary to have OCaml
      play well with callbacks from other orx threads. This is currently only
      required when manipulating audio in OCaml callbacks from audio packet
      events. *)
end

module Main : sig
  val execute :
    init:(unit -> Status.t) ->
    run:(unit -> Status.t) ->
    exit:(unit -> unit) ->
    unit ->
    unit
  (** [execute ~init ~run ~exit ()] starts the Orx engine loop.

      Many games will be able to use {!start} instead of [execute] for slightly
      simpler application code. *)

  val start :
    ?config_dir:string ->
    ?exit:(unit -> unit) ->
    init:(unit -> (unit, [ `Orx ]) result) ->
    run:(unit -> (unit, [ `Orx ]) result) ->
    string ->
    unit
  (** [start ?config_dir ?exit ~init ~run name] starts the Orx engine loop.

      [start] automates a few common steps a game will often need when getting
      ready to call {!execute}. [start] defines a custom bootstrap function to
      specify where the game engine configuration resides and calls
      {!Config.set_basename} with [name] to define the root configuration file
      for a game.

      @param config_dir
        specifies the directory holding engine configuration files. The current
        working directory will be used if this is not provided.
      @param exit
        specifies a function to be run when the engine loop exits. It can be
        used to clean up game data which is not managed by or within the game
        engine.
      @param init
        specifies a function to run after the engine has initialized and before
        the game loop begins.
      @param run specifies a function that will be run once per frame.
      @param name
        species the name of the root configuration file without an extension. *)
end
