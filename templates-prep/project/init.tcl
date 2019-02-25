# template init script
# predefined variable in this script: template (template name)

# print template help, return nothing, arguments: {}
init::help $template {
    puts [join {
        "--path <project-path>"
    } "\n"]
}

# check userdata, return true/false: arguments: {userdata}
init::check_userdata $template {
    return true
}

# return {<path to template file> <template type> <output file>}: arguments: {userdata template_dir}
init::template_data $template {
    set tf_map {
        "env.template.sh"      "icgt" "env.sh"
        "vlog/tb_selfcheck.vh" "icgt" "global_src/verilog/tb_selfcheck.vh"
        "stimc/tb_selfcheck.h" "icgt" "global_src/stimc/tb_selfcheck.h"
        "stimc/tb_selfcheck.c" "icgt" "global_src/stimc/tb_selfcheck.c"
    }

    set output_dir_root "."

    if {[dict exists $userdata path]} {
        set output_dir_root $path
    }

    set result [list]
    foreach {i_tfile i_format i_ofile} $tf_map {
        if {$i_format ne "link"} {
            set i_tfile "${template_dir}/${i_tfile}"
        }

        set i_ofile "${output_dir_root}/${i_ofile}"

        lappend result [list $i_tfile $i_format $i_ofile]
    }

    return $result
}

