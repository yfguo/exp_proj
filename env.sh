BASE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
INSTALL_DIR=${BASE_DIR}/install

SCRIPT_PATH=$(dirname "$0")
SCRIPT_PATH=$(cd "${SCRIPT_PATH}"; pwd -P)

export MODULEPATH=/soft/modulefiles:$MODULEPATH

find_file_rec() {
    local name=${1:-env.sh}
    local current_dir=${2:-$PWD}

    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/$name" ]]; then
            echo "$current_dir/$name"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done

    # Check the root directory as the last step
    if [[ -f "/env.sh" ]]; then
        echo "/env.sh"
        return 0
    fi

    echo "$name not found"
    return 1
}

op_log() {
    local timestamp=$(TZ="America/Chicago" date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $@" >> $BASE_DIR/op_log.log
}

split_and_sort() {
    local word_array=(${1//_/})

    # Sort the array
    sorted_array=($(printf '%s\n' "${word_array[@]}" | sort))

    for _item in ${sorted_array[@]}; do
        if [[ -z ${SPEC_OPTIONS} ]]; then
            SPEC_OPTIONS=${_item}
        else
            SPEC_OPTIONS=${SPEC_OPTIONS}_${_item}
        fi
    done
}

SPEC_REPO="main"
SPEC_DEVICE="ofi"
SPEC_COMPILER="gnu"
SPEC_OPTIONS_RAW=""
SPEC_OPTIONS=""

parse_spec() {
    local _arr=(${1//-/ })
    local _repo_base=${2:-mpich}

    for _item in ${_arr[@]}; do
        case "${_item}" in
            ucx)
                SPEC_DEVICE="ucx"
                ;;
            ofi)
                SPEC_DEVICE="ofi"
                ;;
            gnu)
                SPEC_COMPILER="gnu"
                ;;
            clang)
                SPEC_COMPILER="clang"
                ;;
            intel)
                SPEC_COMPILER="intel"
                ;;
            amd)
                SPEC_COMPILER="amd"
                ;;
            *)
                if [[ -d ${BASE_DIR}/${_repo_base}/${_item} ]]; then
                    SPEC_REPO=${_item}
                else
                    if [[ -z ${SPEC_OPTIONS_RAW} ]]; then
                        SPEC_OPTIONS_RAW=${_item}
                    else
                        SPEC_OPTIONS_RAW=${SPEC_OPTIONS_RAW}_${_item}
                    fi
                fi
                ;;
        esac
    done

    if [[ -z ${SPEC_OPTIONS_RAW} ]]; then
        SPEC_OPTIONS_RAW="default"
    fi

    split_and_sort ${SPEC_OPTIONS_RAW}

    echo "SPEC_REPO: ${SPEC_REPO}"
    echo "SPEC_COMPILER: ${SPEC_COMPILER}"
    echo "SPEC_DEVICE: ${SPEC_DEVICE}"
    echo "SPEC_OPTIONS: ${SPEC_OPTIONS}"
}

set_compiler() {
    case "${SPEC_COMPILER}" in
        gnu)
            module load gcc/14.1.0
            CC=gcc
            CXX=g++
            OPT_COMPILER=""
            ;;
        clang)
            CC=clang
            CXX=clang++
            OPT_COMPILER=""
            ;;
        intel)
            module load intel/oneapi/release
            CC=icx
            CXX=icpx
            OPT_COMPILER=""
            ;;
        amd)
            module load aomp
            CC=clang
            CXX=clang++
            OPT_COMPILER=""
            ;;
        *)
            exit 1
    esac
    echo "CC=${CC} CXX=${CXX} OPT_COMPILER: ${OPT_COMPILER}"
}

set_device() {
    local param=${1:-sockets}
    case "${SPEC_DEVICE}" in
        ofi)
            OPT_DEVICE="--with-device=ch4:ofi"
            OPT_DEVICE_PATH="--with-libfabric=${INSTALL_DIR}/libfabric/main-${SPEC_COMPILER}-${param}"
            ;;
        ucx)
            OPT_DEVICE="--with-device=ch4:ucx"
            OPT_DEVICE_PATH="--with-ucx=${INSTALL_DIR}/ucx/main-${SPEC_COMPILER}-${param}"
            ;;
        *)
            exit 1
    esac
    echo "OPT_DEVICE: ${OPT_DEVICE} ${OPT_DEVICE_PATH}"
}
