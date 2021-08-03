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