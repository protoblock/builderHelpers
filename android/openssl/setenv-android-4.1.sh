#!/bin/sh
# Cross-compile environment for Android on ARMv7
#
# This script assumes the Android NDK and the OpenSSL FIPS
# tarballs have been unpacked in the same directory

#android-sdk-linux/platforms Edit this to wherever you unpacked the NDK

export ANDROID_NDK=$HOME/Desktop/ndk/android-ndk-r8e	
# Edit to reference the incore script (usually in ./util/)
export FIPS_SIG=$PWD/openssl-fips-2.0.2/util/incore
export PATH=$HOME/ndk/android-ndk-r8e/toolchains/arm-linux-androideabi-4.6/prebuilt/darwin-x86_64/bin:$PATH
#
# Shouldn't need to edit anything past here.
#

export MACHINE=armv7l
export RELEASE=2.6.37
export SYSTEM=android
export ARCH=arm
export CROSS_COMPILE="arm-linux-androideabi-"
export ANDROID_DEV="$ANDROID_NDK/platforms/android-14/arch-arm/usr"
export HOSTCC=gcc


