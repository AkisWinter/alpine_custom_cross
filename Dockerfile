FROM alpine:3.19

RUN apk update && apk add --no-cache \
    build-base \
    cmake \
    ninja \
    python3 \
    py3-pip \
    git \
    clang \
    lld \
    llvm \
    mingw-w64-gcc \
    bash

RUN pip install --upgrade conan

RUN conan profile detect

# Profile für Windows Crosscompile
RUN conan profile new win64 --detect && \
    conan profile update settings.os=Windows win64 && \
    conan profile update settings.arch=x86_64 win64 && \
    conan profile update settings.compiler=gcc win64 && \
    conan profile update settings.compiler.version=$(gcc -dumpversion) win64 && \
    conan profile update settings.compiler.libcxx=libstdc++11 win64

# Profile für Linux Crosscompile
RUN conan profile new linux64 --detect && \
    conan profile update settings.os=Linux linux64 && \
    conan profile update settings.arch=x86_64 linux64 && \
    conan profile update settings.compiler=gcc linux64 && \
    conan profile update settings.compiler.version=$(gcc -dumpversion) linux64 && \
    conan profile update settings.compiler.libcxx=libstdc++11 linux64

# Profile für macOS Crosscompile (mittels clang)
RUN conan profile new macos --detect && \
    conan profile update settings.os=Macos macos && \
    conan profile update settings.arch=x86_64 macos && \
    conan profile update settings.compiler=clang macos && \
    conan profile update settings.compiler.version=$(clang --version | grep version | awk '{print $3}' | cut -d'.' -f1-2) macos && \
    conan profile update settings.compiler.libcxx=libc++ macos

WORKDIR /app

CMD ["bash"]
