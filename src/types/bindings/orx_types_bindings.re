let swap_tuple_list = l => List.map(((a, b)) => (b, a), l);

module Bindings = (F: Ctypes.TYPE) => {
  type structure('a) = F.typ(Ctypes.structure('a));

  module Status = {
    let success = F.constant("orxSTATUS_SUCCESS", F.int);
    let failure = F.constant("orxSTATUS_FAILURE", F.int);
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
};
