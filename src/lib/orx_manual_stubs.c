#define CAML_NAME_SPACE
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/threads.h>

#include <orx.h>

/* Threads */

orxSTATUS ml_orx_thread_start(void *_context)
{
    int status = 0;
    status = caml_c_thread_register();
    return (status ? orxSTATUS_SUCCESS : orxSTATUS_FAILURE);
}

orxSTATUS ml_orx_thread_stop(void *_context)
{
    int status = 0;
    status = caml_c_thread_unregister();
    return (status ? orxSTATUS_SUCCESS : orxSTATUS_FAILURE);
}

value ml_orx_thread_set_callbacks(value _unit)
{
    CAMLparam1(_unit);
    orxThread_SetCallbacks(&ml_orx_thread_start, &ml_orx_thread_stop, NULL);
    CAMLreturn(Val_unit);
}

/* Event handlers */

orxSTATUS ml_orx_event_add_handler(orxEVENT_TYPE event_type, orxEVENT_HANDLER event_handler, orxU32 add_id_flags, orxU32 remove_id_flags)
{
    orxSTATUS result = orxSTATUS_SUCCESS;
    result = orxEvent_AddHandler(event_type, event_handler);
    if (result == orxSTATUS_SUCCESS)
    {
        result = orxEvent_SetHandlerIDFlags(event_handler, event_type, NULL, add_id_flags, remove_id_flags);
    }
    return result;
}

/* Main engine entrypoint */

void ml_orx_execute(int argc, char **argv,
                    orxMODULE_INIT_FUNCTION init,
                    orxMODULE_RUN_FUNCTION run,
                    orxMODULE_EXIT_FUNCTION exit)
{
    orx_Execute(argc,
                argv,
                init,
                run,
                exit);
    return;
}
