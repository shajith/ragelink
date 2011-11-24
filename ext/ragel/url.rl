#include "ruby.h"

static VALUE Rlinker = Qnil;

static int in_anchor, in_email, in_img, in_object;

void Init_ragelink();

    %%{
    machine autolink;
    alphtype unsigned char;

    include WChar "unicode.rl";

    scheme = ("http" | "https");
    authority = "://";

    start_email = alnum+ "@";
    end_email = space;

    char = ualnum;

    host_char = (alnum | "-") - [_!];

    host = host_char+ ('.' host_char+)*;

    common_tld = "com" | "net" | "org" | "ly" | "co.uk" | "us" | "sk";

    path_char = char | [|+@_~.%;=\-];

    path_suffix = (path_char* (path_char - [.])) | (path_char* '(' path_char* ')' path_char*);

    path = ("/" path_suffix?)* ;

    param_char = char | [/-@.|];
    param_key = param_char+;
    param_value = param_char+;

    fragment = "#" char+;

    param = param_key "=" param_value;

    params =  param_key | param? | (param ("&" param)*);

    query = ("?" params);

    bare_host = ("www" ('.' char+)+) | (char+ ('.' char+)* '.' common_tld);

    url = (scheme authority host path query? fragment?) | (bare_host path query?);

    start_anchor = "<a ";
    end_anchor = "</a>";

    start_img = "<img ";
    end_img = "</img>";

    start_object = "<object ";
    end_object = "</object>";

      main := |*
        start_email => {
          in_email = 1;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        end_email => {
          in_email = 0;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        start_anchor => {
          in_anchor = 1;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        end_anchor => {
          in_anchor = 0;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        start_img => {
          in_img = 1;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        end_img => {
          in_img = 0;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        start_object => {
          in_object = 1;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        end_object => {
          in_object = 0;
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };

        url => {
          VALUE anchor;
          VALUE url = rb_str_new(ts, te-ts);

          if(in_anchor | in_email | in_img | in_object) {
            rb_str_concat(output, rb_str_new(ts, te-ts));
          } else {
            if(rb_block_given_p()) {
              anchor =  rb_yield(url);
            } else {
              anchor = make_url(url);
            }
            rb_str_concat(output, anchor);
          }
        };

        any => {
          rb_str_concat(output, rb_str_new(ts, te-ts));
        };
      *|;
    }%%

    %% write data;

static VALUE 
make_url(VALUE url) {
  VALUE href = rb_str_new2("");
  rb_str_cat2(href, "<a href=\"");
  rb_str_concat(href, url);
  rb_str_cat2(href, "\">");
  rb_str_concat(href, url);
  rb_str_cat2(href, "</a>");
  return href;
}

static VALUE 
autolink_ragel(VALUE self, VALUE data) {
  VALUE output = rb_str_new2("");
  long cs = 0, act = 0;
  
  char *ts;
  char *te;
  unsigned char *p = RSTRING_PTR(data);
  unsigned char *pe = p + RSTRING_LEN(data);
  unsigned char *eof = pe;
  
  %% write init;
  %% write exec;
  return output;
}

void Init_ragelink() {
  Rlinker = rb_define_module("Ragelink");
  rb_define_method(Rlinker, "autolink_ragel", autolink_ragel, 1);
}
