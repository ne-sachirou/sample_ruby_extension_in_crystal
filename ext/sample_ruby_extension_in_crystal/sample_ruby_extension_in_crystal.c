#include "sample_ruby_extension_in_crystal.h"

VALUE rb_mSampleRubyExtensionInCrystal;

VALUE
hello_c(VALUE self) {
  printf("Hello, World!\n");
  return Qnil;
}

VALUE
fib_c(VALUE self, VALUE rb_n) {
  int n = NUM2INT(rb_n);
  int ns[] = {1, 1};
  int i = 1;
  while (i < n) {
    int ns0 = ns[0];
    ns[0] = ns[1];
    ns[1] = ns0 + ns[1];
    ++i;
  }
  return INT2NUM(ns[1]);
}

void
Init_sample_ruby_extension_in_crystal(void)
{
  rb_mSampleRubyExtensionInCrystal = rb_define_module("SampleRubyExtensionInCrystal");
  rb_define_module_function(rb_mSampleRubyExtensionInCrystal, "hello_c", hello_c, 0);
  rb_define_module_function(rb_mSampleRubyExtensionInCrystal, "fib_c", fib_c, 1);
}
