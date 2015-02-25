$pdflatex = 'pdflatex -synctex=1 %O %S';
$compiling_cmd = "xdotool search --name \"%D\" " .
                 "set_window --name \"%D compiling...\"";
$success_cmd = "xdotool search --name \"%D\" " .
               "set_window --name \"%D OK\"; " .
               "gvim --remote-expr 'latex#latexmk#callback(1)'";
$failure_cmd = "xdotool search --name \"%D\" " .
               "set_window --name \"%D FAILURE\"; " .
               "gvim --remote-expr 'latex#latexmk#callback(0)'";
