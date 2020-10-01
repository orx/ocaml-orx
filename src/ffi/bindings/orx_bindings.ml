module T = Orx_types

module Bindings (F : Ctypes.FOREIGN) = struct
  let c name f = F.foreign name f

  module Ctypes_for_stubs = struct
    include Ctypes

    let ( @-> ) = F.( @-> )

    let returning = F.returning
  end

  open Ctypes_for_stubs

  module Status = struct
    type 'ok result = ('ok, [ `Orx ]) Stdlib.result
    type t = unit result

    let ok = Ok ()
    let error = Error `Orx

    let open_error (r : 'ok result) : ('ok, [> `Orx ]) Stdlib.result =
      match r with
      | Ok _ as o -> o
      | Error `Orx -> Error `Orx

    let of_int i : t =
      match i with
      | 1 -> Ok ()
      | 0 -> Error `Orx
      | _ -> Fmt.invalid_arg "Unsupported Orx status %d" i

    let of_int_exn msg i : unit =
      match of_int i with
      | Ok () -> ()
      | Error `Orx -> invalid_arg msg

    let to_int (s : t) : int =
      match s with
      | Ok () -> 1
      | Error `Orx -> 0

    let pp =
      Fmt.(result ~ok:(const string "success") ~error:(const string "failure"))

    let t = view ~format:pp ~read:of_int ~write:to_int int

    let as_exn =
      view
        ~read:(of_int_exn "Unsupported Orx failure state")
        ~write:(fun _ -> 1)
        int

    let invalid msg = view ~read:(of_int_exn msg) ~write:(fun _ -> 1) int

    let body_error_message = "No physics body associated with orx object"
    let body_exn = invalid body_error_message
    let graphic_exn = invalid "No graphic associated with orx object"
    let sound_exn = invalid "No sound associated with orx object"

    let raise_error () = invalid_arg "Orx.Status.get* called on error"

    let get (result : t) =
      match result with
      | Ok () -> ()
      | Error `Orx -> raise_error ()

    let get_ok (result : _ result) =
      match result with
      | Ok v -> v
      | Error `Orx -> raise_error ()

    let ignore (result : t) = ignore result

    let raise fmt =
      Fmt.kstr
        (fun error_message (result : _ result) ->
          match result with
          | Ok v -> v
          | Error `Orx -> invalid_arg error_message)
        fmt
  end

  module Bank = struct
    type t = T.Bank.t structure ptr

    let t = ptr T.Bank.t

    let t_opt = ptr_opt T.Bank.t

    let get_next =
      c "orxBank_GetNext" (t @-> ptr_opt void @-> returning (ptr_opt void))
  end

  module String_id = struct
    type t = T.String_id.t

    let t = uint32_t

    let undefined = T.String_id.undefined

    let get_id = c "orxString_GetID" (string @-> returning t)

    let get_from_id = c "orxString_GetFromID" (t @-> returning string)
  end

  module Vector = struct
    type t = T.Vector.t structure ptr

    let t = ptr T.Vector.t

    let t_opt = ptr_opt T.Vector.t

    let allocate_raw () : t = allocate_n T.Vector.t ~count:1

    let equal = c "orxVector_AreEqual" (t @-> t @-> returning bool)

    let set = c "orxVector_Set" (t @-> float @-> float @-> float @-> returning t)

    let copy = c "orxVector_Copy" (t @-> t @-> returning t)

    let mulf = c "orxVector_Mulf" (t @-> t @-> float @-> returning t)

    let divf = c "orxVector_Divf" (t @-> t @-> float @-> returning t)

    let add = c "orxVector_Add" (t @-> t @-> t @-> returning t)

    let sub = c "orxVector_Sub" (t @-> t @-> t @-> returning t)

    let mul = c "orxVector_Mul" (t @-> t @-> t @-> returning t)

    let div = c "orxVector_Div" (t @-> t @-> t @-> returning t)

    let dot = c "orxVector_Dot" (t @-> t @-> returning float)

    let dot_2d = c "orxVector_2DDot" (t @-> t @-> returning float)

    let cross = c "orxVector_Cross" (t @-> t @-> t @-> returning t)

    let neg = c "orxVector_Neg" (t @-> t @-> returning t)

    let min = c "orxVector_Min" (t @-> t @-> t @-> returning t)

    let max = c "orxVector_Max" (t @-> t @-> t @-> returning t)

    let normalize = c "orxVector_Normalize" (t @-> t @-> returning t)

    let reciprocal = c "orxVector_Rec" (t @-> t @-> returning t)

    let round = c "orxVector_Round" (t @-> t @-> returning t)

    let floor = c "orxVector_Floor" (t @-> t @-> returning t)

    let get_distance = c "orxVector_GetDistance" (t @-> t @-> returning float)

    let get_size = c "orxVector_GetSize" (t @-> returning float)

    let lerp = c "orxVector_Lerp" (t @-> t @-> t @-> float @-> returning t)

    let rotate_2d = c "orxVector_2DRotate" (t @-> t @-> float @-> returning t)
  end

  module Obox = struct
    type t = T.Obox.t structure ptr

    let t = ptr T.Obox.t

    let t_opt = ptr_opt T.Obox.t

    let allocate_raw () : t = allocate_n T.Obox.t ~count:1

    let set_2d =
      c "orxOBox_2DSet"
        (t @-> Vector.t @-> Vector.t @-> Vector.t @-> float @-> returning t)

    let copy = c "orxOBox_Copy" (t @-> t @-> returning t)

    let get_center =
      c "orxOBox_GetCenter" (t @-> Vector.t @-> returning Vector.t)

    let move = c "orxOBox_Move" (t @-> t @-> Vector.t @-> returning t)

    let rotate_2d = c "orxOBox_2DRotate" (t @-> t @-> float @-> returning t)

    let is_inside = c "orxOBox_IsInside" (t @-> Vector.t @-> returning bool)

    let is_inside_2d = c "orxOBox_2DIsInside" (t @-> Vector.t @-> returning bool)
  end

  module Color = struct
    type t = T.Color.t structure ptr

    let t = ptr T.Color.t

    let t_opt = ptr_opt T.Color.t

    let allocate_raw () : t = allocate_n T.Color.t ~count:1
  end

  module Structure = struct
    type t = T.Structure.t structure ptr

    module Guid = struct
      type t = Unsigned.uint64

      let t = uint64_t

      let (compare, equal, pp) = Unsigned.UInt64.(compare, equal, pp)
    end

    let t = ptr T.Structure.t

    let t_opt = ptr_opt T.Structure.t

    let of_void_pointer = c "orxSTRUCTURE" (ptr void @-> returning t_opt)

    let to_void_pointer (s : t) = to_voidp s

    let get_guid = c "orxStructure_GetGUID" (t @-> returning Guid.t)

    let get = c "orxStructure_Get" (Guid.t @-> returning t_opt)
  end

  module Body_part = struct
    type t = T.Body_part.t structure ptr

    let t = ptr T.Body_part.t

    let t_opt = ptr_opt T.Body_part.t

    let set_self_flags =
      c "orxBody_SetPartSelfFlags" (t @-> uint16_t @-> returning Status.as_exn)
  end

  module Body = struct
    type t = T.Body.t structure ptr

    let t = ptr T.Body.t

    let t_opt = ptr_opt T.Body.t

    let of_void_pointer = c "orxBODY" (ptr void @-> returning t_opt)

    let get_next_part =
      c "orxBody_GetNextPart"
        (t @-> Body_part.t_opt @-> returning Body_part.t_opt)
  end

  module Texture = struct
    type t = T.Texture.t structure ptr

    let t = ptr T.Texture.t

    let t_opt = ptr_opt T.Texture.t

    let create_from_file =
      c "orxTexture_CreateFromFile" (string @-> bool @-> returning t_opt)

    let delete = c "orxTexture_Delete" (t @-> returning Status.t)

    let clear_cache = c "orxTexture_ClearCache" (void @-> returning Status.t)

    let get_size =
      c "orxTexture_GetSize"
        (t @-> ptr float @-> ptr float @-> returning Status.t)
  end

  module Graphic = struct
    type t = T.Graphic.t structure ptr

    let t = ptr T.Graphic.t

    let t_opt = ptr_opt T.Graphic.t

    let of_void_pointer = c "orxGRAPHIC" (ptr void @-> returning t_opt)

    let create = c "orxGraphic_Create" (void @-> returning t_opt)

    let create_from_config =
      c "orxGraphic_CreateFromConfig" (string @-> returning t_opt)

    let delete = c "orxGraphic_Delete" (t @-> returning Status.t)

    (* Graphic dimensions on the source texture *)
    let set_size =
      c "orxGraphic_SetSize" (t @-> Vector.t @-> returning Status.as_exn)

    let get_size = c "orxGraphic_GetSize" (t @-> Vector.t @-> returning Vector.t)

    (* Graphic origin on the source texture *)
    let set_origin =
      c "orxGraphic_SetOrigin" (t @-> Vector.t @-> returning Status.as_exn)

    let get_origin =
      c "orxGraphic_GetOrigin" (t @-> Vector.t @-> returning Vector.t)

    (* Flip a graphic on the X or Y axis *)
    let set_flip =
      c "orxGraphic_SetFlip" (t @-> bool @-> bool @-> returning Status.as_exn)

    (* Set the pivot point for a graphic *)
    let set_pivot =
      c "orxGraphic_SetPivot" (t @-> Vector.t @-> returning Status.as_exn)

    (* Set texture data associated with this graphic *)
    let set_data =
      c "orxGraphic_SetData" (t @-> Structure.t @-> returning Status.t)
  end

  module Sound = struct
    type t = T.Sound.t structure ptr

    let t = ptr T.Sound.t

    let t_opt = ptr_opt T.Sound.t

    let of_void_pointer = c "orxSOUND" (ptr void @-> returning t_opt)

    let status_err_no_data = Status.invalid "No sound data or invalid setting"

    let create_from_config =
      c "orxSound_CreateFromConfig" (string @-> returning t_opt)

    let get_name = c "orxSound_GetName" (t @-> returning string)

    let get_status = c "orxSound_GetStatus" (t @-> returning T.Sound_status.t)

    let play = c "orxSound_Play" (t @-> returning status_err_no_data)

    let pause = c "orxSound_Pause" (t @-> returning status_err_no_data)

    let stop = c "orxSound_Stop" (t @-> returning status_err_no_data)

    let get_duration = c "orxSound_GetDuration" (t @-> returning float)

    let get_pitch = c "orxSound_GetPitch" (t @-> returning float)

    let set_pitch =
      c "orxSound_SetPitch" (t @-> float @-> returning status_err_no_data)

    let get_volume = c "orxSound_GetVolume" (t @-> returning float)

    let set_volume =
      c "orxSound_SetVolume" (t @-> float @-> returning status_err_no_data)

    let get_attenuation = c "orxSound_GetAttenuation" (t @-> returning float)

    let set_attenuation =
      c "orxSound_SetAttenuation" (t @-> float @-> returning status_err_no_data)
  end

  module Mouse = struct
    let set_position = c "orxMouse_SetPosition" (Vector.t @-> returning Status.t)

    let get_position =
      c "orxMouse_GetPosition" (Vector.t @-> returning Vector.t_opt)

    let is_button_pressed =
      c "orxMouse_IsButtonPressed" (T.Mouse_button.t @-> returning bool)

    let get_move_delta =
      c "orxMouse_GetMoveDelta" (Vector.t @-> returning Vector.t_opt)

    let get_wheel_delta = c "orxMouse_GetWheelDelta" (void @-> returning float)

    let show_cursor = c "orxMouse_ShowCursor" (bool @-> returning Status.t)

    let set_cursor =
      c "orxMouse_SetCursor" (string @-> Vector.t_opt @-> returning Status.t)

    let get_button_name =
      c "orxMouse_GetButtonName" (T.Mouse_button.t @-> returning string)

    let get_axis_name =
      c "orxMouse_GetAxisName" (T.Mouse_axis.t @-> returning string)
  end

  module Config = struct
    let set_basename =
      c "orxConfig_SetBaseName" (string @-> returning Status.as_exn)

    (* Load config from a file *)
    let load = c "orxConfig_Load" (string @-> returning Status.t)

    (* Load config from a string already in memory *)
    let load_from_memory =
      c "orxConfig_LoadFromMemory" (string @-> int @-> returning Status.t)

    (* Select a config section to work within (stack-based) *)
    let push_section =
      c "orxConfig_PushSection" (string @-> returning Status.as_exn)

    let pop_section =
      c "orxConfig_PopSection"
        (void
        @-> returning
              (Status.invalid
                 "Orx.Config.pop_section: Empty config section stack")
        )

    (* Select a config section to work with (manually manage state) *)
    let get_current_section =
      c "orxConfig_GetCurrentSection" (void @-> returning string)

    let select_section =
      c "orxConfig_SelectSection" (string @-> returning Status.as_exn)

    (* Enumerate sections *)
    let get_section_count =
      c "orxConfig_GetSectionCount" (void @-> returning int)

    let get_section = c "orxConfig_GetSection" (int @-> returning string)

    (* Enumerate keys in the current section *)
    let get_key_count = c "orxConfig_GetKeyCount" (void @-> returning int)

    let get_key = c "orxConfig_GetKey" (int @-> returning string)

    let get_parent = c "orxConfig_GetParent" (string @-> returning string_opt)

    (* Check for section and value existence *)
    let has_section = c "orxConfig_HasSection" (string @-> returning bool)

    let has_value = c "orxConfig_HasValue" (string @-> returning bool)

    (* Clearing sections/values *)
    let clear_section =
      c "orxConfig_ClearSection" (string @-> returning Status.t)

    let clear_value = c "orxConfig_ClearValue" (string @-> returning Status.t)

    (* Get values from a config *)
    let get_string = c "orxConfig_GetString" (string @-> returning string)

    let get_bool = c "orxConfig_GetBool" (string @-> returning bool)

    let get_float = c "orxConfig_GetFloat" (string @-> returning float)

    (* XXX: Pretend a signed 64bit integer is always enough and the values will
       always fit in an OCaml int *)
    let get_int = c "orxConfig_GetS64" (string @-> returning int)

    let get_vector =
      c "orxConfig_GetVector" (string @-> Vector.t @-> returning Vector.t)

    (* Set config values *)
    let set_string =
      c "orxConfig_SetString" (string @-> string @-> returning Status.as_exn)

    let set_bool =
      c "orxConfig_SetBool" (string @-> bool @-> returning Status.as_exn)

    let set_float =
      c "orxConfig_SetFloat" (string @-> float @-> returning Status.as_exn)

    let set_int =
      c "orxConfig_SetS64" (string @-> int @-> returning Status.as_exn)

    let set_vector =
      c "orxConfig_SetVector" (string @-> Vector.t @-> returning Status.as_exn)

    (* Get/Set values from a list *)
    let is_list = c "orxConfig_IsList" (string @-> returning bool)

    let get_list_count = c "orxConfig_GetListCount" (string @-> returning int)

    let int_or_random =
      let read (i : int) : int option =
        match i with
        | -1 -> None
        | i -> Some i
      in
      let write (o : int option) : int =
        match o with
        | None -> -1
        | Some i -> i
      in
      view ~read ~write int

    let get_list_string =
      c "orxConfig_GetListString" (string @-> int_or_random @-> returning string)

    let get_list_bool =
      c "orxConfig_GetListBool" (string @-> int_or_random @-> returning bool)

    let get_list_float =
      c "orxConfig_GetListFloat" (string @-> int_or_random @-> returning float)

    let get_list_int =
      c "orxConfig_GetListS64" (string @-> int_or_random @-> returning int)

    let get_list_vector =
      c "orxConfig_GetListVector"
        (string @-> int_or_random @-> Vector.t @-> returning Vector.t)

    (* Modify a list of config values *)
    let set_list_string =
      c "orxConfig_SetListString"
        (string @-> ptr string @-> int @-> returning Status.as_exn)

    let append_list_string =
      c "orxConfig_AppendListString"
        (string @-> ptr string @-> int @-> returning Status.as_exn)

    let get_guid = c "orxConfig_GetU64" (string @-> returning Structure.Guid.t)

    let set_guid =
      c "orxConfig_SetU64"
        (string @-> Structure.Guid.t @-> returning Status.as_exn)
  end

  module Clock = struct
    type t = T.Clock.t structure ptr

    let t : t typ = ptr T.Clock.t

    let t_opt : t option typ = ptr_opt T.Clock.t

    module Info = struct
      type clock = t

      let clock = t

      let clock_opt = t_opt

      type t = T.Clock_info.t structure ptr

      let t = ptr T.Clock_info.t

      let get (info : t) field = Ctypes.getf !@info field

      let get_type (info : t) : T.Clock_type.t =
        get info T.Clock_info.clock_type

      let get_tick_size (info : t) : float = get info T.Clock_info.tick_size

      let get_modifier (info : t) : T.Clock_modifier.t =
        get info T.Clock_info.modifier

      let get_modifier_value (info : t) : float =
        get info T.Clock_info.modifier_value

      let get_dt (info : t) : float = get info T.Clock_info.dt

      let get_time (info : t) : float = get info T.Clock_info.time

      let get_clock = c "orxClock_GetFromInfo" (t @-> returning clock_opt)
    end

    (* Pointer/physical equality-based comparison *)
    let compare (a : t) (b : t) : int = Ctypes.ptr_compare a b

    let equal a b = compare a b = 0

    (* Create a new clock *)
    let create_from_config =
      c "orxClock_CreateFromConfig" (string @-> returning t_opt)

    let create =
      c "orxClock_Create" (float @-> T.Clock_type.t @-> returning t_opt)

    (* Get a clock in various ways *)
    let get = c "orxClock_Get" (string @-> returning t_opt)

    let find_first =
      c "orxClock_FindFirst" (float @-> T.Clock_type.t @-> returning t_opt)

    (* Get clock properties *)
    let get_name = c "orxClock_GetName" (t @-> returning string)

    let get_info = c "orxClock_GetInfo" (t @-> returning Info.t)

    (* Change a clock *)
    let set_modifier =
      c "orxClock_SetModifier"
        (t @-> T.Clock_modifier.t @-> float @-> returning Status.as_exn)

    let set_tick_size =
      c "orxClock_SetTickSize" (t @-> float @-> returning Status.as_exn)

    (* Adjust clock's progress *)
    let restart = c "orxClock_Restart" (t @-> returning Status.t)

    let pause = c "orxClock_Pause" (t @-> returning Status.as_exn)

    let unpause = c "orxClock_Unpause" (t @-> returning Status.as_exn)

    let is_paused = c "orxClock_IsPaused" (t @-> returning bool)
  end

  module Resource = struct
    type group = Config

    let pp : group Fmt.t =
     fun ppf (g : group) ->
      match g with
      | Config -> Fmt.pf ppf "Config"

    let group_of_string s : group =
      match String.lowercase_ascii s with
      | "config" -> Config
      | _ -> Fmt.invalid_arg "Unsupported ORX resource %s" s

    let string_of_group (Config : group) : string = "Config"

    let group =
      view ~format:pp ~read:group_of_string ~write:string_of_group string

    let add_storage =
      c "orxResource_AddStorage"
        (group @-> string @-> bool @-> returning Status.t)
  end

  module Camera = struct
    type t = T.Camera.t structure ptr

    let t : t typ = ptr T.Camera.t

    let t_opt : t option typ = ptr_opt T.Camera.t

    let to_void_pointer (c : t) = to_voidp c

    let of_void_pointer = c "orxCAMERA" (ptr void @-> returning t_opt)

    (* Creating cameras *)
    let create_from_config =
      c "orxCamera_CreateFromConfig" (string @-> returning t_opt)

    (* Get camera by name *)
    let get = c "orxCamera_Get" (string @-> returning t_opt)

    (* Get/set misc camera properties *)
    let get_name = c "orxCamera_GetName" (t @-> returning string)

    let get_parent = c "orxCamera_GetParent" (t @-> returning Structure.t_opt)

    let set_parent =
      c "orxCamera_SetParent" (t @-> ptr_opt void @-> returning Status.as_exn)

    (* Camera positioning *)
    let get_position =
      c "orxCamera_GetPosition" (t @-> Vector.t @-> returning Vector.t)

    let set_position =
      c "orxCamera_SetPosition" (t @-> Vector.t @-> returning Status.as_exn)

    (* Camera rotation *)
    let get_rotation = c "orxCamera_GetRotation" (t @-> returning float)

    let set_rotation =
      c "orxCamera_SetRotation" (t @-> float @-> returning Status.as_exn)

    (* Camera zoom *)
    let get_zoom = c "orxCamera_GetZoom" (t @-> returning float)

    let set_zoom =
      c "orxCamera_SetZoom" (t @-> float @-> returning Status.as_exn)

    (* Camera frustum *)
    let set_frustum =
      c "orxCamera_SetFrustum"
        (t @-> float @-> float @-> float @-> float @-> returning Status.as_exn)
  end

  module Object = struct
    type t = T.Object.t structure ptr

    let t : t typ = ptr T.Object.t

    let t_opt : t option typ = ptr_opt T.Object.t

    (* Pointer/physical equality-based comparison *)
    let compare (a : t) (b : t) : int = Ctypes.ptr_compare a b

    let equal a b = compare a b = 0

    let of_void_pointer = c "orxOBJECT" (ptr void @-> returning t_opt)

    let to_void_pointer (o : t) = to_voidp o

    (* Object creation and presence *)
    let create_from_config =
      c "orxObject_CreateFromConfig" (string @-> returning t_opt)

    let enable = c "orxObject_Enable" (t @-> bool @-> returning void)

    let enable_recursive =
      c "orxObject_EnableRecursive" (t @-> bool @-> returning void)

    let is_enabled = c "orxObject_IsEnabled" (t @-> returning bool)

    let pause = c "orxObject_Pause" (t @-> bool @-> returning void)

    let is_paused = c "orxObject_IsPaused" (t @-> returning bool)

    (* Basic attributes *)
    let get_name = c "orxObject_GetName" (t @-> returning string)

    let set_parent =
      c "orxObject_SetParent" (t @-> ptr_opt void @-> returning Status.t)

    let get_parent = c "orxObject_GetParent" (t @-> returning Structure.t_opt)

    let set_owner =
      c "orxObject_SetOwner" (t @-> ptr_opt void @-> returning void)

    let get_owner = c "orxObject_GetOwner" (t @-> returning Structure.t_opt)

    let get_owned_child = c "orxObject_GetOwnedChild" (t @-> returning t_opt)

    let get_owned_sibling = c "orxObject_GetOwnedSibling" (t @-> returning t_opt)

    (* Parent/child relationships *)
    let get_child = c "orxObject_GetChild" (t @-> returning t_opt)

    let get_sibling = c "orxObject_GetSibling" (t @-> returning t_opt)

    let get_next_child =
      c "orxObject_GetNextChild"
        (t @-> ptr_opt void @-> T.Structure_id.t @-> returning Structure.t_opt)

    let log_parents = c "orxObject_LogParents" (t @-> returning Status.t)

    (* Bounding box *)
    let get_bounding_box =
      c "orxObject_GetBoundingBox" (t @-> Obox.t @-> returning Obox.t_opt)

    (* FX *)
    let add_fx = c "orxObject_AddFX" (t @-> string @-> returning Status.t)

    let add_unique_fx =
      c "orxObject_AddUniqueFX" (t @-> string @-> returning Status.t)

    let add_delayed_fx =
      c "orxObject_AddDelayedFX" (t @-> string @-> float @-> returning Status.t)

    let add_unique_delayed_fx =
      c "orxObject_AddUniqueDelayedFX"
        (t @-> string @-> float @-> returning Status.t)

    let add_fx_recursive =
      c "orxObject_AddFXRecursive" (t @-> string @-> returning void)

    let add_unique_fx_recursive =
      c "orxObject_AddUniqueFXRecursive" (t @-> string @-> returning void)

    let add_delayed_fx_recursive =
      c "orxObject_AddDelayedFXRecursive"
        (t @-> string @-> float @-> bool @-> returning void)

    let add_unique_delayed_fx_recursive =
      c "orxObject_AddUniqueDelayedFXRecursive"
        (t @-> string @-> float @-> bool @-> returning void)

    let remove_fx = c "orxObject_RemoveFX" (t @-> string @-> returning Status.t)

    (* Position and orientation *)
    let get_rotation = c "orxObject_GetRotation" (t @-> returning float)

    let set_rotation =
      c "orxObject_SetRotation" (t @-> float @-> returning Status.as_exn)

    let get_world_position =
      c "orxObject_GetWorldPosition" (t @-> Vector.t @-> returning Vector.t_opt)

    let set_world_position =
      c "orxObject_SetWorldPosition" (t @-> Vector.t @-> returning Status.as_exn)

    let get_position =
      c "orxObject_GetPosition" (t @-> Vector.t @-> returning Vector.t_opt)

    let set_position =
      c "orxObject_SetPosition" (t @-> Vector.t @-> returning Status.as_exn)

    let get_scale =
      c "orxObject_GetScale" (t @-> Vector.t @-> returning Vector.t_opt)

    let set_scale =
      c "orxObject_SetScale" (t @-> Vector.t @-> returning Status.as_exn)

    (* Text *)
    let set_text_string =
      c "orxObject_SetTextString" (t @-> string @-> returning Status.as_exn)

    let get_text_string = c "orxObject_GetTextString" (t @-> returning string)

    (* Life time *)
    let set_life_time =
      c "orxObject_SetLifeTime" (t @-> float @-> returning Status.as_exn)

    let get_life_time = c "orxObject_GetLifeTime" (t @-> returning float)

    let get_active_time = c "orxObject_GetActiveTime" (t @-> returning float)

    (* Time line *)
    let add_time_line_track =
      c "orxObject_AddTimeLineTrack" (t @-> string @-> returning Status.t)

    let add_time_line_track_recursive =
      c "orxObject_AddTimeLineTrackRecursive" (t @-> string @-> returning void)

    let remove_time_line_track =
      c "orxObject_RemoveTimeLineTrack" (t @-> string @-> returning Status.t)

    let enable_time_line =
      c "orxObject_EnableTimeLine" (t @-> bool @-> returning void)

    let is_time_line_enabled =
      c "orxObject_IsTimeLineEnabled" (t @-> returning bool)

    (* Physics *)
    let apply_force =
      c "orxObject_ApplyForce"
        (t @-> Vector.t @-> Vector.t_opt @-> returning Status.body_exn)

    let apply_impulse =
      c "orxObject_ApplyImpulse"
        (t @-> Vector.t @-> Vector.t_opt @-> returning Status.body_exn)

    let apply_torque =
      c "orxObject_ApplyTorque" (t @-> float @-> returning Status.body_exn)

    let set_speed =
      c "orxObject_SetSpeed" (t @-> Vector.t @-> returning Status.as_exn)

    let get_speed =
      c "orxObject_GetSpeed" (t @-> Vector.t @-> returning Vector.t_opt)

    let set_relative_speed =
      c "orxObject_SetRelativeSpeed" (t @-> Vector.t @-> returning Status.as_exn)

    let get_relative_speed =
      c "orxObject_GetRelativeSpeed" (t @-> Vector.t @-> returning Vector.t_opt)

    let set_angular_velocity =
      c "orxObject_SetAngularVelocity"
        (t @-> float @-> returning Status.body_exn)

    let get_angular_velocity =
      c "orxObject_GetAngularVelocity" (t @-> returning float)

    let set_custom_gravity =
      c "orxObject_SetCustomGravity"
        (t @-> Vector.t_opt @-> returning Status.body_exn)

    let get_custom_gravity =
      c "orxObject_GetCustomGravity" (t @-> Vector.t @-> returning Vector.t_opt)

    let get_mass = c "orxObject_GetMass" (t @-> returning float)

    let get_mass_center =
      c "orxObject_GetMassCenter" (t @-> Vector.t @-> returning Vector.t_opt)

    let raycast =
      c "orxObject_Raycast"
        (Vector.t
        @-> Vector.t
        @-> uint16_t
        @-> uint16_t
        @-> bool
        @-> Vector.t_opt
        @-> Vector.t_opt
        @-> returning t_opt
        )

    (* Color *)
    let set_rgb =
      c "orxObject_SetRGB" (t @-> Vector.t @-> returning Status.graphic_exn)

    let set_rgb_recursive =
      c "orxObject_SetRGBRecursive" (t @-> Vector.t @-> returning void)

    let set_alpha =
      c "orxObject_SetAlpha" (t @-> float @-> returning Status.graphic_exn)

    let set_alpha_recursive =
      c "orxObject_SetAlphaRecursive" (t @-> float @-> returning void)

    (* Animation *)
    let set_target_anim =
      c "orxObject_SetTargetAnim" (t @-> string @-> returning Status.t)

    (* Sound *)
    let add_sound = c "orxObject_AddSound" (t @-> string @-> returning Status.t)

    let remove_sound =
      c "orxObject_RemoveSound" (t @-> string @-> returning Status.t)

    let get_last_added_sound =
      c "orxObject_GetLastAddedSound" (t @-> returning Sound.t_opt)

    let set_volume =
      c "orxObject_SetVolume" (t @-> float @-> returning Status.sound_exn)

    let set_pitch =
      c "orxObject_SetPitch" (t @-> float @-> returning Status.sound_exn)

    let play = c "orxObject_Play" (t @-> returning Status.sound_exn)

    let stop = c "orxObject_Stop" (t @-> returning Status.sound_exn)

    (* Linking structures *)
    let link_structure =
      c "orxObject_LinkStructure" (t @-> Structure.t @-> returning Status.as_exn)

    let get_structure =
      c "_orxObject_GetStructure"
        (t @-> T.Structure_id.t @-> returning Structure.t_opt)

    (* Object selection *)
    (* Neighbor = Object(s) within a bounding box *)
    let create_neighbor_list =
      c "orxObject_CreateNeighborList"
        (Obox.t @-> String_id.t @-> returning Bank.t_opt)

    let delete_neighbor_list =
      c "orxObject_DeleteNeighborList" (Bank.t @-> returning void)

    let pick = c "orxObject_Pick" (Vector.t @-> String_id.t @-> returning t_opt)

    let box_pick =
      c "orxObject_BoxPick" (Obox.t @-> String_id.t @-> returning t_opt)

    (* Group ID and object selection *)
    let get_default_group_id =
      c "orxObject_GetDefaultGroupID" (void @-> returning String_id.t)

    let get_group_id = c "orxObject_GetGroupID" (t @-> returning String_id.t)

    let set_group_id =
      c "orxObject_SetGroupID" (t @-> String_id.t @-> returning Status.t)

    let set_group_id_recursive =
      c "orxObject_SetGroupIDRecursive" (t @-> String_id.t @-> returning void)

    let get_next =
      c "orxObject_GetNext" (t_opt @-> String_id.t @-> returning t_opt)
  end

  module Viewport = struct
    type t = T.Viewport.t structure ptr

    let t = ptr T.Viewport.t

    let t_opt = ptr_opt T.Viewport.t

    let create_from_config =
      c "orxViewport_CreateFromConfig" (string @-> returning t_opt)

    let get_camera = c "orxViewport_GetCamera" (t @-> returning Camera.t_opt)
  end

  module Render = struct
    let get_world_position =
      c "orxRender_GetWorldPosition"
        (Vector.t @-> Viewport.t @-> Vector.t @-> returning Vector.t_opt)

    let get_screen_position =
      c "orxRender_GetScreenPosition"
        (Vector.t @-> Viewport.t @-> Vector.t @-> returning Vector.t_opt)
  end

  module Input = struct
    let is_active = c "orxInput_IsActive" (string @-> returning bool)

    let has_new_status = c "orxInput_HasNewStatus" (string @-> returning bool)

    let has_been_activated =
      c "orxInput_HasBeenActivated" (string @-> returning bool)

    let get_binding =
      c "orxInput_GetBinding"
        (string
        @-> int
        @-> ptr T.Input_type.t
        @-> ptr int
        @-> ptr T.Input_mode.t
        @-> returning Status.t
        )

    let get_binding_name =
      c "orxInput_GetBindingName"
        (T.Input_type.t @-> int @-> T.Input_mode.t @-> returning string)
  end

  module Fx_event = struct
    include T.Fx_event
    type payload = Payload.t Ctypes.structure Ctypes.ptr

    let get_name (payload : payload) : string =
      Ctypes.getf !@payload Payload.name
  end

  module Input_event = struct
    include T.Input_event
    type payload = Payload.t Ctypes.structure Ctypes.ptr

    let get_set_name (payload : payload) : string =
      Ctypes.getf !@payload T.Input_event.Payload.set_name

    let get_input_name (payload : payload) : string =
      Ctypes.getf !@payload T.Input_event.Payload.input_name
  end

  module Object_event = struct
    include T.Object_event
    type payload = Payload.t Ctypes.structure Ctypes.ptr
  end

  module Physics_event = struct
    include T.Physics_event
    type payload = Payload.t Ctypes.structure Ctypes.ptr

    let get_position (payload : payload) : Vector.t =
      !@payload @. T.Physics_event.Payload.position

    let get_normal (payload : payload) : Vector.t =
      !@payload @. T.Physics_event.Payload.normal

    let get_sender_part_name (payload : payload) : string =
      Ctypes.getf !@payload T.Physics_event.Payload.sender_part_name

    let get_recipient_part_name (payload : payload) : string =
      Ctypes.getf !@payload T.Physics_event.Payload.recipient_part_name
  end

  module Sound_event = struct
    include T.Sound_event
    type payload = Payload.t Ctypes.structure Ctypes.ptr

    let get_sound (payload : payload) : Sound.t =
      Ctypes.getf !@payload T.Sound_event.Payload.sound
  end

  module Event = struct
    type t = T.Event.t structure ptr

    let t = ptr T.Event.t

    module Event_type = struct
      type ('event, 'payload) t =
        | Fx : (Fx_event.t, Fx_event.payload) t
        | Input : (Input_event.t, Input_event.payload) t
        | Object : (Object_event.t, Object_event.payload) t
        | Physics : (Physics_event.t, Physics_event.payload) t
        | Sound : (Sound_event.t, Sound_event.payload) t

      type any = Any : (_, _) t -> any

      let of_c_type :
          type e p.
          (e, p) T.Event_type.t -> (e, p Ctypes.structure Ctypes.ptr) t =
        function
        | Fx -> Fx
        | Input -> Input
        | Object -> Object
        | Physics -> Physics
        | Sound -> Sound

      let to_c_any : type e p. (e, p) t -> T.Event_type.any = function
        | Fx -> Any Fx
        | Input -> Any Input
        | Object -> Any Object
        | Physics -> Any Physics
        | Sound -> Any Sound

      let of_c_any (c : T.Event_type.any) : any =
        match c with
        | Any ct -> Any (of_c_type ct)
    end

    let get_flag = c "orxEVENT_GET_FLAG" (uint32_t @-> returning uint32_t)

    let to_event_id (event : t) : int64 =
      Ctypes.getf !@event T.Event.event_id |> Unsigned.UInt.to_int64

    let to_type (event : t) : Event_type.any =
      Ctypes.getf !@event T.Event.event_type |> Event_type.of_c_any

    let assert_type (event : t) (typ_ : Event_type.any) : unit =
      match to_type event = typ_ with
      | true -> ()
      | false -> Fmt.invalid_arg "Unexpected or invalid event type"

    let unsafe_get_payload (event : t) payload_type =
      let payload_field = Ctypes.getf !@event T.Event.payload in
      Ctypes.from_voidp payload_type payload_field

    let to_payload
        (type event payload)
        (event : t)
        (payload_type : (event, payload) Event_type.t) : payload =
      (* Some dynamic type checking... *)
      match payload_type with
      | Fx ->
        assert_type event (Any Fx);
        unsafe_get_payload event T.Fx_event.Payload.t
      | Input ->
        assert_type event (Any Input);
        unsafe_get_payload event T.Input_event.Payload.t
      | Object ->
        assert_type event (Any Object);
        unsafe_get_payload event T.Object_event.Payload.t
      | Physics ->
        assert_type event (Any Physics);
        unsafe_get_payload event T.Physics_event.Payload.t
      | Sound ->
        assert_type event (Any Sound);
        unsafe_get_payload event T.Sound_event.Payload.t

    let get_event_by_id (event : t) map_from_constant =
      let event_id = to_event_id event in
      match List.assoc_opt event_id map_from_constant with
      | None -> Fmt.invalid_arg "Unhandled event id: %Ld" event_id
      | Some event -> event

    let to_event
        (type event payload)
        (event : t)
        (event_type : (event, payload) Event_type.t) : event =
      match event_type with
      | Fx ->
        assert_type event (Any Fx);
        get_event_by_id event T.Fx_event.map_from_constant
      | Input ->
        assert_type event (Any Input);
        get_event_by_id event T.Input_event.map_from_constant
      | Object ->
        assert_type event (Any Object);
        get_event_by_id event T.Object_event.map_from_constant
      | Physics ->
        assert_type event (Any Physics);
        get_event_by_id event T.Physics_event.map_from_constant
      | Sound ->
        assert_type event (Any Sound);
        get_event_by_id event T.Sound_event.map_from_constant
  end

  module Physics = struct
    let get_gravity =
      c "orxPhysics_GetGravity" (Vector.t @-> returning Vector.t_opt)

    let set_gravity =
      c "orxPhysics_SetGravity" (Vector.t @-> returning Status.as_exn)
  end

  module Display = struct
    module Rgba = struct
      let make (rgba : int32) : T.Rgba.t structure =
        let rgba' = make T.Rgba.t in
        setf rgba' T.Rgba.rgba (Unsigned.UInt32.of_int32 rgba);
        rgba'
    end

    module Draw = struct
      let circle =
        c "orxDisplay_DrawCircle"
          (Vector.t @-> float @-> T.Rgba.t @-> bool @-> returning Status.t)

      let line =
        c "orxDisplay_DrawLine"
          (Vector.t @-> Vector.t @-> T.Rgba.t @-> returning Status.t)
    end
  end

  module Screenshot = struct
    let capture = c "orxScreenshot_Capture" (void @-> returning Status.t)
  end

  module Locale = struct
    let select_language =
      c "orxLocale_SelectLanguage" (string @-> returning Status.t)

    let get_current_language =
      c "orxLocale_GetCurrentLanguage" (void @-> returning string)

    let has_language = c "orxLocale_HasLanguage" (string @-> returning bool)

    let get_language_count =
      c "orxLocale_GetLanguageCount" (void @-> returning uint32_t)

    let get_language = c "orxLocale_GetLanguage" (uint32_t @-> returning string)

    let has_string = c "orxLocale_HasString" (string @-> returning bool)

    let get_string = c "orxLocale_GetString" (string @-> returning string)

    let set_string =
      c "orxLocale_SetString" (string @-> string @-> returning Status.t)

    let get_key_count = c "orxLocale_GetKeyCount" (void @-> returning uint32_t)

    let get_key = c "orxLocale_GetKey" (uint32_t @-> returning string)
  end
end
