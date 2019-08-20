module T = Orx_types;

module Bindings = (F: Ctypes.FOREIGN) => {
  let c = (name, f) => F.foreign(name, f);

  module Ctypes_for_stubs = {
    include Ctypes;

    let (@->) = F.(@->);
    let returning = F.returning;
  };
  open Ctypes_for_stubs;

  module Status = {
    type t = result(unit, unit);

    let of_int = (i): t =>
      switch (i) {
      | 1 => Ok()
      | 0 => Error()
      | _ => Fmt.invalid_arg("Unsupported ORX status %d", i)
      };

    let to_int = (s: t): int =>
      switch (s) {
      | Ok () => 1
      | Error () => 0
      };

    let pp =
      Fmt.(
        result(
          ~ok=const(string, "success"),
          ~error=const(string, "failure"),
        )
      );

    let t = view(~format=pp, ~read=of_int, ~write=to_int, int);
  };

  module Vector = {
    type t = ptr(structure(T.Vector.t));

    let t = ptr(T.Vector.t);
    let t_opt = ptr_opt(T.Vector.t);

    let allocate_raw = (): t => allocate_n(T.Vector.t, ~count=1);

    let set =
      c("orxVector_Set", t @-> float @-> float @-> float @-> returning(t));

    let copy = c("orxVector_Copy", t @-> t @-> returning(t));

    let scale = c("orxVector_Mulf", t @-> t @-> float @-> returning(t));

    let add = c("orxVector_Add", t @-> t @-> t @-> returning(t));

    let rotate_2d =
      c("orxVector_2DRotate", t @-> t @-> float @-> returning(t));
  };

  module Color = {
    type t = ptr(structure(T.Color.t));

    let t = ptr(T.Color.t);
    let t_opt = ptr_opt(T.Color.t);

    let allocate_raw = (): t => allocate_n(T.Color.t, ~count=1);
  };

  module Structure = {
    type t = ptr(structure(T.Structure.t));

    let t = ptr(T.Structure.t);
    let t_opt = ptr_opt(T.Structure.t);
  };

  module Texture = {
    type t = ptr(structure(T.Texture.t));

    let t = ptr(T.Texture.t);
    let t_opt = ptr_opt(T.Texture.t);

    let create =
      c("orxTexture_CreateFromFile", string @-> bool @-> returning(t_opt));

    let delete = c("orxTexture_Delete", t @-> returning(Status.t));

    let clear_cache =
      c("orxTexture_ClearCache", void @-> returning(Status.t));

    let to_structure = c("orxSTRUCTURE", t @-> returning(Structure.t));
  };

  module Graphic = {
    type t = ptr(structure(T.Graphic.t));

    let t = ptr(T.Graphic.t);
    let t_opt = ptr_opt(T.Graphic.t);

    let create = c("orxGraphic_Create", void @-> returning(t_opt));

    let create_from_config =
      c("orxGraphic_CreateFromConfig", string @-> returning(t_opt));

    let delete = c("orxGraphic_Delete", t @-> returning(Status.t));

    // Graphic dimensions on the source texture
    let set_size =
      c("orxGraphic_SetSize", t @-> Vector.t @-> returning(Status.t));

    let get_size =
      c("orxGraphic_GetSize", t @-> Vector.t @-> returning(Vector.t));

    // Graphic origin on the source texture
    let set_origin =
      c("orxGraphic_SetOrigin", t @-> Vector.t @-> returning(Status.t));

    let get_origin =
      c("orxGraphic_GetOrigin", t @-> Vector.t @-> returning(Vector.t));

    // Set texture data associated with this graphic
    let set_data =
      c("orxGraphic_SetData", t @-> Structure.t @-> returning(Status.t));

    // Cast to a orx structure
    let to_structure = c("orxSTRUCTURE", t @-> returning(Structure.t));
  };

  module Config = {
    /* This module will be included in the Config module defined in orx.re */
    let set_basename =
      c("orxConfig_SetBaseName", string @-> returning(Status.t));

    // Load config from a file
    let load = c("orxConfig_Load", string @-> returning(Status.t));

    // Load config from a string already in memory
    let load_from_memory =
      c("orxConfig_LoadFromMemory", string @-> int @-> returning(Status.t));

    /* Select a config section to work within */
    let push_section =
      c("orxConfig_PushSection", string @-> returning(Status.t));
    let pop_section =
      c("orxConfig_PopSection", void @-> returning(Status.t));

    // Check for section and value existence
    let has_section = c("orxConfig_HasSection", string @-> returning(bool));
    let has_value = c("orxConfig_HasValue", string @-> returning(bool));

