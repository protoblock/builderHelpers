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


PREFIX=$HOME/Desktop/fc/leveldb-android/build/

if [ -d $PREFIX ];
	then 
	rm -rf ${PREFIX}
	mkdir -p ${PREFIX}/lib
	mkdir -p ${PREFIX}/include
else 
	mkdir -p ${PREFIX}/lib
	mkdir -p ${PREFIX}/include/leveldb/
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
		tar -xf android-ndk-r11c-darwin-x86.tar
		## clean up
		## rm android-ndk-r11c-darwin-x86.tar
		## rm android-ndk-r11c-darwin-x86.tar.bz2
	fi


NDK_HOME=$HOME/Desktop/ndk/android-ndk-r11c
export ANDROID_NDK_ROOT=$NDK_HOME
export PATH=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/:$PATH
export SYSROOT=$NDK_HOME/platforms/android-24/arch-arm/
export CC="arm-linux-androideabi-gcc --sysroot $SYSROOT"
export CXX="arm-linux-androideabi-g++ --sysroot $SYSROOT"
export CXXSTL=$NDK_HOME/sources/cxx-stl/gnu-libstdc++/4.9/



##########################################
# Download leveldb for android
##########################################

cd /tmp 

if [ -d /tmp/leveldb-android ];
then
    rm -rf /tmp/leveldb-android
fi

git clone https://github.com/protoblock/leveldb-android.git
cd leveldb-android/
git submodule update --recursive
git clone https://github.com/google/leveldb.git
cd /tmp/leveldb-android/leveldb
git reset --hard 803d69203a62faf50f1b77897310a3a1fcae712b
## git pull

mkdir -p /tmp/leveldb-android/leveldb/jni/
cp /tmp/leveldb-android/Android.mk /tmp/leveldb-android/leveldb/jni/
cp /tmp/leveldb-android/Application.mk /tmp/leveldb-android/leveldb/jni/
cd /tmp/leveldb-android/leveldb
$NDK_HOME/ndk-build 



# FIXME. Inspect the library architecture specific information
arm-linux-androideabi-readelf -A /tmp/leveldb-android/leveldb/obj/local/armeabi-v7a/libleveldb.a


for i in ${PREFIX}/lib/armeabi ${PREFIX}/lib/armeabi-v7a ${PREFIX}/lib/x86 ${PREFIX}/lib/x86_64;
do 
	mkdir $i;
done

cp /tmp/leveldb-android/leveldb/obj/local/armeabi/libleveldb.a ${PREFIX}/lib/armeabi/
cp /tmp/leveldb-android/leveldb/obj/local/armeabi-v7a/libleveldb.a ${PREFIX}/lib/armeabi-v7a/
cp /tmp/leveldb-android/leveldb/obj/local/x86/libleveldb.a ${PREFIX}/lib/x86/
cp /tmp/leveldb-android/leveldb/obj/local/x86_64/libleveldb.a ${PREFIX}/lib/x86_64/

cp -r /tmp/leveldb-android/leveldb/libs/ ${PREFIX}/lib
cp -r /tmp/leveldb-android/leveldb/include ${PREFIX}/

