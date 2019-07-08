let swap_tuple_list = l => List.map(((a, b)) => (b, a), l);

module Bindings = (F: Ctypes.TYPE) => {
  type structure('a) = F.typ(Ctypes.structure('a));

  module Status = {
    let success = F.constant("orxSTATUS_SUCCESS", F.int);
    let failure = F.constant("orxSTATUS_FAILURE", F.int);
  };

  module Rgba = {
    type t;

    let t: structure(t) = F.structure("__orxRGBA_t");
    let rgba = F.field(t, "u32RGBA", F.uint32_t);
    let () = F.seal(t);
  };

  module Vector = {
    type t;

    let t: structure(t) = F.structure("__orxVECTOR_t");
    let x = F.field(t, "fX", F.float);
    let y = F.field(t, "fY", F.float);
    let z = F.field(t, "fZ", F.float);
    let () = F.seal(t);
  };

  module Handle = {
    let t = F.ptr(F.void);
  };

  module Module_id = {
    type t =
      | Clock
      | Main;

    let clock = F.constant("orxMODULE_ID_CLOCK", F.int64_t);
    let main = F.constant("orxMODULE_ID_MAIN", F.int64_t);

    let map_to_constant = [(Clock, clock), (Main, main)];

    let t =
      F.enum("__orxMODULE_ID_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported module id enum: %Ld", i)
      );
  };

  module Clock_modifier = {
    type t =
      | Fixed
      | Multiply
      | Maxed;

    let fixed = F.constant("orxCLOCK_MOD_TYPE_FIXED", F.int64_t);
    let multiply = F.constant("orxCLOCK_MOD_TYPE_MULTIPLY", F.int64_t);
    let maxed = F.constant("orxCLOCK_MOD_TYPE_MAXED", F.int64_t);

    let map_to_constant = [
      (Fixed, fixed),
      (Multiply, multiply),
      (Maxed, maxed),
    ];

    let t =
      F.enum("__orxCLOCK_MOD_TYPE_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported clock mod type enum: %Ld", i)
      );
  };

  module Clock_type = {
    type t =
      | Core
      | User
      | Second;

    let core = F.constant("orxCLOCK_TYPE_CORE", F.int64_t);
    let user = F.constant("orxCLOCK_TYPE_USER", F.int64_t);
    let second = F.constant("orxCLOCK_TYPE_SECOND", F.int64_t);

    let map_to_constant = [(Core, core), (User, user), (Second, second)];

    let t =
      F.enum("__orxCLOCK_TYPE_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported clock mod type enum: %Ld", i)
      );
  };

  module Clock_info = {
    type t;

    let t: structure(t) = F.structure("__orxCLOCK_INFO_t");
    let clock_type = F.field(t, "eType", Clock_type.t);
    let tick_size = F.field(t, "fTickSize", F.float);
    let modifier = F.field(t, "eModType", Clock_modifier.t);
    let modifier_value = F.field(t, "fModValue", F.float);
    let dt = F.field(t, "fDT", F.float);
    let time = F.field(t, "fTime", F.float);
    let () = F.seal(t);
  };

  module Clock_priority = {
    type t =
      | Lowest
      | Lower
      | Low
      | Normal
      | High
      | Higher
      | Highest;

    let lowest = F.constant("orxCLOCK_PRIORITY_LOWEST", F.int64_t);
    let lower = F.constant("orxCLOCK_PRIORITY_LOWER", F.int64_t);
    let low = F.constant("orxCLOCK_PRIORITY_LOW", F.int64_t);
    let normal = F.constant("orxCLOCK_PRIORITY_NORMAL", F.int64_t);
    let high = F.constant("orxCLOCK_PRIORITY_HIGH", F.int64_t);
    let higher = F.constant("orxCLOCK_PRIORITY_HIGHER", F.int64_t);
    let highest = F.constant("orxCLOCK_PRIORITY_HIGHEST", F.int64_t);

    let map_to_constant = [
      (Lowest, lowest),
      (Lower, lower),
      (Low, low),
      (Normal, normal),
      (High, high),
      (Higher, higher),
      (Highest, highest),
    ];

    let t =
      F.enum("__orxCLOCK_PRIORITY_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported clock priority enum: %Ld", i)
      );
  };

  module Clock = {
    type t;

    // Unsealed structure because the type is anonymous
    let t: structure(t) = F.structure("__orxCLOCK_t");
  };

  module Fx = {
    type t;

    // Unsealed structure because the type is anonymous
    let t: structure(t) = F.structure("__orxFX_t");
  };

  module Input_type = {
    type t =
      | Keyboard_key
      | Mouse_button
      | Mouse_axis
      | Joystick_button
      | Joystick_axis
      | External
      | None;

    let keyboard_key = F.constant("orxINPUT_TYPE_KEYBOARD_KEY", F.int64_t);
    let mouse_button = F.constant("orxINPUT_TYPE_MOUSE_BUTTON", F.int64_t);
    let mouse_axis = F.constant("orxINPUT_TYPE_MOUSE_AXIS", F.int64_t);
    let joystick_button =
      F.constant("orxINPUT_TYPE_JOYSTICK_BUTTON", F.int64_t);
    let joystick_axis = F.constant("orxINPUT_TYPE_JOYSTICK_AXIS", F.int64_t);
    let external_ = F.constant("orxINPUT_TYPE_EXTERNAL", F.int64_t);
    let none = F.constant("orxINPUT_TYPE_NONE", F.int64_t);

    let map_to_constant = [
      (Keyboard_key, keyboard_key),
      (Mouse_button, mouse_button),
      (Mouse_axis, mouse_axis),
      (Joystick_button, joystick_button),
      (Joystick_axis, joystick_axis),
      (External, external_),
      (None, none),
    ];

    let t =
      F.enum("__orxINPUT_TYPE_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported input type enum: %Ld", i)
      );
  };

  module Input_mode = {
    type t =
      | Full
      | Positive
      | Negative;

    let full = F.constant("orxINPUT_MODE_FULL", F.int64_t);
    let positive = F.constant("orxINPUT_MODE_POSITIVE", F.int64_t);
    let negative = F.constant("orxINPUT_MODE_NEGATIVE", F.int64_t);

    let map_to_constant = [
      (Full, full),
      (Positive, positive),
      (Negative, negative),
    ];

    let t =
      F.enum("__orxINPUT_MODE_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported input mode enum: %Ld", i)
      );
  };

  module Event_type = {
    type t =
      | Anim
      | Clock
      | Config
      | Display
      | Fx
      | Input
      | Locale
      | Object
      | Render
      | Physics
      | Resource
      | Shader
      | Sound
      | Spawner
      | System
      | Texture
      | Timeline
      | Viewport;

    let anim = F.constant("orxEVENT_TYPE_ANIM", F.int64_t);
    let clock = F.constant("orxEVENT_TYPE_CLOCK", F.int64_t);
    let config = F.constant("orxEVENT_TYPE_CONFIG", F.int64_t);
    let display = F.constant("orxEVENT_TYPE_DISPLAY", F.int64_t);
    let fx = F.constant("orxEVENT_TYPE_FX", F.int64_t);
    let input = F.constant("orxEVENT_TYPE_INPUT", F.int64_t);
    let locale = F.constant("orxEVENT_TYPE_LOCALE", F.int64_t);
    let object_ = F.constant("orxEVENT_TYPE_OBJECT", F.int64_t);
    let render = F.constant("orxEVENT_TYPE_RENDER", F.int64_t);
    let physics = F.constant("orxEVENT_TYPE_PHYSICS", F.int64_t);
    let resource = F.constant("orxEVENT_TYPE_RESOURCE", F.int64_t);
    let shader = F.constant("orxEVENT_TYPE_SHADER", F.int64_t);
    let sound = F.constant("orxEVENT_TYPE_SOUND", F.int64_t);
    let spawner = F.constant("orxEVENT_TYPE_SPAWNER", F.int64_t);
    let system = F.constant("orxEVENT_TYPE_SYSTEM", F.int64_t);
    let texture = F.constant("orxEVENT_TYPE_TEXTURE", F.int64_t);
    let timeline = F.constant("orxEVENT_TYPE_TIMELINE", F.int64_t);
    let viewport = F.constant("orxEVENT_TYPE_VIEWPORT", F.int64_t);

    let map_to_constant = [
      (Anim, anim),
      (Clock, clock),
      (Config, config),
      (Display, display),
      (Fx, fx),
      (Input, input),
      (Locale, locale),
      (Object, object_),
      (Render, render),
      (Physics, physics),
      (Resource, resource),
      (Shader, shader),
      (Sound, sound),
      (Spawner, spawner),
      (System, system),
      (Texture, texture),
      (Timeline, timeline),
      (Viewport, viewport),
    ];

    let map_from_constant = swap_tuple_list(map_to_constant);

    let t =
      F.enum("__orxEVENT_TYPE_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported event type enum: %Ld", i)
      );
  };

  module Fx_event = {
    type t =
      | Start
      | Stop
      | Add
      | Remove
      | Loop;

    let start = F.constant("orxFX_EVENT_START", F.int64_t);
    let stop = F.constant("orxFX_EVENT_STOP", F.int64_t);
    let add = F.constant("orxFX_EVENT_ADD", F.int64_t);
    let remove = F.constant("orxFX_EVENT_REMOVE", F.int64_t);
    let loop = F.constant("orxFX_EVENT_LOOP", F.int64_t);

    let map_to_constant = [
      (Start, start),
      (Stop, stop),
      (Add, add),
      (Remove, remove),
      (Loop, loop),
    ];

    let map_from_constant = swap_tuple_list(map_to_constant);

    let t =
      F.enum("__orxFX_EVENT_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported fx event type enum: %Ld", i)
      );

    module Payload = {
      type t;

      let t: structure(t) = F.structure("__orxFX_EVENT_PAYLOAD_t");
      let fx = F.field(t, "pstFX", F.ptr(Fx.t));
      let name = F.field(t, "zFXName", F.string);
      let () = F.seal(t);
    };
  };

  module Input_event = {
    type t =
      | On
      | Off
      | Select_set;

    let on = F.constant("orxINPUT_EVENT_ON", F.int64_t);
    let off = F.constant("orxINPUT_EVENT_OFF", F.int64_t);
    let select_set = F.constant("orxINPUT_EVENT_SELECT_SET", F.int64_t);

    let map_to_constant = [(On, on), (Off, off), (Select_set, select_set)];

    let map_from_constant = swap_tuple_list(map_to_constant);

    let t =
      F.enum("__orxINPUT_EVENT_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported input event type enum: %Ld", i)
      );

    module Payload = {
      type t;

      // Unsealed structure because the type definition isn't fully mapped here
      let t: structure(t) = F.structure("__orxINPUT_EVENT_PAYLOAD_t");
      let set_name = F.field(t, "zSetName", F.string);
      let input_name = F.field(t, "zInputName", F.string);
    };
  };

  module Physics_event = {
    type t =
      | Contact_add
      | Contact_remove;

    let contact_add = F.constant("orxPHYSICS_EVENT_CONTACT_ADD", F.int64_t);
    let contact_remove =
      F.constant("orxPHYSICS_EVENT_CONTACT_REMOVE", F.int64_t);

    let map_to_constant = [
      (Contact_add, contact_add),
      (Contact_remove, contact_remove),
    ];

    let map_from_constant = swap_tuple_list(map_to_constant);

    let t =
      F.enum("__orxPHYSICS_EVENT_t", map_to_constant, ~unexpected=i =>
        Fmt.invalid_arg("unsupported physics event type enum: %Ld", i)
      );

    module Payload = {
      type t;

      let t: structure(t) = F.structure("__orxPHYSICS_EVENT_PAYLOAD_t");
      let position = F.field(t, "vPosition", Vector.t);
      let normal = F.field(t, "vNormal", Vector.t);
      let sender_part_name = F.field(t, "zSenderPartName", F.string);
      let recipient_part_name = F.field(t, "zRecipientPartName", F.string);
      let () = F.seal(t);
    };
  };

  module Event = {
    type t;

    let t: structure(t) = F.structure("__orxEVENT_t");
    let event_type = F.field(t, "eType", Event_type.t);
    let event_id = F.field(t, "eID", F.uint);
    let sender = F.field(t, "hSender", Handle.t);
    let recipient = F.field(t, "hRecipient", Handle.t);
    let payload = F.field(t, "pstPayload", F.ptr(F.void));
    let context = F.field(t, "pContext", F.ptr(F.void));
    let () = F.seal(t);
  };

  module Camera = {
    type t;

    // Unsealed structure because the type is anonymous
    let t: structure(t) = F.structure("__orxCAMERA_t");
  };

  module Object = {
    type t;

    // Unsealed structure because the type is anonymous
    let t: structure(t) = F.structure("__orxOBJECT_t");
  };

  module Viewport = {
    type t;

    // Unsealed structure because the type is anonymous
    let t: structure(t) = F.structure("__orxVIEWPORT_t");
  };

  module Object_bounding_box = {
    type t;

    let t: structure(t) = F.structure("__orxOBOX_t");
    let position = F.field(t, "vPosition", Vector.t);
    let pivot = F.field(t, "vPivot", Vector.t);
    let x = F.field(t, "vX", Vector.t);
    let y = F.field(t, "vY", Vector.t);
    let z = F.field(t, "vZ", Vector.t);
    let () = F.seal(t);
  };
};