    // Get values from a config
    let get_string = c("orxConfig_GetString", string @-> returning(string));
    let get_bool = c("orxConfig_GetBool", string @-> returning(bool));
    let get_float = c("orxConfig_GetFloat", string @-> returning(float));
    // XXX: Pretend a signed 64bit integer is always enough and the values will
    // always fit in an OCaml int
    let get_int = c("orxConfig_GetS64", string @-> returning(int));
    let get_vector =
      c("orxConfig_GetVector", string @-> Vector.t @-> returning(Vector.t));

    // Set config values
    let set_string =
      c("orxConfig_SetString", string @-> string @-> returning(Status.t));
    let set_bool =
      c("orxConfig_SetBool", string @-> bool @-> returning(Status.t));
    let set_float =
      c("orxConfig_SetFloat", string @-> float @-> returning(Status.t));
    let set_int =
      c("orxConfig_SetS64", string @-> int @-> returning(Status.t));
    let set_vector =
      c("orxConfig_SetVector", string @-> Vector.t @-> returning(Status.t));

    // Get/Set values from a list
    let is_list = c("orxConfig_IsList", string @-> returning(bool));
    let get_list_count =
      c("orxConfig_GetListCount", string @-> returning(int));

    let int_or_random = {
      let read = (i: int): option(int) => {
        switch (i) {
        | (-1) => None
        | i => Some(i)
        };
      };
      let write = (o: option(int)): int => {
        switch (o) {
        | None => (-1)
        | Some(i) => i
        };
      };
      view(~read, ~write, int);
    };

    let get_list_string =
      c(
        "orxConfig_GetListString",
        string @-> int_or_random @-> returning(string),
      );
    let get_list_bool =
      c(
        "orxConfig_GetListBool",
        string @-> int_or_random @-> returning(string),
      );
    let get_list_float =
      c(
        "orxConfig_GetListFloat",
        string @-> int_or_random @-> returning(float),
      );
    let get_list_int =
      c("orxConfig_GetListS64", string @-> int_or_random @-> returning(int));
    let get_list_vector =
      c(
        "orxConfig_GetListVector",
        string @-> int_or_random @-> Vector.t @-> returning(Vector.t),
      );

    // Modify a list of config values
    let set_list_string =
      c(
        "orxConfig_SetListString",
        string @-> ptr(string) @-> int @-> returning(Status.t),
      );
    let append_list_string =
      c(
        "orxConfig_AppendListString",
        string @-> ptr(string) @-> int @-> returning(Status.t),
      );
  };

  module Clock = {
    type t = ptr(structure(T.Clock.t));

    let t: typ(t) = ptr(T.Clock.t);
    let t_opt: typ(option(t)) = ptr_opt(T.Clock.t);

    module Info = {
      type clock = t;
      let clock = t;
      let clock_opt = t_opt;

      type t = ptr(structure(T.Clock_info.t));

      let t = ptr(T.Clock_info.t);

      let get = (info: t, field) => Ctypes.getf(!@info, field);
      let get_type = (info: t): T.Clock_type.t =>
        get(info, T.Clock_info.clock_type);
      let get_tick_size = (info: t): float =>
        get(info, T.Clock_info.tick_size);
      let get_modifier = (info: t): T.Clock_modifier.t =>
        get(info, T.Clock_info.modifier);
      let get_modifier_value = (info: t): float =>
        get(info, T.Clock_info.modifier_value);
      let get_dt = (info: t): float => get(info, T.Clock_info.dt);
      let get_time = (info: t): float => get(info, T.Clock_info.time);

      let get_clock = c("orxClock_GetFromInfo", t @-> returning(clock_opt));
    };

    // Pointer/physical equality-based comparison
    let compare = (a: t, b: t): int => Ctypes.ptr_compare(a, b);
    let equal = (a, b) => compare(a, b) == 0;

    let create_from_config =
      c("orxClock_CreateFromConfig", string @-> returning(t_opt));

    let find_first =
      c("orxClock_FindFirst", float @-> T.Clock_type.t @-> returning(t_opt));

    let get_name = c("orxClock_GetName", t @-> returning(string));

    let get_info = c("orxClock_GetInfo", t @-> returning(Info.t));

    let set_modifier =
      c(
        "orxClock_SetModifier",
        t @-> T.Clock_modifier.t @-> float @-> returning(Status.t),
      );
  };

  module Resource = {
    type group =
      | Config;

    let pp: Fmt.t(group) =
      (ppf, g: group) =>
        switch (g) {
        | Config => Fmt.pf(ppf, "Config")
        };

    let group_of_string = (s): group =>
      switch (String.lowercase_ascii(s)) {
      | "config" => Config
      | _ => Fmt.invalid_arg("Unsupported ORX resource %s", s)
      };

    let string_of_group = (Config: group): string => "Config";

    let group =
      view(~format=pp, ~read=group_of_string, ~write=string_of_group, string);

