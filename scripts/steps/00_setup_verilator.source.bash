expected_source_script=00_setup.source.bash

if [ -z "$BASH_SOURCE" ]
then
    printf "script \"$0\" should be sourced from $expected_source_script\n" 1>&2
    exit 1
fi

this_script=$(basename "${BASH_SOURCE[0]}")
source_script=$(basename "${BASH_SOURCE[1]}")

if [ -z "$source_script" ]
then
    printf "script \"$this_script\" should be sourced from $expected_source_script\n" 1>&2
    return 1
fi

if [ "$source_script" != $expected_source_script ]
then
    printf "script \"$this_script\" should be sourced from \"$expected_source_script\", not \"$source_script\"\n" 1>&2
    exit 1
fi

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

verilator_setup ()
{
    if is_command_available verilator ; then
        return  # Already set up
    fi

    alt_icarus_install_path="$HOME/install/verilator"

    if [ -d "$alt_icarus_install_path" ]
    then
        export PATH="${PATH:+$PATH:}$alt_icarus_install_path/bin"
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$alt_icarus_install_path/lib"
    fi
}
#-----------------------------------------------------------------------------
run_verilator ()
{
    is_command_available_or_error_and_install verilator
    #!/bin/bash

    # check version
    version=$(verilator --version | awk '{print $2}')

    # version compare
    if [[ $(echo "$version 5.0" | awk '{print ($1 < $2)}') -eq 1 ]]; then
        error "You have Verilator version $version installed. \
           Version > 5.0 must be installed. \
           Instructions can be found here : \
           https://github.com/NickolayTernovoy/basics-graphics-music-verilator-cocotb-support/blob/main/README_Verilator.md
           "
    else
        echo "Version check passed"
    fi


    # Verilator flags
    BIN=Vtop
    VFLAGS="--trace-fst --cc --binary -Wno-style -Wno-fatal --compiler clang -o $BIN -O0"

    #For building
    verilator $VFLAGS \
    +incdir+.. +incdir+"$lab_dir/common" \
    ../*.sv "$lab_dir/common"/*.sv \
             --top-module tb \
    |& tee "$log"

    # For simulation
    ./obj_dir/$BIN \
    |& tee "$log"

    if grep -m 1 ERROR "$log" ; then
        warning errors detected
    fi

    #-------------------------------------------------------------------------

    is_command_available_or_error_and_install gtkwave

    gtkwave_script=../gtkwave.tcl

    gtkwave_options=

    if [ -f $gtkwave_script ]; then
        gtkwave_options="--script $gtkwave_script"
    fi

    if    [ "$OSTYPE" = "linux-gnu" ]  \
       || [ "$OSTYPE" = "cygwin"    ]  \
       || [ "$OSTYPE" = "msys"      ]
    then
        gtkwave=gtkwave
    elif [ ${OSTYPE/[0-9]*/} = "darwin" ]
    # elif [[ "$OSTYPE" = "darwin"* ]]  # Alternative way
    then
        # For some reason the following way of opening the application
        # under Mac does not read the script file:
        #
        # open -a gtkwave dump.vcd --args --script $PWD/gtkwave.tcl
        #
        # This way works:

        gtkwave=/Applications/gtkwave.app/Contents/MacOS/gtkwave-bin
    else
        error 1 "don't know how to run GTKWave on your OS $OSTYPE"
    fi

    $gtkwave tb_verialtor.vcd $gtkwave_options
}
#-----------------------------------------------------------------------------
