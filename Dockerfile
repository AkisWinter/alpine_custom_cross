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
RUN cp ~/.conan2/profiles/default ~/.conan2/profiles/win64 && \
    sed -i 's/os=.*/os=Windows/' ~/.conan2/profiles/win64 && \
    sed -i 's/arch=.*/arch=x86_64/' ~/.conan2/profiles/win64 && \
    sed -i 's/compiler=.*/compiler=gcc/' ~/.conan2/profiles/win64 && \
    sed -i 's/compiler.version=.*/compiler.version='$(x86_64-w64-mingw32-gcc -dumpversion | cut -d. -f1)'/' ~/.conan2/profiles/win64 && \
    sed -i 's/compiler.libcxx=.*/compiler.libcxx=libstdc++11/' ~/.conan2/profiles/win64

# Profile for Linux Crosscompile
RUN cp ~/.conan2/profiles/default ~/.conan2/profiles/linux64 && \
    sed -i 's/os=.*/os=Linux/' ~/.conan2/profiles/linux64 && \
    sed -i 's/arch=.*/arch=x86_64/' ~/.conan2/profiles/linux64 && \
    sed -i 's/compiler=.*/compiler=gcc/' ~/.conan2/profiles/linux64 && \
    sed -i 's/compiler.version=.*/compiler.version='$(gcc -dumpversion | cut -d. -f1)'/' ~/.conan2/profiles/linux64 && \
    sed -i 's/compiler.libcxx=.*/compiler.libcxx=libstdc++11/' ~/.conan2/profiles/linux64

# Profile for macOS Crosscompile (with clang)
RUN cp ~/.conan2/profiles/default ~/.conan2/profiles/macos && \
    sed -i 's/os=.*/os=Macos/' ~/.conan2/profiles/macos && \
    sed -i 's/arch=.*/arch=x86_64/' ~/.conan2/profiles/macos && \
    sed -i 's/compiler=.*/compiler=clang/' ~/.conan2/profiles/macos && \
    sed -i 's/compiler.version=.*/compiler.version='$(clang --version | grep version | awk '{print $3}' | cut -d'.' -f1)'/' ~/.conan2/profiles/macos && \
    sed -i 's/compiler.libcxx=.*/compiler.libcxx=libc++/' ~/.conan2/profiles/macos

# Display of the Compiler- and CMake-Versions
RUN echo "--- GCC (Linux) ---" && gcc --version && \
    echo "--- MinGW GCC (Windows) ---" && x86_64-w64-mingw32-gcc --version && \
    echo "--- Clang (macOS) ---" && clang --version && \
    echo "--- CMake ---" && cmake --version

WORKDIR /app

CMD ["bash"]