    let add_storage =
      c(
        "orxResource_AddStorage",
        group @-> string @-> bool @-> returning(Status.t),
      );
  };

  module Camera = {
    type t = ptr(structure(T.Camera.t));

    let t: typ(t) = ptr(T.Camera.t);
    let t_opt: typ(option(t)) = ptr_opt(T.Camera.t);

    let create_from_config =
      c("orxCamera_CreateFromConfig", string @-> returning(t_opt));

    let get_position =
      c("orxCamera_GetPosition", t @-> Vector.t @-> returning(Vector.t));
    let set_position =
      c("orxCamera_SetPosition", t @-> Vector.t @-> returning(Status.t));

    let get_rotation = c("orxCamera_GetRotation", t @-> returning(float));
    let set_rotation =
      c("orxCamera_SetRotation", t @-> float @-> returning(Status.t));
  };

  module Object = {
    type t = ptr(structure(T.Object.t));

    let t: typ(t) = ptr(T.Object.t);
    let t_opt: typ(option(t)) = ptr_opt(T.Object.t);

    // Pointer/physical equality-based comparison
    let compare = (a: t, b: t): int => Ctypes.ptr_compare(a, b);
    let equal = (a, b) => compare(a, b) == 0;

    let of_void_pointer = c("orxOBJECT", ptr(void) @-> returning(t));

    // Object creation and presence
    let create_from_config =
      c("orxObject_CreateFromConfig", string @-> returning(t_opt));

    let enable = c("orxObject_Enable", t @-> bool @-> returning(void));

    // Basic attributes
    let get_name = c("orxObject_GetName", t @-> returning(string));

    let get_child_object = c("orxObject_GetChild", t @-> returning(t_opt));

    // FX
    let add_fx = c("orxObject_AddFX", t @-> string @-> returning(Status.t));
    let add_unique_fx =
      c("orxObject_AddUniqueFX", t @-> string @-> returning(Status.t));

    let add_delayed_fx =
      c(
        "orxObject_AddDelayedFX",
        t @-> string @-> float @-> returning(Status.t),
      );
    let add_unique_delayed_fx =
      c(
        "orxObject_AddUniqueDelayedFX",
        t @-> string @-> float @-> returning(Status.t),
      );

    let remove_fx =
      c("orxObject_RemoveFX", t @-> string @-> returning(Status.t));

    // Position and orientation
    let get_rotation = c("orxObject_GetRotation", t @-> returning(float));
    let set_rotation =
      c("orxObject_SetRotation", t @-> float @-> returning(Status.t));

    let get_world_position =
      c(
        "orxObject_GetWorldPosition",
        t @-> ptr(T.Vector.t) @-> returning(ptr(T.Vector.t)),
      );

    let set_position =
      c("orxObject_SetPosition", t @-> Vector.t @-> returning(Status.t));

    let set_scale =
      c("orxObject_SetScale", t @-> Vector.t @-> returning(Status.t));

    let set_text_string =
      c("orxObject_SetTextString", t @-> string @-> returning(Status.t));

    let set_life_time =
      c("orxObject_SetLifeTime", t @-> double @-> returning(Status.t));

    let add_time_line_track =
      c("orxObject_AddTimeLineTrack", t @-> string @-> returning(Status.t));

    // Physics
    let apply_force =
      c(
        "orxObject_ApplyForce",
        t @-> Vector.t @-> Vector.t_opt @-> returning(Status.t),
      );

    let apply_impulse =
      c(
        "orxObject_ApplyImpulse",
        t @-> Vector.t @-> Vector.t_opt @-> returning(Status.t),
      );

    let apply_torque =
      c("orxObject_ApplyTorque", t @-> float @-> returning(Status.t));

    // Color
    let set_rgb =
      c("orxObject_SetRGB", t @-> Vector.t @-> returning(Status.t));
    let set_rgb_recursive =
      c("orxObject_SetRGBRecursive", t @-> Vector.t @-> returning(void));

    let set_alpha =
      c("orxObject_SetAlpha", t @-> float @-> returning(Status.t));
    let set_alpha_recursive =
      c("orxObject_SetAlphaRecursive", t @-> float @-> returning(void));

    // Animation
    let set_target_anim =
      c("orxObject_SetTargetAnim", t @-> string @-> returning(Status.t));

    // Linking structures
    let link_structure =
      c(
        "orxObject_LinkStructure",
        t @-> Structure.t @-> returning(Status.t),
      );
  };

  module Viewport = {
    type t = ptr(structure(T.Viewport.t));

    let t = ptr(T.Viewport.t);
    let t_opt = ptr_opt(T.Viewport.t);

    let create_from_config =
      c("orxViewport_CreateFromConfig", string @-> returning(t_opt));

    let get_camera =
      c("orxViewport_GetCamera", t @-> returning(Camera.t_opt));
  };

