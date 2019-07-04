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

    let make = (~x, ~y, ~z): t => {
      let v_ptr = allocate_raw();
      let v = !@v_ptr;
      Ctypes.setf(v, T.Vector.x, x);
      Ctypes.setf(v, T.Vector.y, y);
      Ctypes.setf(v, T.Vector.z, z);
      v_ptr;
    };

    let copy = (~x=?, ~y=?, ~z=?, src: t) => {
      let dest = allocate_raw();
      let dest' = !@dest;
      let src' = !@src;
      let set = (field, value) => {
        let actual =
          switch (value) {
          | None => Ctypes.getf(src', field)
          | Some(value') => value'
          };
        Ctypes.setf(dest', field, actual);
      };
      set(T.Vector.x, x);
      set(T.Vector.y, y);
      set(T.Vector.z, z);
      dest;
    };

    let rotate_2d =
      c("orxVector_2DRotate", t @-> t @-> float @-> returning(t));
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
    module Info = {
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
    };

    type t = ptr(structure(T.Clock.t));

    let t: typ(t) = ptr(T.Clock.t);
    let t_opt: typ(option(t)) = ptr_opt(T.Clock.t);

    let find_first =
      c("orxClock_FindFirst", float @-> T.Clock_type.t @-> returning(t_opt));

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

    let get_rotation = c("orxCamera_GetRotation", t @-> returning(float));

    let set_rotation =
      c("orxCamera_SetRotation", t @-> float @-> returning(Status.t));
  };

  module Object = {
    type t = ptr(structure(T.Object.t));

    let t: typ(t) = ptr(T.Object.t);
    let t_opt: typ(option(t)) = ptr_opt(T.Object.t);

    let of_void_pointer = (p: ptr(unit)): ptr(structure(T.Object.t)) => {
      from_voidp(T.Object.t, p);
    };

    // Object creation and presence
    let create_from_config =
      c("orxObject_CreateFromConfig", string @-> returning(t_opt));

    let enable = c("orxObject_Enable", t @-> bool @-> returning(void));

    // Basic attributes
    let get_name = c("orxObject_GetName", t @-> returning(string));

    let get_child_object = c("orxObject_GetChild", t @-> returning(t_opt));

    // FX
    let add_fx = c("orxObject_AddFX", t @-> string @-> returning(Status.t));

    // Position and orientation
    let get_rotation = c("orxObject_GetRotation", t @-> returning(float));

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

    // Animation
    let set_target_anim =
      c("orxObject_SetTargetAnim", t @-> string @-> returning(Status.t));
  };

  module Viewport = {
    type t = ptr(structure(T.Viewport.t));

    let t = ptr_opt(T.Viewport.t);

    let create_from_config =
      c("orxViewport_CreateFromConfig", string @-> returning(t));

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

    let to_event_id = (event: t): int64 => {
      Ctypes.getf(!@event, T.Event.event_id) |> Unsigned.UInt.to_int64;
    };

    module Physics = {
      let get_sender = (event: t): Object.t =>
        Ctypes.getf(!@event, T.Event.sender) |> Object.of_void_pointer;
      let get_recipient = (event: t): Object.t =>
        Ctypes.getf(!@event, T.Event.recipient) |> Object.of_void_pointer;

      let get_event = (event: t): T.Physics_event.t => {
        let event_id = to_event_id(event);
        let event =
          List.assoc_opt(event_id, T.Physics_event.map_from_constant);
        switch (event) {
        | None => Fmt.invalid_arg("Unhandled physics event id: %Ld", event_id)
        | Some(event) => event
        };
      };
    };

    let to_type = (event: t): T.Event_type.t =>
      Ctypes.getf(!@event, T.Event.event_type);
  };

  module Physics = {
    let get_gravity =
      c("orxPhysics_GetGravity", Vector.t @-> returning(Vector.t_opt));

    let set_gravity =
      c("orxPhysics_SetGravity", Vector.t @-> returning(Status.t));
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