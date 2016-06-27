#!/bin/bash
#
#
# 88""Yb 88""Yb  dP"Yb  888888  dP"Yb  88""Yb 88      dP"Yb   dP""b8 88  dP 
# 88__dP 88__dP dP   Yb   88   dP   Yb 88__dP 88     dP   Yb dP   `" 88odP  
# 88"""  88"Yb  Yb   dP   88   Yb   dP 88""Yb 88  .o Yb   dP Yb      88"Yb  
# 88     88  Yb  YbodP    88    YbodP  88oodP 88ood8  YbodP   YboodP 88  Yb                                                                                                                       '                   
#
# 080 114 111 116 111 098 108 111 099 107
# 01010000 01110010 01101111 01110100 01101111 01000010 01101100 01101111 01100011 01101011
#
# contact@protoblock.com
#
#

printHelp(){
cat << _EOF_
#______________________________________________________________ #
#    ____                                                       #
#    /    )                          /     /               /    #
#---/____/---)__----__--_/_----__---/__---/----__----__---/-__- #
#  /        /   ) /   ) /    /   ) /   ) /   /   ) /   ' /(     #
#_/________/_____(___/_(_ __(___/_(___/_/___(___/_(___ _/___\__ #
#                                                               #
#______________________________________________________________ #
#                                                               #                                                              
Usage 
$0 [options]
 
 Options
    --default                   : Build in default mode
    --debug, -d , -v --verbose  : Print std out in debug mode
    --release, -r               : Print std in release mode
    --help, -h, h , ?           : Print this help
    --default , default         : build with the default options
    --ecdh-no , ecdh-no         : disable ecdh
    --endomorphism-no           : disable endomorphism
    --static-no                 : build as a shared lib
    --asm                       : enable assemble code
    --experimental              : enable experimental builds
    --no-armv7                  : disable armv7 build 
    --no-armv7s                 : disable armv7s build 
    --no-arm64                  : disable arm64 build
    --no-sim                    : disable iphone emulator build 
    --nox86-64                  : disable 64bit osx build
Example: 
    $0 --default
_EOF_
exit 1;
}
THETIME=$(date "+%Y-%m-%d%-H-%M-%S")
BUILDLOG=$(pwd)/build-$THETIME.log
LOGDIR=$(pwd)
DEBUG=false
DEFAULT=true
HELP=false
FIELD=auto
BIGNUM=auto
SCALAR=auto
ENDOMORPHISM=no
STATICPRECOMPUTATION=yes
ASM=no
BUILD=check
ECDH=no
schnorr=no
RECOVERY=no
ENDOMORPHISM=yes
ECDH=yes
#archs
ARMV7=true
ARM7S=true
ARM64=true
SIMULATOR=true
X8664=true


OPTS=$(getopt -o vhns: --long default,verbose,help,ecdh-no,endomorphism-no,static-no,asm,experimental,no-armv7,no-armv7s,no-arm64,no-sim,nox86-64: -n 'parse-options' -- "$@")
if [ $? != 0 ];then 
    printHelp
fi
clear
eval set -- "$OPTS"

while true; 
do
  case "$1" in
    --default)
        if [ $2 == false ];
            then
                DEFAULT=false
            else
                DEFAULT=true
            fi
        shift
        shift
        ;;
    -v | --verbose | -d | --debug ) 
        DEBUG=true;
         shift 
         ;;
    -h | --help )
        HELP=true;
        shift 
        ;;
    --ecdh-no ) 
        ECDH=no;
        shift 
        ;;
    --endomorphism-no ) 
        ENDOMORPHISM=no;
        shift;
        ;;
    --static-no ) 
        STATICPRECOMPUTATION=no;
        shift;
        ;;
    --asm)
        ASM=yes
        shift;
        ;;
    --experimental)
        ECDH=yes;
        shift
        ;;
    --no-armv7)
        ARMV7=false;
        shift
        ;;
    --no-armv7s)
        ARMV7S=false;
        shift
        ;;
    --no-arm64)
        ARM64=false
        shift
        ;;
    --no-sim)
        SIMULATOR=false
        shift
        ;;
    --nox86-64)
        X8664=false
        shift
        ;;
    -- ) 
        shift;
        break 
        ;;
    * )
        break 
        ;;
  esac
done


if [ $HELP == true ];
then
    printHelp
fi

if [ $DEBUG == true ];
then
    set -x;
fi


