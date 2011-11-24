#include "ruby.h"

static VALUE Rlinker = Qnil;

static int in_anchor, in_email, in_img, in_object, linking_mode;

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

    email_user_char = alnum | ['.!#\$%+\-];    
    email_host_char = alnum | "-";
    email = email_user_char+ "@" email_host_char+ ("." email_host_char+)+;

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

          if((linking_mode != 1) || (in_anchor | in_email | in_img | in_object)) {
            rb_str_concat(output, rb_str_new(ts, te-ts));
          } else {
            if(blk != !Qnil) {
              anchor =  rb_funcall(blk, rb_intern("call"), 1, url);;
            } else {
              anchor = make_url(url);
            }
            rb_str_concat(output, anchor);
          }
        };

        email => {
          //"<a href=\"mailto:#{text}\">#{display_text}</a>"
          VALUE mailto;
          VALUE email = rb_str_new(ts, te-ts);

          if((linking_mode != 2) || in_anchor) {
            rb_str_concat(output, email);
          } else {

            if(blk != Qnil) {
              mailto =  rb_funcall(blk, rb_intern("call"), 1, email);
            } else {
              mailto = rb_str_new2("<a href=\"mailto:");
              rb_str_concat(mailto, email);
              rb_str_cat2(mailto, "\">");
              rb_str_concat(mailto, email);
              rb_str_cat2(mailto, "</a>");
            }

            rb_str_concat(output, mailto);
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
  autolink_ragel(VALUE data, int mode, VALUE blk) {
  VALUE output = rb_str_new2("");
  long cs = 0, act = 0;
  linking_mode = mode;

  char *ts;
  char *te;
  unsigned char *p = RSTRING_PTR(data);
  unsigned char *pe = p + RSTRING_LEN(data);
  unsigned char *eof = pe;

  in_anchor = in_email = in_img = in_object = 0;

  %% write init;
  %% write exec;
  return output;
}

static VALUE 
autolink_ragel_urls(VALUE self, VALUE data) {
  VALUE blk = Qnil;

  if(rb_block_given_p()) {
    blk = rb_block_proc();
  }

  return autolink_ragel(data, 1, blk);
}

static VALUE 
autolink_ragel_emails(VALUE self, VALUE data) {
  VALUE blk = Qnil;

  if(rb_block_given_p()) {
    blk = rb_block_proc();
  }

  return autolink_ragel(data, 2, blk);
}


void Init_ragelink() {
  Rlinker = rb_define_module("Ragelink");
  rb_define_method(Rlinker, "autolink_ragel_urls", autolink_ragel_urls, 1);
  rb_define_method(Rlinker, "autolink_ragel_emails", autolink_ragel_emails, 1);

}
