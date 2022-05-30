FROM ubuntu:latest

WORKDIR /mo436

ENV TZ=America/Sao_Paulo
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone

RUN apt-get -y update && apt-get install -y clang clang-tools \
    cmake graphviz libpng-dev libprotobuf-dev llvm \
    llvm-dev ninja-build protobuf-compiler wget libgoogle-glog-dev \
    libboost-all-dev libdouble-conversion-dev libevent-dev libssl-dev \
    libgflags-dev libjemalloc-dev libpthread-stubs0-dev liblz4-dev libzstd-dev \
    libbz2-dev libsodium-dev libfmt-dev \
    pkg-config apt-utils libfmt-dev libc6-dbg gdb valgrind \
    git git-lfs doxygen zsh

RUN update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-10/bin/clang 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-10/bin/clang++ 100 && \
    update-alternatives --install /usr/bin/cc  cc  /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 30

ENV GLOWBIN="/mo436/glow/build/bin"

RUN git clone https://github.com/fmtlib/fmt.git && \
    cmake -S fmt -B fmt/build && \
    cmake --build fmt/build && \
    cmake --install fmt/build && \
    rm -rf fmt


RUN echo "export PS1='%m %F{red}%/%f $ '" >> /root/.zshrc
RUN echo "export GLOWBIN='/mo436/glow/build/bin'" >> /root/.zshrc
RUN echo "export PATH=$PATH:$GLOWBIN" >> /root/.zshrc

RUN apt install -y libopenblas-dev

#RUN cd /mo436 && \
#    cmake -S glow -B glow/build -G Ninja -DCMAKE_BUILD_TYPE=Release && \
#    cmake --build glow/build


