
export EDITOR=vim
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/fede/bin:/usr/local/

# Android developer tools
export ANDROID_SDK=/opt/android-sdk
export ANDROID_NDK=/opt/android-ndk
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools:$ANDROID_NDK

# Redwood root directory
export REDWOOD=$HOME/data/Redwood
# Per-platform directories for prebuilt software
export REDWOOD_LINUX=$REDWOOD/Linux
export REDWOOD_ANDROID=$REDWOOD/Android
export REDWOOD_PEANUT=$REDWOOD/Peanut

# Build system variables
export NDK_MODULE_PATH=$REDWOOD_ANDROID/share/ndk-modules

export LD_LIBRARY_PATH=$REDWOOD_LINUX/lib:$LD_LIBRARY_PATH
export PATH=$REDWOOD_LINUX/bin:$PATH
export REDWOOD_LINUX
