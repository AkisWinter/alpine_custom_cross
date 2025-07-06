FROM alpine:3.22

RUN apk update && apk add --no-cache \
    build-base \
    cmake \
    ninja \
    python3 \
    py3-pip \
    pipx \
    py3-virtualenv \
    git \
    clang \
    lld \
    llvm \
    mingw-w64-gcc \
    bash

# Install pipx and Conan
RUN pipx install conan

ENV PATH="/root/.local/bin:${PATH}"

RUN conan profile detect

# Profile for Windows Crosscompile
RUN conan profile new win64 --detect && \
    conan profile update settings.os=Windows win64 && \
    conan profile update settings.arch=x86_64 win64 && \
    conan profile update settings.compiler=gcc win64 && \
    conan profile update settings.compiler.version=$(x86_64-w64-mingw32-gcc -dumpversion) win64 && \
    conan profile update settings.compiler.libcxx=libstdc++11 win64

# Profile for Linux Crosscompile
RUN conan profile new linux64 --detect && \
    conan profile update settings.os=Linux linux64 && \
    conan profile update settings.arch=x86_64 linux64 && \
    conan profile update settings.compiler=gcc linux64 && \
    conan profile update settings.compiler.version=$(gcc -dumpversion) linux64 && \
    conan profile update settings.compiler.libcxx=libstdc++11 linux64

# Profile for macOS Crosscompile (with clang)
RUN conan profile new macos --detect && \
    conan profile update settings.os=Macos macos && \
    conan profile update settings.arch=x86_64 macos && \
    conan profile update settings.compiler=clang macos && \
    conan profile update settings.compiler.version=$(clang --version | grep version | awk '{print $3}' | cut -d'.' -f1-2) macos && \
    conan profile update settings.compiler.libcxx=libc++ macos

# displey of the Compiler- and CMake-Versions
RUN echo "--- GCC (Linux) ---" && gcc --version && \
    echo "--- MinGW GCC (Windows) ---" && x86_64-w64-mingw32-gcc --version && \
    echo "--- Clang (macOS) ---" && clang --version && \
    echo "--- CMake ---" && cmake --version

WORKDIR /app

CMD ["bash"]