  module Input = {
    let is_active = c("orxInput_IsActive", string @-> returning(bool));

    let has_new_status =
      c("orxInput_HasNewStatus", string @-> returning(bool));

    let get_binding =
      c(
        "orxInput_GetBinding",
        string
        @-> int
        @-> ptr(T.Input_type.t)
        @-> ptr(int)
        @-> ptr(T.Input_mode.t)
        @-> returning(Status.t),
      );

    let get_binding_name =
      c(
        "orxInput_GetBindingName",
        T.Input_type.t @-> int @-> T.Input_mode.t @-> returning(string),
      );
  };

  module Event = {
    type t = ptr(structure(T.Event.t));

    let t = ptr(T.Event.t);

    type payload('event) =
      | Fx: payload(T.Fx_event.Payload.t)
      | Input: payload(T.Input_event.Payload.t)
      | Physics: payload(T.Physics_event.Payload.t);

    type event('event) =
      | Fx: event(T.Fx_event.t)
      | Input: event(T.Input_event.t)
      | Physics: event(T.Physics_event.t);

    let to_event_id = (event: t): int64 => {
      Ctypes.getf(!@event, T.Event.event_id) |> Unsigned.UInt.to_int64;
    };

    let to_type = (event: t): T.Event_type.t =>
      Ctypes.getf(!@event, T.Event.event_type);

    let assert_type = (event: t, typ_: T.Event_type.t): unit => {
      to_type(event) == typ_
        ? () : Fmt.invalid_arg("Unexpected or invalid event type");
    };

    let unsafe_get_payload = (event: t, payload_type) => {
      let payload_field = Ctypes.getf(!@event, T.Event.payload);
      Ctypes.from_voidp(payload_type, payload_field);
    };

    let to_payload =
        (type a, event: t, payload_type: payload(a)): ptr(structure(a)) => {
      // Some dynamic type checking...
      switch (payload_type) {
      | Fx =>
        assert_type(event, T.Event_type.Fx);
        unsafe_get_payload(event, T.Fx_event.Payload.t);
      | Input =>
        assert_type(event, T.Event_type.Input);
        unsafe_get_payload(event, T.Input_event.Payload.t);
      | Physics =>
        assert_type(event, T.Event_type.Physics);
        unsafe_get_payload(event, T.Physics_event.Payload.t);
      };
    };

    let get_event_by_id = (event: t, map_from_constant) => {
      let event_id = to_event_id(event);
      switch (List.assoc_opt(event_id, map_from_constant)) {
      | None => Fmt.invalid_arg("Unhandled event id: %Ld", event_id)
      | Some(event) => event
      };
    };

    let to_event = (type a, event: t, event_type: event(a)): a => {
      switch (event_type) {
      | Fx =>
        assert_type(event, T.Event_type.Fx);
        get_event_by_id(event, T.Fx_event.map_from_constant);
      | Input =>
        assert_type(event, T.Event_type.Input);
        get_event_by_id(event, T.Input_event.map_from_constant);
      | Physics =>
        assert_type(event, T.Event_type.Physics);
        get_event_by_id(event, T.Physics_event.map_from_constant);
      };
    };
  };

  module Fx_event = {
    let get_name = (event: Event.t): string => {
      let payload = Event.to_payload(event, Fx);
      Ctypes.getf(!@payload, T.Fx_event.Payload.name);
    };
  };

  module Input_event = {
    let get_payload_field = (event: Event.t, field) => {
      let payload = Event.to_payload(event, Input);
      Ctypes.getf(!@payload, field);
    };

    let get_set_name = (event: Event.t): string => {
      get_payload_field(event, T.Input_event.Payload.set_name);
    };
    let get_input_name = (event: Event.t): string => {
      get_payload_field(event, T.Input_event.Payload.input_name);
    };
  };

  module Physics = {
    let get_gravity =
      c("orxPhysics_GetGravity", Vector.t @-> returning(Vector.t_opt));

    let set_gravity =
      c("orxPhysics_SetGravity", Vector.t @-> returning(Status.t));
  };

  module Texture = {
    type t = ptr(structure(T.Texture.t));

    let t = ptr(T.Texture.t);
  };

  module Display = {
    module Rgba = {
      let make = (rgba: int32): structure(T.Rgba.t) => {
        let rgba' = make(T.Rgba.t);
        setf(rgba', T.Rgba.rgba, Unsigned.UInt32.of_int32(rgba));
        rgba';
      };
    };

    module Draw = {
      let circle =
        c(
          "orxDisplay_DrawCircle",
          Vector.t @-> float @-> T.Rgba.t @-> bool @-> returning(Status.t),
        );

      let line =
        c(
          "orxDisplay_DrawLine",
          Vector.t @-> Vector.t @-> T.Rgba.t @-> returning(Status.t),
        );
    };
  };
};