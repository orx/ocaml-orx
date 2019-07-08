let (!@) = Ctypes.(!@);

let orx_error = (name: string) => {
  Fmt.invalid_arg("Fatal orx error in %s", name);
};

module Orx_gen = Orx_bindings.Bindings(Generated);

module Camera = Orx_gen.Camera;
module Display = Orx_gen.Display;
module Fx_event = Orx_gen.Fx_event;
module Resource = Orx_gen.Resource;
module Viewport = Orx_gen.Viewport;

module Vector = {
  include Orx_gen.Vector;

  let rotate_2d = (v: t, angle: float): t => {
    let rotated: t = allocate_raw();
    // rotate_2d returns the rotated pointer, so there's no need to keep it
    // around twice
    let _: t = rotate_2d(rotated, v, angle);
    rotated;
  };
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

  let get_gravity = () => {
    let v: Vector.t = Vector.allocate_raw();
    let _: option(Vector.t) = get_gravity(v);
    v;
  };
};

module Object = {
  include Orx_gen.Object;

  let get_world_position = (o: t): Vector.t => {
    let pos = Vector.allocate_raw();
    let ret: Vector.t = get_world_position(o, pos);
    if (Ctypes.is_null(ret)) {
      orx_error("get_world_position");
    } else {
      pos;
    };
  };

  let set_position = (o: t, v: Vector.t): unit => {
    switch (set_position(o, v)) {
    | Ok () => ()
    | Error () => orx_error("set_position")
    };
  };

  let set_text_string = (o: t, s: string): unit => {
    switch (set_text_string(o, s)) {
    | Ok () => ()
    | Error () => orx_error("set_text_string")
    };
  };
};

module Event = {
  include Orx_gen.Event;

  let get_sender_object = (event: t): Object.t => {
    Object.of_void_pointer(Ctypes.getf(!@event, Orx_types.Event.sender));
  };

  let get_recipient_object = (event: t): Object.t => {
    Object.of_void_pointer(Ctypes.getf(!@event, Orx_types.Event.recipient));
  };

  let event_handler = Ctypes.(t @-> returning(Orx_gen.Status.t));

  let add_handler =
    Ctypes.(
      Foreign.foreign(
        "orxEvent_AddHandler",
        Orx_types.Event_type.t
        @-> Foreign.funptr(event_handler)
        @-> returning(Orx_gen.Status.t),
      )
    );
};

module Clock = {
  include Orx_gen.Clock;

  let callback = Ctypes.(Info.t @-> ptr(void) @-> returning(void));

  let c_register =
    Ctypes.(
      Foreign.foreign(
        "orxClock_Register",
        t
        @-> Foreign.funptr(callback)
        @-> ptr(void)
        @-> Orx_types.Module_id.t
        @-> Orx_types.Clock_priority.t
        @-> returning(Orx_gen.Status.t),
      )
    );

  // Collect callbacks so they're not collected.  A user would normally be able
  // to do this but we wrap a user's callback to "hide" the unused context
  // argument.
  let registered_callbacks: ref(list((Info.t, Ctypes.ptr(unit)) => unit)) =
    ref([]);

  let register = (clock: t, callback, module_, priority) => {
    let callback_wrapper = (info, _ctx) => callback(info);
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

module Main = {
  let init_function = Ctypes.(void @-> returning(Orx_gen.Status.t));
  let run_function = Ctypes.(void @-> returning(Orx_gen.Status.t));
  let exit_function = Ctypes.(void @-> returning(void));

  // This is wrapped differently because it's inlined in orx.h
  let execute_c = {
    Ctypes.(
      Foreign.foreign(
        "ml_orx_execute",
        int
        @-> ptr(string)
        @-> Foreign.funptr(init_function)
        @-> Foreign.funptr(run_function)
        @-> Foreign.funptr(exit_function)
        @-> returning(void),
      )
    );
  };

  let execute = (~init, ~run, ~exit, ()) => {
    let empty_argv = Ctypes.from_voidp(Ctypes.string, Ctypes.null);
    execute_c(0, empty_argv, init, run, exit);
  };
};