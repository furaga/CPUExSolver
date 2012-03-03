#include <stdio.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>

// TODO float用に書き換え
typedef union
{
  int32 i[2];
  double d;
} flt;

value gethi(value v)
{
  flt d;
  d.d = (double)Double_val(v);
  return copy_int32(d.i[0]);
}

value getlo(value v)
{
  flt d;
  d.d = Double_val(v);
  return copy_int32(d.i[1]);
}

