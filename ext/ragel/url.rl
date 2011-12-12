#include "ruby.h"

static VALUE Rlinker = Qnil;

static int in_anchor, in_email, in_img, in_object, linking_mode;

void Init_ragelink();

    %%{
    machine autolink;
    alphtype unsigned char;

    include WChar "unicode.rl";

    include "url_productions.rl";

      main := |*
        start_email => {
          in_email = 1;
          rb_str_cat(output, ts, te-ts);
        };

        end_email => {
          in_email = 0;
          rb_str_cat(output, ts, te-ts);
        };

        start_anchor => {
          in_anchor = 1;
          rb_str_cat(output, ts, te-ts);
        };

        end_anchor => {
          in_anchor = 0;
          rb_str_cat(output, ts, te-ts);
        };

        start_img => {
          in_img = 1;
          rb_str_cat(output, ts, te-ts);
        };

        end_img => {
          in_img = 0;
          rb_str_cat(output, ts, te-ts);
        };

        start_object => {
          in_object = 1;
          rb_str_cat(output, ts, te-ts);
        };

        end_object => {
          in_object = 0;
          rb_str_cat(output, ts, te-ts);
        };

        url => {
          VALUE url;

          if((linking_mode != 1) || (in_anchor | in_email | in_img | in_object)) {
            rb_str_cat(output, ts, te-ts);
          } else {
            if(blk != Qnil) {
              url = rb_str_new(ts, te-ts);
              rb_str_concat(output, rb_funcall(blk, call, 1, url));
            } else {
              rb_str_cat(output, "<a href=\"", 9);
              rb_str_cat(output, ts, te-ts);
              rb_str_cat(output, "\">", 2);
              rb_str_cat(output, ts, te-ts);
              rb_str_cat(output, "</a>", 4);
            }

          }
        };

        email => {
          VALUE email;

          if((linking_mode != 2) || in_anchor) {
            rb_str_cat(output, ts, te-ts);
          } else {

            if(blk != Qnil) {
              email = rb_str_new(ts, te-ts);
              rb_str_concat(output, rb_funcall(blk, call, 1, email));
            } else {
              rb_str_cat(output, "<a href=\"mailto:", 16);
              rb_str_cat(output, ts, te-ts);
              rb_str_cat(output, "\">", 2);
              rb_str_cat(output, ts, te-ts);
              rb_str_cat(output, "</a>", 4);
            }
          }
        };

        any => {
          rb_str_cat(output, ts, te-ts);
        };
      *|;
    }%%

    %% write data;

static VALUE
autolink_ragel(VALUE data, int mode, VALUE blk) {
  VALUE output = rb_str_new2(""), call = rb_intern("call");
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


void
Init_ragelink() {
  Rlinker = rb_define_module("Ragelink");
  rb_define_method(Rlinker, "autolink_ragel_urls", autolink_ragel_urls, 1);
  rb_define_method(Rlinker, "autolink_ragel_emails", autolink_ragel_emails, 1);

}
