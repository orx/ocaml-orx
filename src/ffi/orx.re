let (!@) = Ctypes.(!@);

module Orx_gen = Orx_bindings.Bindings(Generated);

module Color = Orx_gen.Color;
module Display = Orx_gen.Display;
module Fx_event = Orx_gen.Fx_event;
module Input_event = Orx_gen.Input_event;
module Sound_event = Orx_gen.Sound_event;
module Resource = Orx_gen.Resource;
module Sound = Orx_gen.Sound;
module Structure = Orx_gen.Structure;
module Texture = Orx_gen.Texture;
module Viewport = Orx_gen.Viewport;

module Vector = {
  include Orx_gen.Vector;

  let get_x = (v: t): float => {
    Ctypes.getf(!@v, Orx_types.Vector.x);
  };

  let get_y = (v: t): float => {
    Ctypes.getf(!@v, Orx_types.Vector.y);
  };

  let get_z = (v: t): float => {
    Ctypes.getf(!@v, Orx_types.Vector.z);
  };

  let make = (~x, ~y, ~z): t => {
    let v = allocate_raw();
    let _: t = set(v, x, y, z);
    v;
  };

  let set_x = (v: t, x: float): unit => {
    Ctypes.setf(!@v, Orx_types.Vector.x, x);
  };

  let set_y = (v: t, y: float): unit => {
    Ctypes.setf(!@v, Orx_types.Vector.y, y);
  };

  let set_z = (v: t, z: float): unit => {
    Ctypes.setf(!@v, Orx_types.Vector.z, z);
  };

  let copy = (v: t): t => {
    let copied: t = allocate_raw();
    let _: t = copy(copied, v);
    copied;
  };

  let scale = (v: t, factor: float): t => {
    let scaled: t = allocate_raw();
    let _: t = scale(scaled, v, factor);
    scaled;
  };

  let add = (v1: t, v2: t): t => {
    let added: t = allocate_raw();
    let _: t = add(added, v1, v2);
    added;
  };

  let rotate_2d = (v: t, angle: float): t => {
    let rotated: t = allocate_raw();
    let _: t = rotate_2d(rotated, v, angle);
    rotated;
  };
};

// Wrapper for functions which return a vector property.
// Orx uses the return value to indicate if the get was a success or not.
let get_optional_vector = (get, o) => {
  let v = Vector.allocate_raw();
  switch (get(o, v)) {
  | None => None
  | Some(_v) => Some(v)
  };
};

let get_vector = (get, o) => {
  let v = Vector.allocate_raw();
  let _: Vector.t = get(o, v);
  v;
};

module Graphic = {
  include Orx_gen.Graphic;

  let get_size = get_vector(get_size);
  let get_origin = get_vector(get_origin);

  let to_structure = (g: t): Structure.t => {
    let g' = Ctypes.to_voidp(g);
    Structure.of_any(g');
  };
};

module Camera = {
  include Orx_gen.Camera;

  let get_position = get_vector(get_position);
};

module Input = {
  include Orx_gen.Input;

  let get_binding = (name: string, index: int) => {
    let type_ = Ctypes.allocate_n(Orx_types.Input_type.t, ~count=1);
    let id = Ctypes.allocate_n(Ctypes.int, ~count=1);
    let mode = Ctypes.allocate_n(Orx_types.Input_mode.t, ~count=1);
    switch (get_binding(name, index, type_, id, mode)) {
    | Error () as e => e
    | Ok () => Ok((!@type_, !@id, !@mode))
    };
  };
};

module Physics = {
  include Orx_gen.Physics;

  let get_gravity = get_optional_vector(((), v) => get_gravity(v));
};

module Object = {
  include Orx_gen.Object;

  let get_world_position = get_optional_vector(get_world_position);
  let get_scale = get_optional_vector(get_scale);
  let get_speed = get_optional_vector(get_speed);
  let get_relative_speed = get_optional_vector(get_relative_speed);
  let get_custom_gravity = get_optional_vector(get_custom_gravity);
  let get_mass_center = get_optional_vector(get_mass_center);

