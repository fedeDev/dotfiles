export EDITOR=vim
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/fede/bin

# Android developer tools
export ANDROID_SDK=/opt/android-sdk
export ANDROID_NDK=/opt/android-ndk-r10b
PATH=$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools:$ANDROID_NDK

# Sanity check for system wide UTF-8
export LC_ALL=en_US.UTF-8

# Timezone(s)
# export TZ=America/Mexico_City
export TZ=Europe/Zurich
# export TZ=US/Pacific

# CCACHE
export CCACHE_PATH="/usr/bin"

export PATH="$PATH:/home/fede/code/cuda/android-sdk-linux/platform-tools"

export PATH="$PATH:/home/fede/code/cuda/android-sdk-linux/build-tools"

export PATH="$PATH:/home/fede/code/cuda/android-sdk-linux/tools"

export CUDA_TOOLKIT_ROOT="/home/fede/NVPACK/cuda-6.0"

export PATH="$PATH:/home/fede/NVPACK/cuda-6.0/bin"

export NVPACK_ROOT="/home/fede/NVPACK"