VERSION=1.0
DARWIN_RELEASE=$(uname -r)
FULLCPU=$(sysctl -n hw.ncpu);
One=1
BuildCores=$(expr $FULLCPU - $One)
CORES=$BuildCores  
PREFIX=$HOME/Desktop/fc/ios/secp256k1-ios
BUILD_PREFIX=$PREFIX/build
mkdir -p $BUILD_PREFIX
OSX_SDK=$(xcodebuild -showsdks \
    | grep macosx | sort | tail -n 1 | awk '{print substr($NF, 7)}'
    )

IOS_SDK=$(xcodebuild -showsdks \
    | grep iphoneos | sort | tail -n 1 | awk '{print substr($NF, 9)}'
    )

XCODEDIR=$(xcode-select --print-path)

MACOSX_PLATFORM=${XCODEDIR}/Platforms/MacOSX.platform
MACOSX_SYSROOT=${MACOSX_PLATFORM}/Developer/MacOSX${OSX_SDK}.sdk

IPHONEOS_PLATFORM=${XCODEDIR}/Platforms/iPhoneOS.platform
IPHONEOS_SYSROOT=${IPHONEOS_PLATFORM}/Developer/SDKs/iPhoneOS${IOS_SDK}.sdk

IPHONESIMULATOR_PLATFORM=${XCODEDIR}/Platforms/iPhoneSimulator.platform
IPHONESIMULATOR_SYSROOT=${IPHONESIMULATOR_PLATFORM}/Developer/SDKs/iPhoneSimulator${IOS_SDK}.sdk

CC=clang
CFLAGS="-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions"
CXX=clang
CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=libc++"
LDFLAGS="-stdlib=libc++"
LIBS="-lc++ -lc++abi"




# function _spinner() {
#     # $1 start/stop
#     # on start: $2 display message
#     # on stop : $2 process exit status
#     # $3 spinner function pid (supplied from stop_spinner)

#     local on_success="DONE"
#     local on_fail="FAIL"

#     case $1 in
#         start)
#             # calculate the column where spinner and status msg will be displayed
#             let column=$(tput cols)-${#2}-8
#             # display message and position the cursor in $column column
#             echo -ne ${2}
#             printf "%${column}s" 

#             # start spinner
#             i=1
#             sp='\|/-'
#             delay=${SPINNER_DELAY:-0.15}

#             while :
#             do
#                 printf "\b${sp:i++%${#sp}:1}" 
#                 sleep $delay
#             done
#             ;;
#         stop)
#             if [[ -z ${3} ]]; then
#                 echo "spinner is not running.." >> $BUILDLOG 2>&1
#                 exit 1
#             fi

#             kill $3 > /dev/null 2>&1

#             # inform the user uppon success or failure
#             echo -en "\b["
#             if [[ $2 -eq 0 ]]; then
#                 echo -en "${green}${on_success}${nc} " >> $BUILDLOG 2>&1
#             else
#                 echo -en "${red}${on_fail}${nc}" >> $BUILDLOG 2>&1
#             fi
#             echo -e "]"
#             ;;
#         *)
#             echo "invalid argument, try {start/stop}" >> $BUILDLOG 2>&1
#             exit 1
#             ;;
#     esac
# }

# function start_spinner {
#     # $1 : msg to display
#     _spinner "start" "${1}" &
#     # set global spinner pid
#     _sp_pid=$!
#     disown
# }

# function stop_spinner {
#     # $1 : command exit status
#     _spinner "stop" $1 $_sp_pid
#     unset _sp_pid
# }


