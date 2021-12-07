let swap_tuple_list l = List.map (fun (a, b) -> (b, a)) l

module Bindings (F : Ctypes.TYPE) = struct
  type 'a structure = 'a Ctypes.structure F.typ

  (* Type alias for orxENUM *)

  let orx_enum = F.uint

  module Status = struct
    let success = F.constant "orxSTATUS_SUCCESS" F.int
    let failure = F.constant "orxSTATUS_FAILURE" F.int
  end

  module Bank = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxBANK_t"
  end

  module String_id = struct
    type t = Unsigned.UInt64.t

    let undefined = F.constant "orxSTRINGID_UNDEFINED" F.uint64_t
  end

  module Rgba = struct
    type t

    let t : t structure = F.structure "__orxRGBA_t"
    let rgba = F.field t "u32RGBA" F.uint32_t
    let () = F.seal t
  end

  module Vector = struct
    type t

    let t : t structure = F.structure "__orxVECTOR_t"
    let x = F.field t "fX" F.float
    let y = F.field t "fY" F.float
    let z = F.field t "fZ" F.float
    let () = F.seal t
  end

  module Color = struct
    type t

    let t : t structure = F.structure "__orxCOLOR_t"
    let rgb = F.field t "vRGB" Vector.t
    let alpha = F.field t "fAlpha" F.float
    let () = F.seal t
  end

  module Handle = struct
    let t = F.ptr F.void
  end

  module Module_id = struct
    type t =
      | Clock
      | Main

    let clock = F.constant "orxMODULE_ID_CLOCK" F.int64_t
    let main = F.constant "orxMODULE_ID_MAIN" F.int64_t

    let map_to_constant = [ (Clock, clock); (Main, main) ]

    let t =
      F.enum "__orxMODULE_ID_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported module id enum: %Ld" i
      )
  end

  module Clock_modifier = struct
    type t =
      | Fixed
      | Multiply
      | Maxed
      | Average

    let fixed = F.constant "orxCLOCK_MODIFIER_FIXED" F.int64_t
    let multiply = F.constant "orxCLOCK_MODIFIER_MULTIPLY" F.int64_t
    let maxed = F.constant "orxCLOCK_MODIFIER_MAXED" F.int64_t
    let average = F.constant "orxCLOCK_MODIFIER_AVERAGE" F.int64_t

    let map_to_constant =
      [
        (Fixed, fixed); (Multiply, multiply); (Maxed, maxed); (Average, average);
      ]

    let t =
      F.enum "__orxCLOCK_MODIFIER_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported clock modifier type enum: %Ld" i
      )
  end

  module Clock_info = struct
    type t

    let clock_modifier_number = F.constant "orxCLOCK_MODIFIER_NUMBER" F.size_t
    let assumed_clock_modifier_number = 4

    let t : t structure = F.structure "__orxCLOCK_INFO_t"
    let tick_size = F.field t "fTickSize" F.float
    let dt = F.field t "fDT" F.float
    let time = F.field t "fTime" F.float
    let modifier_list =
      F.field t "afModifierList" (F.array assumed_clock_modifier_number F.float)
    let () = F.seal t
  end

  module Clock_priority = struct
    type t =
      | Lowest
      | Lower
      | Low
      | Normal
      | High
      | Higher
      | Highest

    let lowest = F.constant "orxCLOCK_PRIORITY_LOWEST" F.int64_t
    let lower = F.constant "orxCLOCK_PRIORITY_LOWER" F.int64_t
    let low = F.constant "orxCLOCK_PRIORITY_LOW" F.int64_t
    let normal = F.constant "orxCLOCK_PRIORITY_NORMAL" F.int64_t
    let high = F.constant "orxCLOCK_PRIORITY_HIGH" F.int64_t
    let higher = F.constant "orxCLOCK_PRIORITY_HIGHER" F.int64_t
    let highest = F.constant "orxCLOCK_PRIORITY_HIGHEST" F.int64_t

    let map_to_constant =
      [
        (Lowest, lowest);
        (Lower, lower);
        (Low, low);
        (Normal, normal);
        (High, high);
        (Higher, higher);
        (Highest, highest);
      ]

    let t =
      F.enum "__orxCLOCK_PRIORITY_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported clock priority enum: %Ld" i
      )
  end

  module Clock = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxCLOCK_t"
  end

  module Fx = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxFX_t"
  end

  module Graphic = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxGRAPHIC_t"
  end

  module Sound = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxSOUND_t"
  end

  module Sound_status = struct
    type t =
      | Play
      | Pause
      | Stop

    let play = F.constant "orxSOUND_STATUS_PLAY" F.int64_t
    let pause = F.constant "orxSOUND_STATUS_PAUSE" F.int64_t
    let stop = F.constant "orxSOUND_STATUS_STOP" F.int64_t

    let map_to_constant = [ (Play, play); (Pause, pause); (Stop, stop) ]

    let t =
      F.enum "__orxSOUND_STATUS_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported sound status enum: %Ld" i
      )
  end

  module Mouse_button = struct
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

    let make name = F.constant ("orxMOUSE_BUTTON_" ^ name) F.int64_t

    let left = make "LEFT"
    let right = make "RIGHT"
    let middle = make "MIDDLE"
    let extra_1 = make "EXTRA_1"
    let extra_2 = make "EXTRA_2"
    let extra_3 = make "EXTRA_3"
    let extra_4 = make "EXTRA_4"
    let extra_5 = make "EXTRA_5"
    let wheel_up = make "WHEEL_UP"
    let wheel_down = make "WHEEL_DOWN"

    let map_to_constant =
      [
        (Left, left);
        (Right, right);
        (Middle, middle);
        (Extra_1, extra_1);
        (Extra_2, extra_2);
        (Extra_3, extra_3);
        (Extra_4, extra_4);
        (Extra_5, extra_5);
        (Wheel_up, wheel_up);
        (Wheel_down, wheel_down);
      ]

    let t =
      F.enum "__orxMOUSE_BUTTON_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported mouse button enum: %Ld" i
      )
  end

  module Mouse_axis = struct
    type t =
      | X
      | Y

    let make name = F.constant ("orxMOUSE_AXIS_" ^ name) F.int64_t

    let x = make "X"
    let y = make "Y"

    let map_to_constant = [ (X, x); (Y, y) ]

    let t =
      F.enum "__orxMOUSE_AXIS_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported mouse axis enum: %Ld" i
      )
  end

  module Structure = struct
    type t

    (* Unsealed structure until we expose its form in these bindings *)
    let t : t structure = F.structure "__orxSTRUCTURE_t"
  end

  module Structure_id = struct
    type t =
      | Body
      | Camera
      | Graphic
      | Object
      | Sound

    let make name = F.constant ("orxSTRUCTURE_ID_" ^ name) F.int64_t

    let body = make "BODY"
    let camera = make "CAMERA"
    let graphic = make "GRAPHIC"
    let object_ = make "OBJECT"
    let sound = make "SOUND"

    let map_to_constant =
      [
        (Body, body);
        (Camera, camera);
        (Graphic, graphic);
        (Object, object_);
        (Sound, sound);
      ]

    let t =
      F.enum "__orxSTRUCTURE_ID_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "Unsupported structre id: %Ld" i
      )
  end

  module Object = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxOBJECT_t"
  end

  module Input_type = struct
    type t =
      | Keyboard_key
      | Mouse_button
      | Mouse_axis
      | Joystick_button
      | Joystick_axis
      | External

    let keyboard_key = F.constant "orxINPUT_TYPE_KEYBOARD_KEY" F.int64_t
    let mouse_button = F.constant "orxINPUT_TYPE_MOUSE_BUTTON" F.int64_t
    let mouse_axis = F.constant "orxINPUT_TYPE_MOUSE_AXIS" F.int64_t
    let joystick_button = F.constant "orxINPUT_TYPE_JOYSTICK_BUTTON" F.int64_t
    let joystick_axis = F.constant "orxINPUT_TYPE_JOYSTICK_AXIS" F.int64_t
    let external_ = F.constant "orxINPUT_TYPE_EXTERNAL" F.int64_t

    let map_to_constant =
      [
        (Keyboard_key, keyboard_key);
        (Mouse_button, mouse_button);
        (Mouse_axis, mouse_axis);
        (Joystick_button, joystick_button);
        (Joystick_axis, joystick_axis);
        (External, external_);
      ]

    let t =
      F.enum "__orxINPUT_TYPE_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported input type enum: %Ld" i
      )
  end

  module Input_mode = struct
    type t =
      | Full
      | Positive
      | Negative

    let full = F.constant "orxINPUT_MODE_FULL" F.int64_t
    let positive = F.constant "orxINPUT_MODE_POSITIVE" F.int64_t
    let negative = F.constant "orxINPUT_MODE_NEGATIVE" F.int64_t

    let map_to_constant =
      [ (Full, full); (Positive, positive); (Negative, negative) ]

    let t =
      F.enum "__orxINPUT_MODE_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported input mode enum: %Ld" i
      )
  end

  module Shader_param_type = struct
    type t =
      | Float
      | Texture
      | Vector
      | Time

    let make tag = F.constant ("orxSHADER_PARAM_TYPE_" ^ tag) F.int64_t
    let float = make "FLOAT"
    let texture = make "TEXTURE"
    let vector = make "VECTOR"
    let time = make "TIME"

    let map_to_constant =
      [ (Float, float); (Texture, texture); (Vector, vector); (Time, time) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxSHADER_PARAM_TYPE_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported shader param type enum: %Ld" i
      )
  end

  module Shader_pointer = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxSHADERPOINTER_t"
  end

  module Shader = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxSHADER_t"
  end

  module Config_event = struct
    type t =
      | Reload_start
      | Reload_stop

    let make tag = F.constant ("orxCONFIG_EVENT_" ^ tag) F.int64_t
    let reload_start = make "RELOAD_START"
    let reload_stop = make "RELOAD_STOP"

    let map_to_constant =
      [ (Reload_start, reload_start); (Reload_stop, reload_stop) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxCONFIG_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported config event type enum: %Ld" i
      )
  end

  module Time_line = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxTIMELINE_t"
  end

  module Fx_event = struct
    type t =
      | Start
      | Stop
      | Add
      | Remove
      | Loop

    let start = F.constant "orxFX_EVENT_START" F.int64_t
    let stop = F.constant "orxFX_EVENT_STOP" F.int64_t
    let add = F.constant "orxFX_EVENT_ADD" F.int64_t
    let remove = F.constant "orxFX_EVENT_REMOVE" F.int64_t
    let loop = F.constant "orxFX_EVENT_LOOP" F.int64_t

    let map_to_constant =
      [
        (Start, start); (Stop, stop); (Add, add); (Remove, remove); (Loop, loop);
      ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxFX_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported fx event type enum: %Ld" i
      )

    module Payload = struct
      type t

      let t : t structure = F.structure "__orxFX_EVENT_PAYLOAD_t"
      let fx = F.field t "pstFX" (F.ptr Fx.t)
      let name = F.field t "zFXName" F.string
      let () = F.seal t
    end
  end

  module Object_event = struct
    type t =
      | Create
      | Delete
      | Prepare
      | Enable
      | Disable
      | Pause
      | Unpause

    let make name = F.constant ("orxOBJECT_EVENT_" ^ name) F.int64_t
    let create = make "CREATE"
    let delete = make "DELETE"
    let prepare = make "PREPARE"
    let enable = make "ENABLE"
    let disable = make "DISABLE"
    let pause = make "PAUSE"
    let unpause = make "UNPAUSE"

    let map_to_constant =
      [
        (Create, create);
        (Delete, delete);
        (Prepare, prepare);
        (Enable, enable);
        (Disable, disable);
        (Pause, pause);
        (Unpause, unpause);
      ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxOBJECT_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported object event type enum: %Ld" i
      )

    module Payload = Object
  end

  module Input_event = struct
    type t =
      | On
      | Off
      | Select_set

    let on = F.constant "orxINPUT_EVENT_ON" F.int64_t
    let off = F.constant "orxINPUT_EVENT_OFF" F.int64_t
    let select_set = F.constant "orxINPUT_EVENT_SELECT_SET" F.int64_t

    let map_to_constant = [ (On, on); (Off, off); (Select_set, select_set) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxINPUT_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported input event type enum: %Ld" i
      )

    module Payload = struct
      type t

      (* orxINPUT_KU32_BINDING_NUMBER = 8 in orxInput.h *)
      let binding_number = 8

      let t : t structure = F.structure "__orxINPUT_EVENT_PAYLOAD_t"
      let set_name = F.field t "zSetName" F.string
      let input_name = F.field t "zInputName" F.string
      let input_type = F.field t "aeType" (F.array binding_number Input_type.t)
      let id = F.field t "aeID" (F.array binding_number orx_enum)
      let mode = F.field t "aeMode" (F.array binding_number Input_mode.t)
      let value = F.field t "afValue" (F.array binding_number F.float)
      let () = F.seal t
    end
  end

  module Physics_event = struct
    type t =
      | Contact_add
      | Contact_remove

    let contact_add = F.constant "orxPHYSICS_EVENT_CONTACT_ADD" F.int64_t
    let contact_remove = F.constant "orxPHYSICS_EVENT_CONTACT_REMOVE" F.int64_t

    let map_to_constant =
      [ (Contact_add, contact_add); (Contact_remove, contact_remove) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxPHYSICS_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported physics event type enum: %Ld" i
      )

    module Payload = struct
      type t

      let t : t structure = F.structure "__orxPHYSICS_EVENT_PAYLOAD_t"
      let position = F.field t "vPosition" Vector.t
      let normal = F.field t "vNormal" Vector.t
      let sender_part_name = F.field t "zSenderPartName" F.string
      let recipient_part_name = F.field t "zRecipientPartName" F.string
      let () = F.seal t
    end
  end

  module Shader_event = struct
    type t = Set_param

    let set_param = F.constant "orxSHADER_EVENT_SET_PARAM" F.int64_t

    let map_to_constant = [ (Set_param, set_param) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxSHADER_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported shader event type enum: %Ld" i
      )

    module Payload = struct
      type t

      let t : t structure = F.structure "__orxSHADER_EVENT_PAYLOAD_t"
      let shader = F.field t "pstShader" (F.ptr Shader.t)
      let shader_name = F.field t "zShaderName" F.string
      let param_name = F.field t "zParamName" F.string
      let param_type = F.field t "eParamType" Shader_param_type.t
      let param_index = F.field t "s32ParamIndex" F.int32_t

      (* TODO: This is a hack to allow lookup of other fields in the
         structure *)
      let _value_placeholder = F.field t "vValue" Vector.t
      let () = F.seal t
    end
  end

  module Sound_event = struct
    type t =
      | Start
      | Stop
      | Add
      | Remove

    let make tag = F.constant ("orxSOUND_EVENT_" ^ tag) F.int64_t

    (* These events are safe to handle without extra care *)
    let start = make "START"
    let stop = make "STOP"
    let add = make "ADD"
    let remove = make "REMOVE"
    let _recording_start = make "RECORDING_START"
    let _recording_stop = make "RECORDING_STOP"
    let _recording_packet = make "RECORDING_PACKET"

    (* These events require extra care - they're sent from another thread, so
       the callback will be invoked from that thread. It's not safe to call any
       orx functions from inside of the callback for these events. *)
    let _packet = make "PACKET"

    let map_to_constant =
      [ (Start, start); (Stop, stop); (Add, add); (Remove, remove) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxSOUND_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported sound event type enum: %Ld" i
      )

    module Payload = struct
      type t

      let t : t structure = F.structure "__orxSOUND_EVENT_PAYLOAD_t"
      let sound = F.field t "pstSound" (F.ptr Sound.t)
      let () = F.seal t
    end
  end

  module Texture_event = struct
    type t =
      | Create
      | Delete
      | Load

    let create = F.constant "orxTEXTURE_EVENT_CREATE" F.int64_t
    let delete = F.constant "orxTEXTURE_EVENT_DELETE" F.int64_t
    let load = F.constant "orxTEXTURE_EVENT_LOAD" F.int64_t

    let map_to_constant = [ (Create, create); (Delete, delete); (Load, load) ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxTEXTURE_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported texture event type enum: %Ld" i
      )
  end

  module Time_line_event = struct
    type t =
      | Track_start
      | Track_stop
      | Track_add
      | Track_remove
      | Loop
      | Trigger

    let make tag = F.constant ("orxTIMELINE_EVENT_" ^ tag) F.int64_t
    let start = make "TRACK_START"
    let stop = make "TRACK_STOP"
    let add = make "TRACK_ADD"
    let remove = make "TRACK_REMOVE"
    let loop = make "LOOP"
    let trigger = make "TRIGGER"

    let map_to_constant =
      [
        (Track_start, start);
        (Track_stop, stop);
        (Track_add, add);
        (Track_remove, remove);
        (Loop, loop);
        (Trigger, trigger);
      ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxTIMELINE_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported time line event type enum: %Ld" i
      )

    module Payload = struct
      type t

      let t : t structure = F.structure "__orxTIMELINE_EVENT_PAYLOAD_t"
      let time_line = F.field t "pstTimeLine" (F.ptr Time_line.t)
      let track_name = F.field t "zTrackName" F.string
      let event = F.field t "zEvent" F.string
      let time_stamp = F.field t "fTimeStamp" F.float
      let () = F.seal t
    end
  end

  module Anim_event = struct
	type t =
		| Start
		| Stop
		| Cut
		| Loop
		| Update
		| Custom_event

	let make tag = F.constant ("orxANIM_EVENT_" ^ tag) F.int64_t
    let start = make "START"
    let stop = make "STOP"
    let cut = make "CUT"
    let loop = make "LOOP"
    let update = make "UPDATE"
    let custom_event = make "CUSTOM_EVENT"

	let map_to_constant =
      [
        (Start, start);
        (Stop, stop);
        (Cut, cut);
        (Loop, loop);
        (Update, update);
        (Custom_event, custom_event);
      ]

	let map_from_constant = swap_tuple_list map_to_constant

	let t =
      F.enum "__orxANIM_EVENT_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported time line event type enum: %Ld" i
      )

	module Payload = struct
      type t

      let t : t structure = F.structure "__orxANIM_EVENT_PAYLOAD_t"
      let animation = F.field t "pstAnim" (F.ptr Animation.t)
      let name = F.field t "zAnimName" F.string
	  (* TODO: I don't know if we have to do something special to access union members here *)
	  (* TODO: This is a hack to allow lookup of other fields in the
         structure *)
      let _value_placeholder = F.field t "vValue" Vector.t
      let () = F.seal t
    end
  end

  module Event_type = struct
    (* type 'event simple = *)
    (* | Config : Config_event.t simple *)
    (* | Texture : Texture_event.t simple *)
    (* | User_defined : User_defined_event.t simple *)

    type ('event, 'payload) t =
      | Animation : ( Anim_event.t, Anim_event.Payload.t) t
      (* | Clock : ([ `Unbound ], [ `Unbound ]) t *)
      (* | Config : (Config_event.t, unit) t *)
      (* | Display : ([ `Unbound ], [ `Unbound ]) t *)
      | Fx : (Fx_event.t, Fx_event.Payload.t) t
      | Input : (Input_event.t, Input_event.Payload.t) t
      (* | Locale : ([ `Unbound ], [ `Unbound ]) t *)
      | Object : (Object_event.t, Object_event.Payload.t) t
      (* | Render : ([ `Unbound ], [ `Unbound ]) t *)
      | Physics : (Physics_event.t, Physics_event.Payload.t) t
      (* | Resource : ([ `Unbound ], [ `Unbound ]) t *)
      | Shader : (Shader_event.t, Shader_event.Payload.t) t
      | Sound : (Sound_event.t, Sound_event.Payload.t) t
      (* | Spawner : ([ `Unbound ], [ `Unbound ]) t *)
      (* | System : ([ `Unbound ], [ `Unbound ]) t *)
      (* | Texture : (Texture_event.t, unit) t *)
      | Time_line : (Time_line_event.t, Time_line_event.Payload.t) t

    (* | Viewport : ([ `Unbound ], [ `Unbound ]) t *)
    (* | User_defined : ([ `Unbound ], [ `Unbound ]) t *)

    type any = Any : (_, _) t -> any

    let anim = F.constant "orxEVENT_TYPE_ANIM" F.int64_t
    (* let clock = F.constant "orxEVENT_TYPE_CLOCK" F.int64_t *)
    (* let config = F.constant "orxEVENT_TYPE_CONFIG" F.int64_t *)

    (* let display = F.constant "orxEVENT_TYPE_DISPLAY" F.int64_t *)
    let fx = F.constant "orxEVENT_TYPE_FX" F.int64_t
    let input = F.constant "orxEVENT_TYPE_INPUT" F.int64_t

    (* let locale = F.constant "orxEVENT_TYPE_LOCALE" F.int64_t *)
    let object_ = F.constant "orxEVENT_TYPE_OBJECT" F.int64_t

    (* let render = F.constant "orxEVENT_TYPE_RENDER" F.int64_t *)
    let physics = F.constant "orxEVENT_TYPE_PHYSICS" F.int64_t

    (* let resource = F.constant "orxEVENT_TYPE_RESOURCE" F.int64_t *)
    let shader = F.constant "orxEVENT_TYPE_SHADER" F.int64_t
    let sound = F.constant "orxEVENT_TYPE_SOUND" F.int64_t

    (* let spawner = F.constant "orxEVENT_TYPE_SPAWNER" F.int64_t *)
    (* let system = F.constant "orxEVENT_TYPE_SYSTEM" F.int64_t *)
    (* let texture = F.constant "orxEVENT_TYPE_TEXTURE" F.int64_t *)
    let time_line = F.constant "orxEVENT_TYPE_TIMELINE" F.int64_t

    (* let viewport = F.constant "orxEVENT_TYPE_VIEWPORT" F.int64_t *)
    (* let user_defined = F.constant "orxEVENT_TYPE_USER_DEFINED" F.int64_t *)

    let map_to_constant =
      [
        (Any Animation, anim);
        (* (Any Clock, clock); *)
        (* (Any Config, config); *)
        (* (Any Display, display); *)
        (Any Fx, fx);
        (Any Input, input);
        (* (Any Locale, locale); *)
        (Any Object, object_);
        (* (Any Render, render); *)
        (Any Physics, physics);
        (* (Any Resource, resource); *)
        (Any Shader, shader);
        (Any Sound, sound);
        (* (Any Spawner, spawner); *)
        (* (Any System, system); *)
        (* (Any Texture, texture); *)
        (Any Time_line, time_line);
        (* (Any Viewport, viewport); *)
        (* (Any User_defined, user_defined); *)
      ]

    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxEVENT_TYPE_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported event type enum: %Ld" i
      )
  end

  module Event = struct
    type t

    let t : t structure = F.structure "__orxEVENT_t"
    let event_type = F.field t "eType" Event_type.t
    let event_id = F.field t "eID" orx_enum
    let sender = F.field t "hSender" Handle.t
    let recipient = F.field t "hRecipient" Handle.t
    let payload = F.field t "pstPayload" (F.ptr F.void)
    let context = F.field t "pContext" (F.ptr F.void)
    let () = F.seal t
  end

  module Body_part = struct
    type t

    let t : t structure = F.structure "__orxBODY_PART_t"
  end

  module Body = struct
    type t

    let t : t structure = F.structure "__orxBODY_t"
  end

  module Camera = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxCAMERA_t"
  end

  module Obox = struct
    type t

    let t : t structure = F.structure "__orxOBOX_t"
    let field = F.field t
    let position = field "vPosition" Vector.t
    let pivot = field "vPivot" Vector.t
    let x = field "vX" Vector.t
    let y = field "vY" Vector.t
    let z = field "vZ" Vector.t
    let () = F.seal t
  end

  module Texture = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxTEXTURE_t"
  end

  module Viewport = struct
    type t

    (* Unsealed structure because the type is anonymous *)
    let t : t structure = F.structure "__orxVIEWPORT_t"
  end

  module Command_var_type = struct
    type t =
      | String
      | Float
      | Int
      | Bool
      | Vector
      | Guid

    let equal (a : t) (b : t) = a = b

    let make tag = F.constant ("orxCOMMAND_VAR_TYPE_" ^ tag) F.int64_t
    let string = make "STRING"
    let float = make "FLOAT"
    let int = make "S64"
    let bool = make "BOOL"
    let vector = make "VECTOR"
    let guid = make "U64"

    let map_to_constant =
      [
        (String, string);
        (Float, float);
        (Int, int);
        (Bool, bool);
        (Vector, vector);
        (Guid, guid);
      ]
    let map_from_constant = swap_tuple_list map_to_constant

    let t =
      F.enum "__orxCOMMAND_VAR_TYPE_t" map_to_constant ~unexpected:(fun i ->
          Fmt.invalid_arg "unsupported comand variable type enum: %Ld" i
      )
  end

  module Command_var_def = struct
    type t

    let t : t structure = F.structure "__orxCOMMAND_VAR_DEF_t"
    let field name typ = F.field t name typ
    let name = field "zName" F.string
    let type_ = field "eType" Command_var_type.t
    let () = F.seal t
  end

  module Command_var = struct
    type t

    let t : t structure = F.structure "__orxCOMMAND_VAR_t"

    (* TODO: This is a hack to allow lookup of other fields in the structure *)
    let _value = F.field t "vValue" Vector.t
    let _type = F.field t "eType" Command_var_type.t
    let () = F.seal t
  end
end
