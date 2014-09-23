export EDITOR=vim
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/fede/bin

# Android developer tools
export ANDROID_SDK=/opt/android-sdk
export ANDROID_NDK=/opt/android-ndk
PATH=$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools:$ANDROID_NDK

# Sanity check for system wide UTF-8
export LC_ALL=en_US.UTF-8

# Timezone(s)
# export TZ=America/Mexico_City
# export TZ=Europe/Zurich
export TZ=US/Pacific