####################################
# Cleanup any earlier build attempts
####################################
function cleanup(){
    echo "------------------ Cleanup --------------------" >> $BUILDLOG 2>&1
    cd $BUILD_PREFIX
    if [ -d $BUILD_PREFIX ]
    then
    rm -rf $BUILD_PREFIX
    fi
    mkdir -p $BUILD_PREFIX
    rm $LOGDIR/*.log
}



function runAutogen(){
    # cd $BUILD_PREFIX/secp256k1-$1
    sh autogen.sh >> $BUILDLOG 2>&1 
}

##########################################
# Fetch secp256k1 from github.
##########################################

function cloneBranch(){
    echo "------------- Building secp256k1 for $1 ---------------"
    cd $BUILD_PREFIX
    git clone https://github.com/bitcoin-core/secp256k1.git secp256k1-$1 >> $BUILDLOG 2>&1
    cd $BUILD_PREFIX/secp256k1-$1
    ## FIXME add commit for git for certian times
    # git checkout ${VERSION}
    runAutogen
}

#####################
# x86_64 for Mac OS X
#####################

function buildOsx(){
    cloneBranch x86
    echo "------------------ Mac OS X --------------------" >> $BUILDLOG 2>&1
    # cd $BUILD_PREFIX/secp256k1
    # make clean
    ./configure \
        --disable-shared \
        --enable-static \
        --prefix=${PREFIX}/x86_64 \
        --exec-prefix=${PREFIX}/x86_64 \
        "CC=${CC}" "CFLAGS=${CFLAGS} \
        -arch x86_64" "CXX=${CXX}" \
        "CXXFLAGS=${CXXFLAGS} \
        -arch x86_64" \
        "LDFLAGS=${LDFLAGS}" \
        "LIBS=${LIBS}" \
        --enable-experimental=$ECDH \
        --enable-endomorphism=$ENDOMORPHISM \
        --with-field=$FIELD \
        --with-bignum=$BIGNUM \
        --with-scalar=$SCALAR \
        --enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
        --enable-module-ecdh=$ECDH \
        --enable-module-schnorr=$SCHNORR \
        --enable-module-recovery=$RECOVERY >> $BUILDLOG 2>&1
    make -j $CORES  >> $BUILDLOG 2>&1
    make install >> $BUILDLOG 2>&1
    
}

###########################
# i386 for iPhone Simulator
###########################

function buildSimulator(){
    echo "------------------ iPhone Simulator --------------------" >> $BUILDLOG 2>&1
    cloneBranch sim
    ./configure \
        --build=x86_64-apple-darwin${DARWIN_RELEASE} \
        --host=i386-apple-darwin${DARWIN_RELEASE} \
        --disable-shared \
        --enable-static \
        --prefix=${PREFIX}/i386 \
        --exec-prefix=${PREFIX}/i386 \
        "CC=${CC}" "CFLAGS=${CFLAGS} \
        -miphoneos-version-min=${IOS_SDK} \
        -arch i386 \
        -isysroot ${IPHONESIMULATOR_SYSROOT}" \
        "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} \
        -arch i386 \
        -isysroot ${IPHONESIMULATOR_SYSROOT}" \
        LDFLAGS="-arch i386 -miphoneos-version-min=${IOS_SDK} \
        ${LDFLAGS}" \
        "LIBS=${LIBS}" \
        --enable-experimental=$ECDH \
        --enable-endomorphism=$ENDOMORPHISM \
        --with-field=$FIELD \
        --with-bignum=$BIGNUM \
        --with-scalar=$SCALAR \
        --enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
        --enable-module-ecdh=$ECDH \
        --enable-module-schnorr=$SCHNORR \
        --enable-module-recovery=$RECOVERY >> $BUILDLOG 2>&1
    make -j $CORES  >> $BUILDLOG 2>&1
    make install >> $BUILDLOG 2>&1
    
}

##################
# armv7 for iPhone
##################

function buildArmv7(){
    echo "------------------ armv7 iPhone --------------------" >> $BUILDLOG 2>&1
    cloneBranch armv7
    ./configure \
        --build=x86_64-apple-darwin${DARWIN_RELEASE} \
        --host=armv7-apple-darwin${DARWIN_RELEASE} \
        --disable-shared \
        --enable-static \
        --prefix=${PREFIX}/armv7 \
        --exec-prefix=${PREFIX}/armv7 \
        "CC=${CC}" "CFLAGS=${CFLAGS} \
        -miphoneos-version-min=${IOS_SDK} \
        -arch armv7 -isysroot ${IPHONEOS_SYSROOT}" \
        "CXX=${CXX}" \
        "CXXFLAGS=${CXXFLAGS} \
        -arch armv7 \
        -isysroot ${IPHONEOS_SYSROOT}" \
        LDFLAGS="-arch armv7 -miphoneos-version-min=${IOS_SDK} \
        ${LDFLAGS}" \
        "LIBS=${LIBS}" \
        --enable-experimental=$ECDH \
        --enable-endomorphism=$ENDOMORPHISM \
        --with-field=$FIELD \
        --with-bignum=$BIGNUM \
        --with-scalar=$SCALAR \
        --enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
        --enable-module-ecdh=$ECDH \
        --enable-module-schnorr=$SCHNORR \
        --enable-module-recovery=$RECOVERY >> $BUILDLOG 2>&1
    make -j $CORES  >> $BUILDLOG 2>&1
    make install >> $BUILDLOG 2>&1
    
}

###################
# armv7s for iPhone
###################

function buildArmv7s(){
    echo "------------------ armv7s iPhone --------------------" >> $BUILDLOG 2>&1
    cloneBranch armv7s
    ./configure \
        --build=x86_64-apple-darwin${DARWIN_RELEASE} \
        --host=armv7s-apple-darwin${DARWIN_RELEASE} \
        --disable-shared \
        --enable-static \
        --prefix=${PREFIX}/armv7s \
        --exec-prefix=${PREFIX}/armv7s \
        "CC=${CC}" "CFLAGS=${CFLAGS} \
        -miphoneos-version-min=${IOS_SDK} \
        -arch armv7s \
        -isysroot ${IPHONEOS_SYSROOT}" \
        "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} \
        -arch armv7s \
        -isysroot ${IPHONEOS_SYSROOT}" \
        LDFLAGS="-arch armv7s \
        -miphoneos-version-min=${IOS_SDK} \
        ${LDFLAGS}" \
        "LIBS=${LIBS}" \
        --enable-experimental=$ECDH \
        --enable-endomorphism=$ENDOMORPHISM \
        --with-field=$FIELD \
        --with-bignum=$BIGNUM \
        --with-scalar=$SCALAR \
        --enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
        --enable-module-ecdh=$ECDH \
        --enable-module-schnorr=$SCHNORR \
        --enable-module-recovery=$RECOVERY >> $BUILDLOG 2>&1
    make -j $CORES  >> $BUILDLOG 2>&1
    make install >> $BUILDLOG 2>&1
    
}

##################
# arm64 for iPhone
##################

function buildArm64(){
echo "------------------ arm64 iPhone --------------------" >> $BUILDLOG 2>&1
    cloneBranch arm64
    ./configure \
        --build=x86_64-apple-darwin${DARWIN_RELEASE} \
        --host=arm \
        --disable-shared \
        --enable-static \
        --prefix=${PREFIX}/arm64 \
        --exec-prefix=${PREFIX}/arm64 \
        "CC=${CC}" "CFLAGS=${CFLAGS} \
        -miphoneos-version-min=${IOS_SDK} \
        -arch arm64 -isysroot ${IPHONEOS_SYSROOT}" \
        "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} \
        -arch arm64 \
        -isysroot ${IPHONEOS_SYSROOT}" \
        LDFLAGS="-arch arm64 \
        -miphoneos-version-min=${IOS_SDK} \
        ${LDFLAGS}" \
        "LIBS=${LIBS}" \
        --enable-experimental=$ECDH \
        --enable-endomorphism=$ENDOMORPHISM \
        --with-field=$FIELD \
        --with-bignum=$BIGNUM \
        --with-scalar=$SCALAR \
        --enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
        --enable-module-ecdh=$ECDH \
        --enable-module-schnorr=$SCHNORR \
        --enable-module-recovery=$RECOVERY >> $BUILDLOG 2>&1
    make -j $CORES  >> $BUILDLOG 2>&1
    make install >> $BUILDLOG 2>&1
    
}



############################
# Create Universal Libraries
############################
# function createFatCat(){
#     echo "------------------ fatcat the libs --------------------" >> $BUILDLOG 2>&1
#     cd $BUILD_PREFIX/secp256k1
#     mkdir $BUILD_PREFIX/secp256k1/universal
#     lipo x86_64/lib/libprotobuf.a \
#         arm64/lib/libsecp2561k1.a \
#         armv7s/lib/libsecp2561k1.a \
#         armv7/lib/libsecp2561k1.a \
#         i386/lib/libsecp2561k1.a \
#         -create -output universal/libsecp2561k1.a
# }



########################
# Finalize the packaging
########################

# function packaging(){
#     echo "------------------ Packaging --------------------" >> $BUILDLOG 2>&1
#     cd $PREFIX
#     # mkdir -p $PREFIX/bin
#     for i in armv7s arm64 armv7 i386;
#     do 
#         mkdir -p $PREFIX/$i/lib
#         mkdir -p $PREFIX/$i/include
#     done


#     ##FIXME make pkg-config stuff


#     mkdir -p $PREFIX/lib
#     mkdir -p $PREFIX/include
#     cp -r platform/x86_64/lib/* lib
#     cp -r platform/universal/* lib
#     cp -r $BUILD_PREFIX/secp256k1/include $PREFIX/include/

# }

cleanup

if [ $X8664 == true ];
then 
    buildOsx 
fi 

if [ $SIMULATOR == true ];
then
    buildSimulator
fi

if [ $ARMV7 == true ];
then    
    buildArmv7
fi

if [ $ARM7S == true ];
then    
    buildArmv7s
fi

if [ $ARM64 == true ];
then
    buildArm64
fi

# createFatCat
echo "done"