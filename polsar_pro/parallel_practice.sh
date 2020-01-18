(for x in `cat run1.txt` ; do
          
        done) | echo

(for x in `cat list` ; do
          no_extension=${x%.*};
          do_something $x scale $no_extension.jpg
          do_step2 <$x $no_extension
        done) | process_output


cat run1.txt | parallel "do_something {} scale {.}.jpg ; do_step2 <{} {.}" | process_output
