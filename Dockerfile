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
    bash \
    libc++ \
    libc++abi \
    libc++-dev \
    libc++abi-dev

# Install pipx and Conan
RUN pipx install conan

ENV PATH="/root/.local/bin:${PATH}"

RUN conan profile detect

# Display of the Compiler- and CMake-Versions
RUN echo "--- GCC (Linux) ---" && gcc --version && \
    echo "--- MinGW GCC (Windows) ---" && x86_64-w64-mingw32-gcc --version && \
    echo "--- Clang (macOS) ---" && clang --version && \
    echo "--- CMake ---" && cmake --version

WORKDIR /app

CMD ["bash"]