  let add_fx = (~delay: option(float)=?, o: t, fx: string, ~unique: bool) => {
    switch (delay) {
    | None =>
      if (unique) {
        add_unique_fx(o, fx);
      } else {
        add_fx(o, fx);
      }
    | Some(time) =>
      if (unique) {
        add_unique_delayed_fx(o, fx, time);
      } else {
        add_delayed_fx(o, fx, time);
      }
    };
  };
};

module Event = {
  include Orx_gen.Event;

  type event_flag = Unsigned.UInt32.t;

  let to_flag = (event_id: 'a, map_to_constant: list(('a, int64))) => {
    switch (List.assoc_opt(event_id, map_to_constant)) {
    | None => Fmt.invalid_arg("Unhandled event id when looking up flag")
    | Some(event) => get_flag(Unsigned.UInt32.of_int64(event))
    };
  };
  let to_flags = (event_ids: list('a), map_to_constant: list(('a, int64))) => {
    let flags =
      List.map(event_id => to_flag(event_id, map_to_constant), event_ids);
    List.fold_left(
      (flag, id) => Unsigned.UInt32.logor(flag, id),
      Unsigned.UInt32.zero,
      flags,
    );
  };

  let make_flags =
      (type a, event_type: event(a), event_ids: list(a)): event_flag => {
    switch (event_type) {
    | Fx => to_flags(event_ids, Orx_types.Fx_event.map_to_constant)
    | Input => to_flags(event_ids, Orx_types.Input_event.map_to_constant)
    | Physics => to_flags(event_ids, Orx_types.Physics_event.map_to_constant)
    | Sound => to_flags(event_ids, Orx_types.Sound_event.map_to_constant)
    };
  };

  let get_sender_object = (event: t): Object.t => {
    Object.of_void_pointer(Ctypes.getf(!@event, Orx_types.Event.sender));
  };

  let get_recipient_object = (event: t): Object.t => {
    Object.of_void_pointer(Ctypes.getf(!@event, Orx_types.Event.recipient));
  };

  let event_handler = Ctypes.(t @-> returning(Orx_gen.Status.t));

  let c_add_handler =
    Ctypes.(
      Foreign.foreign(
        ~release_runtime_lock=false,
        "ml_orx_event_add_handler",
        Orx_types.Event_type.t
        @-> Foreign.funptr(~runtime_lock=false, event_handler)
        @-> uint32_t
        @-> uint32_t
        @-> returning(Orx_gen.Status.t),
      )
    );

  // Hold onto callbacks so they're not collected
  let registered_callbacks: ref(list(t => Orx_gen.Status.t)) = ref([]);

  let add_handler = (event_type: Orx_types.Event_type.t, callback) => {
    let callback = event =>
      switch (callback(event)) {
      | result => result
      | exception exn =>
        Fmt.epr(
          "Unhandled exception in event callback: %a@.",
          Fmt.exn_backtrace,
          (exn, Printexc.get_raw_backtrace()),
        );
        raise(exn);
      };
    registered_callbacks := [callback, ...registered_callbacks^];
    let add_flags =
      switch (event_type) {
      | Sound => make_flags(Sound, [Start, Stop, Add, Remove])
      | _ => Unsigned.UInt32.max_int
      };
    let remove_flags = Unsigned.UInt32.max_int;
    c_add_handler(event_type, callback, add_flags, remove_flags);
  };
};

module Clock = {
  include Orx_gen.Clock;

  let callback = Ctypes.(Info.t @-> ptr(void) @-> returning(void));

  let c_register =
    Ctypes.(
      Foreign.foreign(
        ~release_runtime_lock=false,
        "orxClock_Register",
        t
        @-> Foreign.funptr(~runtime_lock=false, callback)
        @-> ptr(void)
        @-> Orx_types.Module_id.t
        @-> Orx_types.Clock_priority.t
        @-> returning(Orx_gen.Status.t),
      )
    );

  // Hold onto callbacks so they're not collected
  let registered_callbacks: ref(list((Info.t, Ctypes.ptr(unit)) => unit)) =
    ref([]);

