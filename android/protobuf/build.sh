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



export PATH=/Users/satoshi/Desktop/ndk/android-ndk-r10e:$PATH
##########################################
# Fetch Protobuf 2.6.1 from source.
##########################################

rm -r protobuf-2.5.0
rm *.tar.gz
(
    wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
	tar xf protobuf-2.5.0.tar.gz
)


## copy the mk files to a new jni dir
mkdir -p protobuf-2.5.0/jni/
cp *.mk protobuf-2.5.0/jni/
cp config.h protobuf-2.5.0/src/


## Build
cd protobuf-2.5.0
ndk-build


