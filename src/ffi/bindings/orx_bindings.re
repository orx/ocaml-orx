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
    type t = {
      x: float,
      y: float,
      z: float,
    };

    type t_ptr = ptr(structure(T.Vector.t));

    let allocate_raw = (): ptr(structure(T.Vector.t)) =>
      allocate_n(T.Vector.t, ~count=1);

    let of_raw = (v: t_ptr): t => {
      let v = !@v;
      {
        x: Ctypes.getf(v, T.Vector.x),
        y: Ctypes.getf(v, T.Vector.y),
        z: Ctypes.getf(v, T.Vector.z),
      };
    };

    let to_raw = (vector: t): t_ptr => {
      let v = allocate_n(T.Vector.t, ~count=1);
      setf(!@v, T.Vector.x, vector.x);
      setf(!@v, T.Vector.y, vector.y);
      setf(!@v, T.Vector.z, vector.z);
      v;
    };

    let t = {
      Ctypes.view(~read=of_raw, ~write=to_raw, ptr(T.Vector.t));
    };

    let of_raw_opt = (v: t_ptr): option(t) =>
      if (Ctypes.is_null(v)) {
        None;
      } else {
        Some(of_raw(v));
      };

    let to_raw_opt = (v_opt: option(t)): t_ptr =>
      switch (v_opt) {
      | None => Ctypes.from_voidp(T.Vector.t, Ctypes.null)
      | Some(v) => to_raw(v)
      };

    let t_opt = {
      Ctypes.view(~read=of_raw_opt, ~write=to_raw_opt, ptr(T.Vector.t));
    };
  };

  module Config_generated = {
    /* This module will be included in the Config module defined in orx.re */
    let set_basename =
      c("orxConfig_SetBaseName", string @-> returning(Status.t));
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

  module Object = {
    type t = ptr(unit);

    let t: typ(t) = ptr(void);
    let t_opt: typ(option(t)) = ptr_opt(void);

    let of_void_pointer = (p: ptr(unit)): t => {
      p;
    };

    let create_from_config =
      c("orxObject_CreateFromConfig", string @-> returning(t_opt));

    let enable = c("orxObject_Enable", t @-> bool @-> returning(void));

    let get_name = c("orxObject_GetName", t @-> returning(string));

    let get_child_object = c("orxObject_GetChild", t @-> returning(t_opt));
    let get_world_position =
      c(
        "orxObject_GetWorldPosition",
        t @-> ptr(T.Vector.t) @-> returning(ptr(T.Vector.t)),
      );

    // Position and orientation
    let get_rotation = c("orxObject_GetRotation", t @-> returning(float));

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
    let t = ptr_opt(void);

    let create_from_config =
      c("orxViewport_CreateFromConfig", string @-> returning(t));
  };

  module Input = {
    let t = ptr(void);

    let is_active = c("orxInput_IsActive", string @-> returning(bool));

    let has_new_status =
      c("orxInput_HasNewStatus", string @-> returning(bool));
  };

  module Event = {
    module Raw = {
      type t = ptr(structure(T.Event.t));

      let to_event_id = (raw: t): int64 => {
        Ctypes.getf(!@raw, T.Event.event_id) |> Unsigned.UInt.to_int64;
      };
    };
    module Physics = {
      type objects = {
        sender: Object.t,
        recipient: Object.t,
      };

      type t =
        | Contact_add(objects)
        | Contact_remove(objects);

      let objects_of_raw = (raw: Raw.t): objects => {
        let sender =
          Ctypes.getf(!@raw, T.Event.sender) |> Object.of_void_pointer;
        let recipient =
          Ctypes.getf(!@raw, T.Event.recipient) |> Object.of_void_pointer;
        {sender, recipient};
      };

      let of_raw = (raw: Raw.t): t => {
        let event_id = Raw.to_event_id(raw);
        let event =
          List.assoc_opt(event_id, T.Physics_event.map_from_constant);
        switch (event) {
        | None => Fmt.invalid_arg("Unhandled physics event id: %Ld", event_id)
        | Some(event) =>
          let objects = objects_of_raw(raw);
          switch (event) {
          | Contact_add => Contact_add(objects)
          | Contact_remove => Contact_remove(objects)
          };
        };
      };
    };

    type t =
      | Physics(Physics.t);

    let of_raw = (e: Raw.t): t => {
      switch (Ctypes.getf(!@e, T.Event.event_type)) {
      | Physics => Physics(Physics.of_raw(e))
      | _ => Fmt.invalid_arg("Unsupported event")
      };
    };

    let t =
      Ctypes.view(~read=of_raw, ~write=_ => assert(false), ptr(T.Event.t));
  };
};