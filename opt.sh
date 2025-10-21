#!/bin/bash

# A function to display the script usage
usage() {
    echo "Usage: $0 [-a] [-b <arg>] [-c] <file>"
    echo "  -a        : Force autogen step"
    echo "  -c        : Force configure step"
    echo "  -m        : Set MPI type: mpich (default), ompi, cray"
    echo "  -s <spec> : Specify a spec name"
    echo "  <file1> [<file2> ...] : Specify one or more files to process"
    exit 1
}

# Initialize variables for options
option_autogen=false
option_configure=false
option_mpitype="mpich"
option_spec=""

# Process the options using getopts
while getopts ":acm:s:" opt; do
    case ${opt} in
        a)
            option_autogen=true
            ;;
        c)
            option_configure=true
            ;;
        m)
            option_mpitype=$OPTARG
            ;;
        s)
            option_spec=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Remove the options from the positional parameters
shift $((OPTIND -1))

# Check if a file argument is provided
# if [ $# -ne 1 ]; then
#     echo "Error: A file must be specified."
#     usage
# fi

option_positional=$@

# Display the parsed options and file
echo "Option force autogen: $option_autogen"
echo "Option force configure: $option_configure"
echo "Option mpi type: $option_mpitype"
echo "Option spec: $option_spec"
echo "Positional options: $option_positional"

