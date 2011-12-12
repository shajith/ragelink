%%{
    machine autolink;

    scheme = ("http" | "https");
    authority = "://";

    start_email = alnum+ "@";
    end_email = space;

    char = ualnum;

    host_char = (ualnum | "-") - [_!];

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

    port = ":" [0-9]+;

    url = (scheme authority host port? path query? fragment?) | (bare_host path query?);

    start_anchor = "<a ";
    end_anchor = "</a>";

    start_img = "<img ";
    end_img = "</img>";

    start_object = "<object ";
    end_object = "</object>";

    email_user_char = alnum | ['.!#\$%+\-_];
    email_host_char = alnum | "-";
    email = email_user_char+ "@" email_host_char+ ("." email_host_char+)+;
}%%

