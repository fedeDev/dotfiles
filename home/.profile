export EDITOR=vim
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/fede/bin

# Android developer tools
export ANDROID_SDK=/opt/android-sdk
export ANDROID_NDK=/opt/android-ndk
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools:$ANDROID_NDK
# Build system variables
#export NDK_MODULE_PATH=$REDWOOD_ANDROID/share/ndk-modules

# Sanity check for system wide UTF-8
export LC_ALL=en_US.UTF-8
