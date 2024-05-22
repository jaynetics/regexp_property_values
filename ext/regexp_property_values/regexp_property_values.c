#include "ruby.h"
#include "ruby/encoding.h"
#include "ruby/oniguruma.h" // still in recent rubies f. backwards compatibility

static int prop_name_to_ctype(VALUE arg, rb_encoding *enc)
{
  char *name;
  UChar *uname;
  int ctype;

  name = StringValueCStr(arg);
  uname = (UChar *)name;
  ctype = ONIGENC_PROPERTY_NAME_TO_CTYPE(enc, uname, uname + strlen(name));
  if (ctype < 0)
    rb_raise(rb_eArgError, "Unknown property name `%s`", name);

  return ctype;
}

const OnigCodePoint *get_onig_ranges(VALUE prop_name)
{
  int ctype;
  const OnigCodePoint *ranges;
  OnigCodePoint sb_out;
  rb_encoding *enc;

  enc = rb_utf8_encoding();
  ctype = prop_name_to_ctype(prop_name, enc);
  ONIGENC_GET_CTYPE_CODE_RANGE(enc, ctype, &sb_out, &ranges);
  return ranges;
}

VALUE onig_ranges_to_rb_ranges(const OnigCodePoint *onig_ranges)
{
  unsigned int range_count, i;
  VALUE result, sub_range;

  range_count = onig_ranges[0];
  result = rb_ary_new_capa(range_count);

  for (i = 0; i < range_count; i++)
  {
    sub_range = rb_range_new(INT2FIX(onig_ranges[(i * 2) + 1]),
                             INT2FIX(onig_ranges[(i * 2) + 2]),
                             0);
    rb_ary_store(result, i, sub_range);
  }

  return result;
}

VALUE onig_ranges_to_rb_integers(const OnigCodePoint *onig_ranges)
{
  unsigned int range_count, i, beg, end, j;
  VALUE result;

  range_count = onig_ranges[0];
  result = rb_ary_new();

  for (i = 0; i < range_count; i++)
  {
    beg = onig_ranges[(i * 2) + 1];
    end = onig_ranges[(i * 2) + 2];
    for (j = beg; j <= end; j++)
    {
      rb_ary_push(result, INT2FIX(j));
    }
  }

  return result;
}

VALUE method_matched_ranges(VALUE self, VALUE arg)
{
  return onig_ranges_to_rb_ranges(get_onig_ranges(arg));
}

VALUE method_matched_codepoints(VALUE self, VALUE arg)
{
  return onig_ranges_to_rb_integers(get_onig_ranges(arg));
}

void Init_regexp_property_values()
{
#ifdef HAVE_RB_EXT_RACTOR_SAFE
  rb_ext_ractor_safe(true);
#endif

  VALUE module;
  module = rb_define_module("OnigRegexpPropertyHelper");
  rb_define_singleton_method(module, "matched_ranges", method_matched_ranges, 1);
  rb_define_singleton_method(module, "matched_codepoints", method_matched_codepoints, 1);
}
