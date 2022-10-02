#!/bin/bash
# Install Luvit-Lit-Luvi

function checkerr {
    if [[ ! $1 == 0 ]]; then
        printf "$2\n   To show more information of error, check log file\n"
        read -p " * Open log file? [y/n] " user
        if [[ $user == [yY] || $user == [yY][eE][sS] ]]; then
            less "$3"
        fi
        return 1
    fi
    return 0
}

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear='\033[0m'

headerr="${red}[BUILD]${clear}"
head="${green}[BUILD]${clear}"
ok=" ${yellow}[ OK! ]${clear}\n"

function build_luvi {
    cd $2
    printf "${yellow}[BUILD] Building luvi . . .${clear}\n"

    # checkout git repo
    printf "$head Cloning luvi repo"
    if [[ ! -d $2/luvi.d ]]; then
        git init $2/luvi.d 1>> $2/logs/git_luvi 2>> $2/logs/git_luvi
        checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvi"; [[ $? == 1 ]] && return 1
        cd $2/luvi.d
        git remote add origin "https://github.com/luvit/luvi" 1>> $2/logs/git_luvi 2>> $2/logs/git_luvi
        checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvi"; [[ $? == 1 ]] && return 1
    fi
    cd $2/luvi.d
    git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master 1>> $2/logs/git_luvi 2>> $2/logs/git_luvi
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvi"; [[ $? == 1 ]] && return 1
    git checkout --progress --force master 1>> $2/logs/git_luvi 2>> $2/logs/git_luvi
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvi"; [[ $? == 1 ]] && return 1
    git submodule sync --recursive 1>> $2/logs/git_luvi 2>> $2/logs/git_luvi
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvi"; [[ $? == 1 ]] && return 1
    git submodule update --init --force --depth=1 --recursive 1>> $2/logs/git_luvi 2>> $2/logs/git_luvi
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvi"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # set version
    printf "$head Parsing version from git"
    latest_ref=$(git rev-parse HEAD)
    latest_ref_short=$(git log -1 --format="%h")
    latest_tagged=$(git rev-list --tags --max-count=1)
    LUVI_VERSION=$(git describe --tags ${latest_tagged})
    if [ "${latest_tagged}" != "${latest_ref}" ]; then
        LUVI_VERSION="${LUVI_VERSION}-dev (git-${latest_ref_short})"
    fi
    printf "${LUVI_VERSION}" >VERSION
    printf "$ok"

    # patching luvi
    printf "$head Patching luvi code"
    cp $1/src/luvi/** $2/luvi.d -rf
    printf "$ok"

    # running cmake
    printf "$head Running cmake"
    cmake -H. -Bbuild\
        -DCMAKE_C_COMPILER="gcc" -DCMAKE_ASM_COMPILER="gcc" -DCMAKE_CXX_COMPILER="g++"\
        -DCMAKE_BUILD_TYPE=Release -DWithSharedLibluv=OFF -DWithOpenSSL=ON -DWithOpenSSLASM=ON\
        -DWithSharedOpenSSL=ON -DWithPCRE=ON -DWithSharedPCRE=OFF -DWithLPEG=ON -DWithSharedLPEG=OFF\
        -DWithZLIB=ON -DWithSharedZLIB=OFF 1>> "$2/logs/cmake_luvi" 2>> "$2/logs/cmake_luvi"
        #Make regular-asm CC=cc
    checkerr $? "\n$headerr CMAKE ERROR!" "$2/logs/cmake_luvi"; [[ $? == 1 ]] && return 1
    cmake --build build 1>> "$2/logs/cmake_luvi" 2>> "$2/logs/cmake_luvi"
    checkerr $? "\n$headerr CMAKE ERROR!" "$2/logs/cmake_luvi"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # make
    printf "$head Compiling"
    make 1>> $2/logs/make_luvi 2>> $2/logs/make_luvi
    checkerr $? "\n$headerr MAKE ERROR!" "$2/logs/make_luvi"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # test luvi
    printf "$head Testing luvi and checking error"
    ./build/luvi -v 1>> $2/logs/luvi 2>> $2/logs/luvi
    checkerr $? "\n$headerr LUVI TEST FAIL!" "$2/logs/luvi"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # copy luvi
    printf "$head Moving luvi bin"
    mv ./build/luvi $2/luvi
    cd $2
    printf "$ok"

    printf "$head Build luvi successfully!\n"

    return 0
}

function build_lit {
    cd $2
    printf "${yellow}[BUILD] Building lit . . .${clear}\n"

    # checkout git repo
    printf "$head Cloning lit repo"
    if [[ ! -d $2/lit.d ]]; then
        git init $2/lit.d 1>> $2/logs/git_lit 2>> $2/logs/git_lit
        checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_lit"; [[ $? == 1 ]] && return 1
        cd $2/lit.d
        git remote add origin "https://github.com/luvit/lit" 1>> $2/logs/git_lit 2>> $2/logs/git_lit
        checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_lit"; [[ $? == 1 ]] && return 1
    fi
    cd $2/lit.d
    git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master 1>> $2/logs/git_lit 2>> $2/logs/git_lit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_lit"; [[ $? == 1 ]] && return 1
    git checkout --progress --force master 1>> $2/logs/git_lit 2>> $2/logs/git_lit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_lit"; [[ $? == 1 ]] && return 1
    git submodule sync --recursive 1>> $2/logs/git_lit 2>> $2/logs/git_lit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_lit"; [[ $? == 1 ]] && return 1
    git submodule update --init --force --depth=1 --recursive 1>> $2/logs/git_lit 2>> $2/logs/git_lit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_lit"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # building lit
    $2/luvi . -- make . ./lit $2/luvi 1>> $2/logs/build_lit 2>> $2/logs/build_lit
    checkerr $? "\n$headerr BUILD ERROR!" "$2/logs/build_lit"; [[ $? == 1 ]] && return 1

    # test lit
    printf "$head Testing lit and checking error"
    ./lit -v 1>> $2/logs/lit 2>> $2/logs/lit
    checkerr $? "\n$headerr LIT TEST FAIL!" "$2/logs/lit"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # copy lit
    printf "$head Moving lit bin"
    mv ./lit $2/lit
    cd $2
    printf "$ok"

    printf "$head Build lit successfully!\n"

    return 0
}

modulelist=(
    "worker" "https://github.com/qwreey75/worker.lua"
    "mutex" "https://github.com/qwreey75/mutex.lua"
    "promise" "https://github.com/qwreey75/promise.lua"
    "xml" "https://github.com/qwreey75/myXml.lua"
    "profiler" "https://github.com/qwreey75/profiler.lua"
    "logger" "https://github.com/qwreey75/logger.lua"
    "random" "https://github.com/qwreey75/random.lua"
    "tester" "https://github.com/qwreey75/tester.lua"
)
function build_luvit {
    cd $2
    printf "${yellow}[BUILD] Building luvit . . .${clear}\n"

    # checkout git repo
    printf "$head Cloning luvit repo"
    if [[ ! -d $2/luvit.d ]]; then
        git init $2/luvit.d 1>> $2/logs/git_luvit 2>> $2/logs/git_luvit
        checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit"; [[ $? == 1 ]] && return 1
        cd $2/luvit.d
        git remote add origin "https://github.com/luvit/luvit" 1>> $2/logs/git_luvit 2>> $2/logs/git_luvit
        checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit"; [[ $? == 1 ]] && return 1
    fi
    cd $2/luvit.d
    git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master 1>> $2/logs/git_luvit 2>> $2/logs/git_luvit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit"; [[ $? == 1 ]] && return 1
    git checkout --progress --force master 1>> $2/logs/git_luvit 2>> $2/logs/git_luvit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit"; [[ $? == 1 ]] && return 1
    git submodule sync --recursive 1>> $2/logs/git_luvit 2>> $2/logs/git_luvit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit"; [[ $? == 1 ]] && return 1
    git submodule update --init --force --depth=1 --recursive 1>> $2/logs/git_luvit 2>> $2/logs/git_luvit
    checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # clone custom module
    printf "$head Cloning custom modules"
    for (( i=1; i<${#modulelist[@]}; i+=2 )); do
        url=${modulelist[$i]}
        name=${modulelist[$i-1]}
        printf "\n - Cloning ${url} into deps/${name}"
        if [[ ! -d deps/${name} ]]; then
            git clone --depth=1 --recursive "${url}" "deps/${name}" 1>> $2/logs/git_luvit_patch 2>> $2/logs/git_luvit_patch
            checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit_patch"; [[ $? == 1 ]] && return 1
        else
            mv $2/gits/module_${name} deps/${name}/.git
            git -C deps/${name} reset 1>> $2/logs/git_luvit_patch 2>> $2/logs/git_luvit_patch
            checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit_patch"; [[ $? == 1 ]] && return 1
            git -C deps/${name} pull 1>> $2/logs/git_luvit_patch 2>> $2/logs/git_luvit_patch
            checkerr $? "\n$headerr FAILED TO CLONE GIT!" "$2/logs/git_luvit_patch"; [[ $? == 1 ]] && return 1
        fi
        mv deps/${name}/.git $2/gits/module_${name}
        rm deps/${name}/LICENSE 1>> /dev/null 2>> /dev/null
        rm deps/${name}/README.md 1>> /dev/null 2>> /dev/null
        rm deps/${name}/.gitignore 1>> /dev/null 2>> /dev/null
        printf " ${yellow}[ OK! ]${clear}"
    done
    printf "\n"

    # patching
    printf "$head Patching luvit code"
    cp $1/src/luvit/** $2/luvit.d -rf
    printf "$ok"


    # building luvit
    $2/lit make . luvit $2/luvi 1>> $2/logs/build_luvit 2>> $2/logs/build_luvit
    checkerr $? "\n$headerr BUILD ERROR!" "$2/logs/build_luvit"; [[ $? == 1 ]] && return 1

    # test luvit
    printf "$head Testing luvit and checking error"
    ./luvit -v 1>> $2/logs/luvit 2>> $2/logs/luvit
    checkerr $? "\n$headerr LUVIT TEST FAIL!" "$2/logs/luvit"; [[ $? == 1 ]] && return 1
    printf "$ok"

    # copy luvit
    printf "$head Moving luvit bin"
    mv ./luvit $2/luvit
    cd $2
    printf "$ok"

    printf "$head Build luvit successfully!\n"

    return 0
}

function build {
    root=$(pwd)
    mkdir -p dist
    mkdir -p dist/gits
    mkdir -p dist/logs
    cd dist
    build=$(pwd)

    # build luvi
    build_luvi ${root} ${build}
    [[ $? == 1 ]] && printf "\n$red ( BUILD STOPPED DUE TO ERROR )\n" && exit 1

    # build lit
    build_lit ${root} ${build}
    [[ $? == 1 ]] && printf "\n$red ( BUILD STOPPED DUE TO ERROR )\n" && exit 1

    # build luvit
    build_luvit ${root} ${build}
    [[ $? == 1 ]] && printf "\n$red ( BUILD STOPPED DUE TO ERROR )\n" && exit 1
}

function install {
    sudo cp dist/luvi /bin/luvi -f
    sudo cp dist/lit /bin/lit -f
    sudo cp dist/luvit /bin/luvit -f
}

function clean {
    printf "${yellow} * Removing dist folder . . .${clean}"
    rm -rf dist
    printf "$ok"
}

function requestSUDO {
    printf "$1"
    sudo whoami >> /dev/null
    printf "$ok"
}

function help {
  echo "-b | --build (default)"
  echo "    Build luvit and modules"
  echo "-c | --clean"
  echo "    Clean up build folder"
  echo "-i | --install"
  echo "    Copy bin files into /bin !REQUIRE SUDO"
  echo "-h | --help"
  echo "    Show this message"
}

option_build="f"
option_clean="f"
option_install="f"
noOption="t"

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--build)
            option_build="t"
            noOption="f"
            shift # past argument
        ;;
        -c|--clean)
            option_clean="t"
            noOption="f"
            shift # past argument
        ;;
        -i|--install)
            install="t"
            noOption="f"
            shift # past argument
        ;;
        -h|--help)
            noOption="f"
            shift # past argument
            help
            exit 1
        ;;
        -*|--*)
            echo "Wrong option $1"
            help
            exit 1
        ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
        ;;
    esac
done

# request sudo for install into /bin
[[ $option_install == "t" ]] && requestSUDO

# cleanup dist
[[ $option_clean == "t" ]] && clean

# build
[[ $option_build == "t" || $noOption == "t" ]] && build

# install
[[ $option_install == "t" ]] && install

exit 0
