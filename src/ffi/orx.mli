type camera
type obj

module Status : sig
  type 'ok result = ('ok, [ `Orx ]) Stdlib.result
  type t = unit result

  val ok : t
  val error : t

  val open_error : 'ok result -> ('ok, [> `Orx ]) Stdlib.result

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

module Color : sig
  type t
end

module String_id : sig
  type t

  val undefined : t

  val get_id : string -> t

  val get_from_id : t -> string
end

module Parent : sig
  type t =
    | Camera of camera
    | Object of obj
end

module Structure : sig
  type t

  module Guid : sig
    type t

    val compare : t -> t -> int
    val equal : t -> t -> bool
    val pp : Format.formatter -> t -> unit
    val to_string : t -> string
  end
end

module Vector : sig
  type t

  val pp : Format.formatter -> t -> unit

  val equal : t -> t -> bool

  val equal_2d : t -> t -> bool

  val get_x : t -> float

  val get_y : t -> float

  val get_z : t -> float

  val get_size : t -> float

  val make : x:float -> y:float -> z:float -> t

  val set_x : t -> float -> unit

  val set_y : t -> float -> unit

  val set_z : t -> float -> unit

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
  type t

  val make : pos:Vector.t -> pivot:Vector.t -> size:Vector.t -> float -> t

  val copy : t -> t

  val get_center : t -> Vector.t

  val move : t -> Vector.t -> t

  val rotate_2d : t -> float -> t

  val is_inside : t -> Vector.t -> bool

  val is_inside_2d : t -> Vector.t -> bool
end

module Texture : sig
  type t

  val create_from_file : string -> bool -> t option

  val delete : t -> Status.t

  val clear_cache : unit -> Status.t

  val get_size : t -> (float * float) option
end

module Graphic : sig
  type t

  val create : unit -> t option

  val create_from_config : string -> t option

  val delete : t -> Status.t

  val set_size : t -> Vector.t -> unit

  val get_size : t -> Vector.t

  val set_origin : t -> Vector.t -> unit

  val get_origin : t -> Vector.t

  val set_flip : t -> bool -> bool -> unit

  val set_pivot : t -> Vector.t -> unit

  val set_data : t -> Structure.t -> Status.t

  val to_structure : t -> Structure.t
end

module Display : sig
  module Rgba : sig end

  module Draw : sig end
end

module Sound_status : sig
  type t
end

module Sound : sig
  type t

  val create_from_config : string -> t option

  val get_name : t -> string

  val get_status : t -> Sound_status.t

  val play : t -> unit

  val pause : t -> unit

  val stop : t -> unit

  val get_duration : t -> float

  val get_pitch : t -> float

  val set_pitch : t -> float -> unit

  val get_volume : t -> float

  val set_volume : t -> float -> unit

  val get_attenuation : t -> float

  val set_attenuation : t -> float -> unit
end

module Resource : sig
  type group = Config

  val pp : group Fmt.t

  val group_of_string : string -> group

  val string_of_group : group -> string

  val add_storage : group -> string -> bool -> Status.t
end

module Mouse_button : sig
  type t
end

module Mouse_axis : sig
  type t
end

module Mouse : sig
  val is_button_pressed : Mouse_button.t -> bool

  val get_position : unit -> Vector.t option

  val get_move_delta : unit -> Vector.t option

  val get_wheel_delta : unit -> float

  val show_cursor : bool -> Status.t

  val set_cursor : string -> Vector.t option -> Status.t

  val get_button_name : Mouse_button.t -> string

  val get_axis_name : Mouse_axis.t -> string
end

module Input_type : sig
  type t
end

module Input_mode : sig
  type t
end

module Input : sig
  val is_active : string -> bool

  val has_new_status : string -> bool

  val has_been_activated : string -> bool

  val get_binding :
    string -> int -> (Input_type.t * int * Input_mode.t) Status.result

  val get_binding_name : Input_type.t -> int -> Input_mode.t -> string
end

module Physics : sig
  val get_gravity : unit -> Vector.t

  val set_gravity : Vector.t -> unit
end

module Body_part : sig
  type t

  val set_self_flags : t -> int -> unit
end

module Body : sig
  type t

  val get_parts : t -> Body_part.t Seq.t
end

