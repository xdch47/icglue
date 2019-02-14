# template init script
# predefined variable in this script: template (template name)

# generate object output filename: arguments: {object} (object-identifier)
init::output_types $template {
    set objtype [ig::db::get_attribute -object $object -attribute "type"]
    if {$objtype eq "module"} {
        set lang [ig::db::get_attribute -object $object -attribute "language"]
        set lang2type_map {
            "verilog"       {vlog-v}
            "systemverilog" {svlog-sv}
            "systemc"       {sc-h sc-cpp shell-v}
        }
        return [dict get $lang2type_map $lang]
    } elseif {$objtype eq "regfile"} {
        return {rf-csv rf-txt rf-tex rf-html rf-h rf-c rf-hpp rf-cpp rf-soc.h}
    }
    ig::log -warning "No templates available for objects of type ${objtype}"
    return {}
}

# return {<path to template file> <template type>}: arguments: {object type template_dir} (object-identifier, outputtype, path to this template's directory)
init::template_file $template {
    set templateformats {icgt wtf}
    lassign [split $type -] dir ext
    foreach {tf $templateformats {
        if {[file exists  "${template_dir}/${dir}/template.${tf}.${ext}"]} {
            return [list  "${template_dir}/${dir}/template.${tf}.${ext}" $tf]
        }
    }
    ig::log -error -abort "No template available for ${type} (No such files: ${template_dir}/${dir}/template.{[join $templateformats ","]}.${ext})"
}

# generate object output filename: arguments: {object type} (object-identifier, outputtype)
init::output_file $template {
    set output_dir_root "."
    if {[info exists ::env(ICPRO_DIR)]} {
        set output_dir_root "$::env(ICPRO_DIR)"
    }
    set object_name [ig::db::get_attribute -object $object -attribute "name"]
    set parent_unit [ig::db::get_attribute -object $object -attribute "parentunit" -default $object_name]
    set mode        [ig::db::get_attribute -object $object -attribute "mode"       -default "rtl"]
    set lang        [ig::db::get_attribute -object $object -attribute "language"   -default "verilog"]

    lassign [split $type -] maintype ext

    # special cases
    if {$maintype eq "rf"} {
        if {$ext in {csv txt tex html}} {
            return "${output_dir_root}/doc/${ext}/${object_name}.${ext}"
        }
        foreach {fext dir subdir} {
            "h"     host include
            "hpp"   host include
            "c"     host src
            "cpp"   host src
            "soc.h" soc  include
        } {
            if {${ext} eq ${fext}} {
                return "${output_dir_root}/software/${dir}/regfile_access/${subdir}/rf_${object_name}.${ext}"
            }
        }
    }

    # default
    foreach {dir types} {
        "verilog"       {vlog-v shell-v}
        "systemverilog" {svlog-sv}
        "systemc"       {sc-h sc-cpp}
    } {
        if {$type in $types} {
            return "${output_dir_root}/units/${parent_unit}/source/${mode}/${dir}/${object_name}.${ext}"
        }
    }

    ig::log -error -abort "No output directory defined for type $type -- $object_name ($mode,$lang)."
}

