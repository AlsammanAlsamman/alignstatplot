#include <stdio.h>
#include <R.h>
#include <Rinternals.h>

int *numberOfregions(char *Seq)
{
    int seqLength = strlen(Seq);
    int *numberOfRegions = (int *) malloc(sizeof(int));
    int i;
    int count = 0;
    for ( i = 0; i < seqLength; i++)
    {
        if (Seq[i] == '%')
        {
            count++;
        }
    }
    *numberOfRegions = count;
    return numberOfRegions;
}
SEXP getSeqRegion(SEXP a)
{
    char *Seq = CHAR(STRING_ELT(a, 0));
    int *numberOfRegions = numberOfregions(Seq);
    //two index matrixes to store the start and end of each region
    SEXP res = PROTECT(allocVector(VECSXP, *numberOfRegions));
    int len = strlen(Seq);
    int i;
    int j;
    int resn = 0;
    int trueLoc = 0;
    //find the area between $ and % signs
    for (i = 0; i < len; i++)
    {
        if (Seq[i] != '$' && Seq[i] != '%')
        {
            trueLoc++;
        }
        if (Seq[i] == '$')
        {
            j = trueLoc+1;
            for (; i < len; i++)
            {
                if (Seq[i] != '$' && Seq[i] != '%')
                {
                    trueLoc++;
                }

                if (Seq[i] == '%')
                {
                    //Rprintf("%d\t%i\n", j, i);
                    SET_VECTOR_ELT(res, resn, allocVector(INTSXP, 2));
                    INTEGER(VECTOR_ELT(res, resn))[0] = j;
                    INTEGER(VECTOR_ELT(res, resn))[1] = trueLoc;
                    resn++;
                    //reallocate vector to store the next region
                    break;
                }
               
            }
        }
    }
    free(numberOfRegions);
    UNPROTECT(1);
    return res;

}