module Object : sig
  (** {1 Objects in the Orx engine's world} *)

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

  val get_owner : t -> Structure.t option

  val set_parent : t -> Parent.t option -> unit

  val get_parent : t -> Structure.t option

  type _ child =
    | Child_object : t child
    | Owned_object : t child
    | Child_camera : camera child

  val get_children : t -> 'a child -> 'a Seq.t

  val get_first_child : t -> 'a child -> 'a option

  (** {2 Basic object properties} *)

  val get_name : t -> string

  val get_bounding_box : t -> Obox.t

  (** {2 FX} *)

  val add_fx : t -> string -> Status.t

  val add_fx_exn : t -> string -> unit

  val add_unique_fx : t -> string -> Status.t

  val add_unique_fx_exn : t -> string -> unit

  val add_delayed_fx : t -> string -> float -> Status.t

  val add_delayed_fx_exn : t -> string -> float -> unit

  val add_fx_recursive : t -> string -> unit

  val add_unique_fx_recursive : t -> string -> unit

  val add_delayed_fx_recursive : t -> string -> float -> bool -> unit

  val remove_fx : t -> string -> Status.t

  val remove_fx_exn : t -> string -> unit

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

  val pick : Vector.t -> group -> t option

  val box_pick : Obox.t -> group -> t option

  (** {2 Groups} *)

  val get_default_group_id : unit -> String_id.t

  val get_group_id : t -> String_id.t

  val set_group_id : t -> group -> unit

  val set_group_id_recursive : t -> group -> unit

  (** {2 Object GUIDs} *)

  val to_guid : t -> Structure.Guid.t

  val of_guid : Structure.Guid.t -> t option

  val of_guid_exn : Structure.Guid.t -> t
end

module Shader_param_type : sig
  type t =
    | Float
    | Texture
    | Vector
    | Time
end

module Shader : sig
  type t

  val set_float_param_exn : t -> string -> float -> unit

  val set_vector_param_exn : t -> string -> Vector.t -> unit

  val get_name : t -> string
end

module Shader_pointer : sig
  type t

  val get_shader : t -> int -> Shader.t option
end

module Time_line : sig
  type t
end

module Config_event : sig
  type t =
    | Reload_start
    | Reload_stop
end

module Fx_event : sig
  type t =
    | Start
    | Stop
    | Add
    | Remove
    | Loop

  type payload

  val get_name : payload -> string
end

module Input_event : sig
  type t =
    | On
    | Off
    | Select_set

  type payload

  val get_set_name : payload -> string

  val get_input_name : payload -> string
end

module Object_event : sig
  type t =
    | Create
    | Delete
    | Prepare
    | Enable
    | Disable
    | Pause
    | Unpause

  type payload
end

module Physics_event : sig
  type t =
    | Contact_add
    | Contact_remove

  type payload

  val get_position : payload -> Vector.t
  val get_normal : payload -> Vector.t
  val get_sender_part_name : payload -> string
  val get_recipient_part_name : payload -> string
end

module Shader_event : sig
  type t = Set_param

  type payload

  val get_shader : payload -> Shader.t
  val get_shader_name : payload -> string
  val get_param_name : payload -> string
  val get_param_type : payload -> Shader_param_type.t
  val get_param_index : payload -> int
  val set_param_float : payload -> float -> unit
  val set_param_vector : payload -> Vector.t -> unit
end

module Sound_event : sig
  type t =
    | Start
    | Stop
    | Add
    | Remove

  type payload

  val get_sound : payload -> Sound.t
end

module Time_line_event : sig
  type t

  type payload

  val get_time_line : payload -> Time_line.t
  val get_track_name : payload -> string
  val get_event : payload -> string
  val get_time_stamp : payload -> float
end

module Event : sig
  type t

  module Event_type : sig
    type ('event, 'payload) t =
      | Fx : (Fx_event.t, Fx_event.payload) t
      | Input : (Input_event.t, Input_event.payload) t
      | Object : (Object_event.t, Object_event.payload) t
      | Physics : (Physics_event.t, Physics_event.payload) t
      | Shader : (Shader_event.t, Shader_event.payload) t
      | Sound : (Sound_event.t, Sound_event.payload) t
      | Time_line : (Time_line_event.t, Time_line_event.payload) t

    type any = Any : (_, _) t -> any
  end

  val get_flag : String_id.t -> String_id.t

  val to_type : t -> Event_type.any

  val to_event : t -> ('event, _) Event_type.t -> 'event

  val get_sender_object : t -> Object.t option

  val get_recipient_object : t -> Object.t option

  val add_handler :
    ('event, 'payload) Event_type.t ->
    (t -> 'event -> 'payload -> Status.t) ->
    unit
end

module Module_id : sig
  type t =
    | Clock
    | Main
end

module Clock_type : sig
  type t =
    | Core
    | User
    | Second
end

module Clock_modifier : sig
  type t =
    | Fixed
    | Multiply
    | Maxed
    | None
end

module Clock_priority : sig
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
  (** {1 Engine clocks} *)

  type t

  module Info : sig
    type clock = t

    type t

    val get_type : t -> Clock_type.t

    val get_tick_size : t -> float

    val get_modifier : t -> Clock_modifier.t

    val get_modifier_value : t -> float

    val get_dt : t -> float

    val get_time : t -> float

    val get_clock : t -> clock option
  end

  val compare : t -> t -> int

  val equal : t -> t -> bool

  val create_from_config : string -> t option

  val create_from_config_exn : string -> t

  val create : float -> Clock_type.t -> t option

  val get : string -> t option

  val get_core : unit -> t
  (** [get_core ()] returns the core engine clock. *)

  val find_first : ?tick_size:float -> Clock_type.t -> t option

  val get_name : t -> string

  val get_info : t -> Info.t

  val set_modifier : t -> Clock_modifier.t -> float -> unit

  val set_tick_size : t -> float -> unit

  val restart : t -> Status.t

  val pause : t -> unit

  val unpause : t -> unit

  val is_paused : t -> bool

  val register :
    t -> (Info.t -> unit) -> Module_id.t -> Clock_priority.t -> unit
end

module Camera : sig
  type t = camera

  val create_from_config : string -> t option

  val create_from_config_exn : string -> t

  val get : string -> t option

  val get_name : t -> string

  val get_parent : t -> Parent.t option

  val set_parent : t -> Parent.t option -> unit

  val get_position : t -> Vector.t

  val set_position : t -> Vector.t -> unit

  val get_rotation : t -> float

  val set_rotation : t -> float -> unit

  val get_zoom : t -> float

  val set_zoom : t -> float -> unit

  val set_frustum : t -> float -> float -> float -> float -> unit
end

module Viewport : sig
  type t

  val create_from_config : string -> t option

  val create_from_config_exn : string -> t

  val get_camera : t -> Camera.t option

  val get_shader_pointer : t -> Shader_pointer.t option

  val get_shader_exn : ?index:int -> t -> Shader.t

  val get_name : t -> string

  val get : string -> t option

  val get_exn : string -> t
end

module Render : sig
  val get_world_position : Vector.t -> Viewport.t -> Vector.t option

  val get_screen_position : Vector.t -> Viewport.t -> Vector.t option
end

module Config : sig
  val set_basename : string -> unit

  val load : string -> Status.t

  val load_from_memory : string -> Status.t

  val set_bootstrap : (unit -> Status.t) -> unit

  val push_section : string -> unit

  val pop_section : unit -> unit

  val get_current_section : unit -> string

  val select_section : string -> unit

  val get_section_count : unit -> int

  val get_section : int -> string

  val get_key_count : unit -> int

  val get_key : int -> string

  val get_parent : string -> string option

  val has_section : string -> bool

  val has_value : string -> bool

  val clear_section : string -> Status.t

  val clear_value : string -> Status.t

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

  val get_current_section_keys : unit -> string list

  val get_section_keys : string -> string list

  val get_guid : string -> Structure.Guid.t

  val set_guid : string -> Structure.Guid.t -> unit

  val with_section : string -> (unit -> 'a) -> 'a
end

module Command : sig
  (** {1 Define and run custom engine commands} *)

  module Var_type : sig
    type _ t =
      | String : string t
      | Float : float t
      | Int : int t
      | Bool : bool t
      | Vector : Vector.t t
      | Guid : Structure.Guid.t t
  end

  module Var_def : sig
    type t

    val make : string -> _ Var_type.t -> t
  end

  module Var : sig
    type t

    val make : 'a Var_type.t -> 'a -> t

    val set : t -> 'a Var_type.t -> 'a -> unit

    val get : t -> 'a Var_type.t -> 'a
  end

  val register :
    string ->
    (Var.t array -> Var.t -> unit) ->
    Var_def.t list ->
    Var_def.t ->
    Status.t

  val register_exn :
    string ->
    (Var.t array -> Var.t -> unit) ->
    Var_def.t list ->
    Var_def.t ->
    unit

  val unregister : string -> Status.t

  val unregister_exn : string -> unit

  val is_registered : string -> bool

  val evaluate : string -> Var.t option

  val evaluate_with_guid : string -> Structure.Guid.t -> Var.t option
end

module Orx_thread : sig
  val set_ocaml_callbacks : unit -> unit
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

      @param config_dir specifies the directory holding engine configuration
      files. The current working directory will be used if this is not provided.
      @param exit specifies a function to be run when the engine loop exits. It
      can be used to clean up game data which is not managed by or within the
      game engine.
      @param init specifies a function to run after the engine has initialized
      and before the game loop begins.
      @param run specifies a function that will be run once per frame.
      @param name species the name of the root configuration file without an
      extension. *)
end
