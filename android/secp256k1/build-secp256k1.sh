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
#								#
#______________________________________________________________ #
#								#                                                              
Usage 
$0 [option] version
 
 Options
		[ --debug, -d , -v --verbose ]
			Print std out in debug mode
 		
 		[ --release, -r ]
			Print std in release mode

		[ --help, -h, h , ? ]
			Print this help
 
Eample: 
	$0 -r
_EOF_
exit 1;
}



if [ $# -lt 1 ]; 
then
	printHelp;
fi

DEBUG=0;
case "$1" in
    -d|--debug|d|v|--verbose)
    	DEBUG=1
    ;;
    -r|--release)
		DEBUG=0
	;;
        -h|--help|h|?)
    	printHelp;
    ;;
    *)
		printHelp
	;;
esac


 
# FIXME debug
if [ $DEBUG == 1 ];
 then
 		set -x
fi 

BUILD_PREFIX=$HOME/Desktop/fc/android/secp256k1
PREFIX=$HOME/Desktop/fc/android/extreanal
FULLCPU=$(sysctl -n hw.ncpu);
One=1
BuildCores=$(expr $FULLCPU - $One)


if [ -d $BUILD_PREFIX ];
	then 
	rm -rf $BUILD_PREFIX
	mkdir -p $BUILD_PREFIX
else 
	mkdir -p $BUILD_PREFIX
fi 

if [ -d $HOME/Desktop/ndk/android-ndk-r11c ];
	then
		echo "Already have the right version of ndk";
	else
		echo "Downloading the correct NDK toolkit";
		mkdir -p $HOME/Desktop/ndk/
		cd $HOME/Desktop/ndk/

		wget http://dl.google.com/android/repository/android-ndk-r11c-darwin-x86_64.zip
		bzip2 -d android-ndk-r11c-darwin-x86.tar.bz2
		if [ $DEBUG == 1 ];
		then
			tar -xvf android-ndk-r11c-darwin-x86.tar
		else
			tar -xf android-ndk-r11c-darwin-x86.tar
		fi
		## clean up
		## rm android-ndk-r11c-darwin-x86.tar
		## rm android-ndk-r11c-darwin-x86.tar.bz2
	fi



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
EXPERIMENTAL=no

## ANDROID options 
NDK_HOME=$HOME/Desktop/ndk/android-ndk-r11c
export ANDROID_NDK_ROOT=$NDK_HOME
export PATH=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/:$PATH
export SYSROOT=$NDK_HOME/platforms/android-24/arch-arm/
export CC="arm-linux-androideabi-gcc --sysroot $SYSROOT"
export CXX="arm-linux-androideabi-g++ --sysroot $SYSROOT"
export CXXSTL=$NDK_HOME/sources/cxx-stl/gnu-libstdc++/4.9/
 
##########################################
# Download 
##########################################

cd $BUILD_PREFIX
if [ -d $BUILD_PREFIX/secp256k1 ];
then
	rm -rf $BUILD_PREFIX/secp256k1
fi


git clone https://github.com/bitcoin-core/secp256k1.git secp256k1
cd $BUILD_PREFIX/secp256k1


./autogen.sh 
./configure \
		--host=arm-linux-androideabi \
		--with-sysroot=$SYSROOT \
		--enable-cross-compile \
		--disable-shared \
		CFLAGS="-march=armv7-a" \
		CXXFLAGS="-march=armv7-a -I$CXXSTL/include -I$CXXSTL/libs/armeabi-v7a/include" \
		--enable-experimental=$EXPERIMENTAL \
		--enable-endomorphism=$ENDOMORPHISM \
		--with-field=$FIELD \
		--with-bignum=$BIGNUM \
		--with-scalar=$SCALAR \
		--enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
		--enable-module-ecdh=$ECDH \
		--enable-module-schnorr=$SCHNORR \
		--enable-module-recovery=$RECOVERY \
		$EXTRAFLAGS
 

# 4. Build
make -j $BuildCores

 
# # 5. Inspect the library architecture specific information
# arm-linux-androideabi-readelf -A 

