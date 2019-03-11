# test files
deploy mod.icglue           units/mod/source/gen/

# setup
run icprep project
eval_run_output {glob {I,Gen*} 4}

run_nocheck icglue units/mod/source/gen/mod.icglue -o "vlog-v"
eval_run_output {
    glob {W,RFTP*Missing port*} 13
}
