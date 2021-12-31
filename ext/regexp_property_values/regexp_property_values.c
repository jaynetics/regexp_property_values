#include "ruby.h"
#include "ruby/encoding.h"
#include "ruby/oniguruma.h" // still in recent rubies f. backwards compatibility

static int prop_name_to_ctype(char *name, rb_encoding *enc)
{
  UChar *uname;
  int ctype;

  uname = (UChar *)name;
  ctype = ONIGENC_PROPERTY_NAME_TO_CTYPE(enc, uname, uname + strlen(name));
  if (ctype < 0)
    rb_raise(rb_eArgError, "Unknown property name `%s`", name);

  return ctype;
}

VALUE onig_ranges_to_rb(const OnigCodePoint *onig_ranges)
{
  unsigned int range_count, i;
  VALUE result, sub_range;

  range_count = onig_ranges[0];
  result = rb_ary_new2(range_count); // rb_ary_new_capa not avail. in Ruby 2.0

  for (i = 0; i < range_count; i++)
  {
    sub_range = rb_range_new(INT2FIX(onig_ranges[(i * 2) + 1]),
                             INT2FIX(onig_ranges[(i * 2) + 2]),
                             0);
    rb_ary_store(result, i, sub_range);
  }

  return result;
}

VALUE rb_prop_ranges(char *name)
{
  int ctype;
  const OnigCodePoint *onig_ranges;
  OnigCodePoint sb_out;
  rb_encoding *enc;
  enc = rb_utf8_encoding();

  ctype = prop_name_to_ctype(name, enc);
  ONIGENC_GET_CTYPE_CODE_RANGE(enc, ctype, &sb_out, &onig_ranges);
  return onig_ranges_to_rb(onig_ranges);
}

VALUE method_matched_ranges(VALUE self, VALUE arg)
{
  char *prop_name;
  prop_name = StringValueCStr(arg);
  return rb_prop_ranges(prop_name);
}

void Init_regexp_property_values()
{
#ifdef HAVE_RB_EXT_RACTOR_SAFE
  rb_ext_ractor_safe(true);
#endif

  VALUE module;
  module = rb_define_module("OnigRegexpPropertyHelper");
  rb_define_singleton_method(module, "matched_ranges", method_matched_ranges, 1);
}
