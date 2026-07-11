#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern SEXP getSeqRegion(SEXP a);

static const R_CallMethodDef CallEntries[] = {
    {"C_getSeqRegion", (DL_FUNC) &getSeqRegion, 1},
    {NULL, NULL, 0}
};

void R_init_alignstatplot(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, TRUE);
}
