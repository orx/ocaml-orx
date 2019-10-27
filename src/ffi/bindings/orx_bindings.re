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

  module Bank = {
    type t = ptr(structure(T.Bank.t));

    let t = ptr(T.Bank.t);
    let t_opt = ptr_opt(T.Bank.t);

    let get_next =
      c(
        "orxBank_GetNext",
        t @-> ptr_opt(void) @-> returning(ptr_opt(void)),
      );
  };

  module String_id = {
    type t = T.String_id.t;

    let t = uint32_t;

    let undefined = T.String_id.undefined;

    let get_id = c("orxString_GetID", string @-> returning(t));
    let get_from_id = c("orxString_GetFromID", t @-> returning(string));
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

  module Obox = {
    type t = ptr(structure(T.Obox.t));

    let t = ptr(T.Obox.t);
    let t_opt = ptr_opt(T.Obox.t);

    let allocate_raw = (): t => allocate_n(T.Obox.t, ~count=1);

    let set_2d =
      c(
        "orxOBox_2DSet",
        t @-> Vector.t @-> Vector.t @-> Vector.t @-> float @-> returning(t),
      );

    let copy = c("orxOBox_Copy", t @-> t @-> returning(t));

    let get_center =
      c("orxOBox_GetCenter", t @-> Vector.t @-> returning(Vector.t));

    let move = c("orxOBox_Move", t @-> t @-> Vector.t @-> returning(t));

    let rotate_2d =
      c("orxOBox_2DRotate", t @-> t @-> float @-> returning(t));

    let is_inside =
      c("orxOBox_IsInside", t @-> Vector.t @-> returning(bool));

    let is_inside_2d =
      c("orxOBox_2DIsInside", t @-> Vector.t @-> returning(bool));
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

    let of_any = c("orxSTRUCTURE", ptr(void) @-> returning(t));
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
  };

  module Sound = {
    type t = ptr(structure(T.Sound.t));

    let t = ptr(T.Sound.t);
    let t_opt = ptr_opt(T.Sound.t);

    let create_from_config =
      c("orxSound_CreateFromConfig", string @-> returning(t_opt));

    let get_name = c("orxSound_GetName", t @-> returning(string));

    let get_status =
      c("orxSound_GetStatus", t @-> returning(T.Sound_status.t));

    let play = c("orxSound_Play", t @-> returning(Status.t));
    let pause = c("orxSound_Pause", t @-> returning(Status.t));
    let stop = c("orxSound_Stop", t @-> returning(Status.t));

    let get_duration = c("orxSound_GetDuration", t @-> returning(float));

    let get_pitch = c("orxSound_GetPitch", t @-> returning(float));
    let set_pitch =
      c("orxSound_SetPitch", t @-> float @-> returning(Status.t));

    let get_volume = c("orxSound_GetVolume", t @-> returning(float));
    let set_volume =
      c("orxSound_SetVolume", t @-> float @-> returning(Status.t));

    let get_attenuation =
      c("orxSound_GetAttenuation", t @-> returning(float));
    let set_attenuation =
      c("orxSound_SetAttenuation", t @-> float @-> returning(Status.t));
  };

  module Mouse = {
    let set_position =
      c("orxMouse_SetPosition", Vector.t @-> returning(Status.t));

    let get_position =
      c("orxMouse_GetPosition", Vector.t @-> returning(Vector.t_opt));

    let is_button_pressed =
      c("orxMouse_IsButtonPressed", T.Mouse_button.t @-> returning(bool));

    let get_move_delta =
      c("orxMouse_GetMoveDelta", Vector.t @-> returning(Vector.t_opt));

    let get_wheel_delta =
      c("orxMouse_GetWheelDelta", void @-> returning(float));

    let show_cursor = c("orxMouse_ShowCursor", bool @-> returning(Status.t));

    let set_cursor =
      c(
        "orxMouse_SetCursor",
        string @-> Vector.t_opt @-> returning(Status.t),
      );

    let get_button_name =
      c("orxMouse_GetButtonName", T.Mouse_button.t @-> returning(string));

    let get_axis_name =
      c("orxMouse_GetAxisName", T.Mouse_axis.t @-> returning(string));
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

    /* Select a config section to work within (stack-based) */
    let push_section =
      c("orxConfig_PushSection", string @-> returning(Status.t));
    let pop_section =
      c("orxConfig_PopSection", void @-> returning(Status.t));

    // Select a config section to work with (manually manage state)
    let get_current_section =
      c("orxConfig_GetCurrentSection", void @-> returning(string));
    let select_section =
      c("orxConfig_SelectSection", string @-> returning(Status.t));

    // Enumerate sections
    let get_section_count =
      c("orxConfig_GetSectionCount", void @-> returning(int));
    let get_section = c("orxConfig_GetSection", int @-> returning(string));

    // Enumerate keys in the current section
    let get_key_count = c("orxConfig_GetKeyCount", void @-> returning(int));
    let get_key = c("orxConfig_GetKey", int @-> returning(string));

    // Check for section and value existence
    let has_section = c("orxConfig_HasSection", string @-> returning(bool));
    let has_value = c("orxConfig_HasValue", string @-> returning(bool));

    // Clearing sections/values
    let clear_section =
      c("orxConfig_ClearSection", string @-> returning(Status.t));
    let clear_value =
      c("orxConfig_ClearValue", string @-> returning(Status.t));

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

    // Create a new clock
    let create_from_config =
      c("orxClock_CreateFromConfig", string @-> returning(t_opt));

    let create =
      c("orxClock_Create", float @-> T.Clock_type.t @-> returning(t_opt));

    // Get a clock in various ways
    let get = c("orxClock_Get", string @-> returning(t_opt));

    let find_first =
      c("orxClock_FindFirst", float @-> T.Clock_type.t @-> returning(t_opt));

    // Get clock properties
    let get_name = c("orxClock_GetName", t @-> returning(string));

    let get_info = c("orxClock_GetInfo", t @-> returning(Info.t));

    // Change a clock
    let set_modifier =
      c(
        "orxClock_SetModifier",
        t @-> T.Clock_modifier.t @-> float @-> returning(Status.t),
      );

    let set_tick_size =
      c("orxClock_SetTickSize", t @-> float @-> returning(Status.t));

    // Adjust clock's progress
    let restart = c("orxClock_Restart", t @-> returning(Status.t));

    let pause = c("orxClock_Pause", t @-> returning(Status.t));
    let unpause = c("orxClock_Unpause", t @-> returning(Status.t));
    let is_paused = c("orxClock_IsPaused", t @-> returning(bool));
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

    // Creating cameras
    let create_from_config =
      c("orxCamera_CreateFromConfig", string @-> returning(t_opt));

    // Get camera by name
    let get = c("orxCamera_Get", string @-> returning(t_opt));

    // Get misc camera properties
    let get_name = c("orxCamera_GetName", t @-> returning(string));

    // Camera positioning
    let get_position =
      c("orxCamera_GetPosition", t @-> Vector.t @-> returning(Vector.t));
    let set_position =
      c("orxCamera_SetPosition", t @-> Vector.t @-> returning(Status.t));

    // Camera rotation
    let get_rotation = c("orxCamera_GetRotation", t @-> returning(float));
    let set_rotation =
      c("orxCamera_SetRotation", t @-> float @-> returning(Status.t));

    // Camera zoom
    let get_zoom = c("orxCamera_GetZoom", t @-> returning(float));
    let set_zoom =
      c("orxCamera_SetZoom", t @-> float @-> returning(Status.t));

    // Camera frustum
    let set_frustum =
      c(
        "orxCamera_SetFrustum",
        t @-> float @-> float @-> float @-> float @-> returning(Status.t),
      );
  };

  module Object = {
    type t = ptr(structure(T.Object.t));

    let t: typ(t) = ptr(T.Object.t);
    let t_opt: typ(option(t)) = ptr_opt(T.Object.t);

    // Pointer/physical equality-based comparison
    let compare = (a: t, b: t): int => Ctypes.ptr_compare(a, b);
    let equal = (a, b) => compare(a, b) == 0;

    let of_void_pointer = c("orxOBJECT", ptr(void) @-> returning(t));
    let to_void_pointer = (o: t) => to_voidp(o);

    // Object creation and presence
    let create_from_config =
      c("orxObject_CreateFromConfig", string @-> returning(t_opt));

    let enable = c("orxObject_Enable", t @-> bool @-> returning(void));
    let enable_recursive =
      c("orxObject_EnableRecursive", t @-> bool @-> returning(void));
    let is_enabled = c("orxObject_IsEnabled", t @-> returning(bool));

    let pause = c("orxObject_Pause", t @-> bool @-> returning(void));
    let is_paused = c("orxObject_IsPaused", t @-> returning(bool));

    // Basic attributes
    let get_name = c("orxObject_GetName", t @-> returning(string));

    let get_child_object = c("orxObject_GetChild", t @-> returning(t_opt));

    // Bounding box
    let get_bounding_box =
      c("orxObject_GetBoundingBox", t @-> Obox.t @-> returning(Obox.t_opt));

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
        t @-> Vector.t @-> returning(Vector.t_opt),
      );

    let get_position =
      c("orxObject_GetPosition", t @-> Vector.t @-> returning(Vector.t_opt));
    let set_position =
      c("orxObject_SetPosition", t @-> Vector.t @-> returning(Status.t));

    let get_scale =
      c("orxObject_GetScale", t @-> Vector.t @-> returning(Vector.t_opt));
    let set_scale =
      c("orxObject_SetScale", t @-> Vector.t @-> returning(Status.t));

    // Text
    let set_text_string =
      c("orxObject_SetTextString", t @-> string @-> returning(Status.t));

    let get_text_string =
      c("orxObject_GetTextString", t @-> returning(string));

    // Life time
    let set_life_time =
      c("orxObject_SetLifeTime", t @-> float @-> returning(Status.t));

    let get_life_time = c("orxObject_GetLifeTime", t @-> returning(float));

    let get_active_time =
      c("orxObject_GetActiveTime", t @-> returning(float));

    // Time line
    let add_time_line_track =
      c("orxObject_AddTimeLineTrack", t @-> string @-> returning(Status.t));

    let remove_time_line_track =
      c(
        "orxObject_RemoveTimeLineTrack",
        t @-> string @-> returning(Status.t),
      );

    let enable_time_line =
      c("orxObject_EnableTimeLine", t @-> bool @-> returning(void));

    let is_time_line_enabled =
      c("orxObject_IsTimeLineEnabled", t @-> returning(bool));

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

    let set_speed =
      c("orxObject_SetSpeed", t @-> Vector.t @-> returning(Status.t));
    let get_speed =
      c("orxObject_GetSpeed", t @-> Vector.t @-> returning(Vector.t_opt));

    let set_relative_speed =
      c(
        "orxObject_SetRelativeSpeed",
        t @-> Vector.t @-> returning(Status.t),
      );
    let get_relative_speed =
      c(
        "orxObject_GetRelativeSpeed",
        t @-> Vector.t @-> returning(Vector.t_opt),
      );

    let set_angular_velocity =
      c("orxObject_SetAngularVelocity", t @-> float @-> returning(Status.t));
    let get_angular_velocity =
      c("orxObject_GetAngularVelocity", t @-> returning(float));

    let set_custom_gravity =
      c(
        "orxObject_SetCustomGravity",
        t @-> Vector.t @-> returning(Status.t),
      );
    let get_custom_gravity =
      c(
        "orxObject_GetCustomGravity",
        t @-> Vector.t @-> returning(Vector.t_opt),
      );

    let get_mass = c("orxObject_GetMass", t @-> returning(float));

    let get_mass_center =
      c(
        "orxObject_GetMassCenter",
        t @-> Vector.t @-> returning(Vector.t_opt),
      );

    let raycast =
      c(
        "orxObject_Raycast",
        Vector.t
        @-> Vector.t
        @-> uint16_t
        @-> uint16_t
        @-> bool
        @-> Vector.t_opt
        @-> Vector.t_opt
        @-> returning(t_opt),
      );

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

    // Sound
    let add_sound =
      c("orxObject_AddSound", t @-> string @-> returning(Status.t));

    let remove_sound =
      c("orxObject_RemoveSound", t @-> string @-> returning(Status.t));

    let get_last_added_sound =
      c("orxObject_GetLastAddedSound", t @-> returning(Sound.t_opt));

    let set_volume =
      c("orxObject_SetVolume", t @-> float @-> returning(Status.t));

    let set_pitch =
      c("orxObject_SetPitch", t @-> float @-> returning(Status.t));

    let play = c("orxObject_Play", t @-> returning(Status.t));

    let stop = c("orxObject_Stop", t @-> returning(Status.t));

    // Linking structures
    let link_structure =
      c(
        "orxObject_LinkStructure",
        t @-> Structure.t @-> returning(Status.t),
      );

    // Object selection
    // Neighbor = Object(s) within a bounding box
    let create_neighbor_list =
      c(
        "orxObject_CreateNeighborList",
        Obox.t @-> String_id.t @-> returning(Bank.t_opt),
      );

    let delete_neighbor_list =
      c("orxObject_DeleteNeighborList", Bank.t @-> returning(void));

    let pick =
      c("orxObject_Pick", Vector.t @-> String_id.t @-> returning(t_opt));

    let box_pick =
      c("orxObject_BoxPick", Obox.t @-> String_id.t @-> returning(t_opt));

    // Group ID and object selection
    let get_default_group_id =
      c("orxObject_GetDefaultGroupID", void @-> returning(String_id.t));

    let get_group_id =
      c("orxObject_GetGroupID", t @-> returning(String_id.t));
    let set_group_id =
      c("orxObject_SetGroupID", t @-> String_id.t @-> returning(Status.t));

    let set_group_id_recursive =
      c(
        "orxObject_SetGroupIDRecursive",
        t @-> String_id.t @-> returning(void),
      );

    let get_next =
      c("orxObject_GetNext", t_opt @-> String_id.t @-> returning(t_opt));
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

    let has_been_activated =
      c("orxInput_HasBeenActivated", string @-> returning(bool));

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
      | Physics: payload(T.Physics_event.Payload.t)
      | Sound: payload(T.Sound_event.Payload.t);

    type event('event) =
      | Config: event(T.Config_event.t)
      | Fx: event(T.Fx_event.t)
      | Input: event(T.Input_event.t)
      | Physics: event(T.Physics_event.t)
      | Sound: event(T.Sound_event.t);

    let get_flag = c("orxEVENT_GET_FLAG", uint32_t @-> returning(uint32_t));

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
      | Sound =>
        assert_type(event, T.Event_type.Sound);
        unsafe_get_payload(event, T.Sound_event.Payload.t);
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
      | Config =>
        assert_type(event, T.Event_type.Config);
        get_event_by_id(event, T.Config_event.map_from_constant);
      | Fx =>
        assert_type(event, T.Event_type.Fx);
        get_event_by_id(event, T.Fx_event.map_from_constant);
      | Input =>
        assert_type(event, T.Event_type.Input);
        get_event_by_id(event, T.Input_event.map_from_constant);
      | Physics =>
        assert_type(event, T.Event_type.Physics);
        get_event_by_id(event, T.Physics_event.map_from_constant);
      | Sound =>
        assert_type(event, T.Event_type.Sound);
        get_event_by_id(event, T.Sound_event.map_from_constant);
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

  module Sound_event = {
    let get_sound = (event: Event.t): Sound.t => {
      let payload = Event.to_payload(event, Sound);
      Ctypes.getf(!@payload, T.Sound_event.Payload.sound);
    };
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

  module Screenshot = {
    let capture = c("orxScreenshot_Capture", void @-> returning(Status.t));
  };

  module Locale = {
    let select_language =
      c("orxLocale_SelectLanguage", string @-> returning(Status.t));

    let get_current_language =
      c("orxLocale_GetCurrentLanguage", void @-> returning(string));

    let has_language =
      c("orxLocale_HasLanguage", string @-> returning(bool));

    let get_language_count =
      c("orxLocale_GetLanguageCount", void @-> returning(uint32_t));

    let get_language =
      c("orxLocale_GetLanguage", uint32_t @-> returning(string));

    let has_string = c("orxLocale_HasString", string @-> returning(bool));

    let get_string = c("orxLocale_GetString", string @-> returning(string));

    let set_string =
      c("orxLocale_SetString", string @-> string @-> returning(Status.t));

    let get_key_count =
      c("orxLocale_GetKeyCount", void @-> returning(uint32_t));

    let get_key = c("orxLocale_GetKey", uint32_t @-> returning(string));
  };
};