  let register = (clock: t, callback, module_, priority) => {
    let callback_wrapper = (info, _ctx) =>
      switch (callback(info)) {
      | () => ()
      | exception exn =>
        Fmt.epr(
          "Unhandled exception in clock callback: %a@.",
          Fmt.exn_backtrace,
          (exn, Printexc.get_raw_backtrace()),
        );
        raise(exn);
      };
    registered_callbacks := [callback_wrapper, ...registered_callbacks^];
    c_register(clock, callback_wrapper, Ctypes.null, module_, priority);
  };
};

module Config = {
  include Orx_gen.Config;

  let bootstrap_function = Ctypes.(void @-> returning(Orx_gen.Status.t));

  let set_bootstrap =
    Ctypes.(
      Foreign.foreign(
        ~release_runtime_lock=false,
        "orxConfig_SetBootstrap",
        Foreign.funptr(bootstrap_function) @-> returning(Orx_gen.Status.t),
      )
    );

  let set_list_string = (key: string, values: list(string)) => {
    let length = List.length(values);
    let c_values = Ctypes.CArray.of_list(Ctypes.string, values);
    set_list_string(key, Ctypes.CArray.start(c_values), length);
  };

  let append_list_string = (key: string, values: list(string)) => {
    let length = List.length(values);
    let c_values = Ctypes.CArray.of_list(Ctypes.string, values);
    append_list_string(key, Ctypes.CArray.start(c_values), length);
  };

  let get_vector = (key: string): Vector.t => {
    let vector: Vector.t = Vector.allocate_raw();
    let _: Vector.t = get_vector(key, vector);
    vector;
  };

  let get_list_vector = (key: string, i: option(int)): Vector.t => {
    let vector: Vector.t = Vector.allocate_raw();
    let _: Vector.t = get_list_vector(key, i, vector);
    vector;
  };

  let with_section = (section: string, f) => {
    switch (push_section(section)) {
    | Error () as e => e
    | Ok () =>
      let result = f();
      switch (pop_section()) {
      | Error () as e => e
      | Ok () => Ok(result)
      };
    };
  };

  let get =
      (get: string => 'a, ~section: string, ~key: string): result('a, 'err) => {
    with_section(section, () => get(key));
  };

  let get_list_item =
      (
        get: (string, option(int)) => 'a,
        i: option(int),
        ~section: string,
        ~key: string,
      )
      : result('a, 'error) => {
    with_section(section, () => get(key, i));
  };

  let get_list =
      (get: (string, option(int)) => 'a, ~section: string, ~key: string)
      : result(list('a), unit) => {
    let get_all = () => {
      let count = get_list_count(key);
      List.init(count, i => get(key, Some(i)));
    };
    with_section(section, get_all);
  };
};

module Orx_thread = {
  let set_ocaml_callbacks =
    Ctypes.(
      Foreign.foreign(
        ~release_runtime_lock=false,
        "ml_orx_thread_set_callbacks",
        void @-> returning(void),
      )
    );
};

module Main = {
  let init_function = Ctypes.(void @-> returning(Orx_gen.Status.t));
  let run_function = Ctypes.(void @-> returning(Orx_gen.Status.t));
  let exit_function = Ctypes.(void @-> returning(void));

  // This is wrapped differently because the underlying orx function is
  // inlined in orx.h
  let execute_c = {
    Ctypes.(
      Foreign.foreign(
        ~release_runtime_lock=false,
        "ml_orx_execute",
        int
        @-> ptr(string)
        @-> Foreign.funptr(~runtime_lock=false, init_function)
        @-> Foreign.funptr(~runtime_lock=false, run_function)
        @-> Foreign.funptr(~runtime_lock=false, exit_function)
        @-> returning(void),
      )
    );
  };

  let execute = (~init, ~run, ~exit, ()) => {
    // Start the orx main loop
    let empty_argv = Ctypes.from_voidp(Ctypes.string, Ctypes.null);
    execute_c(
      0,
      empty_argv,
      Sys.opaque_identity(init),
      Sys.opaque_identity(run),
      Sys.opaque_identity(exit),
    );
  };
};