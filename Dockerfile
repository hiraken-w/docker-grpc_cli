FROM amazonlinux:2.0.20201218.1 as builder
RUN yum -y install epel-release gcc-c++ gflags-develbin git make wget tar \
    && rm -rf /var/cache/yum/* \
    && yum clean all

ARG CMAKE_VERSION="3.6.2"
RUN wget https://cmake.org/files/v3.6/cmake-${CMAKE_VERSION}.tar.gz \
    && tar xvf cmake-${CMAKE_VERSION}.tar.gz \
    && cd cmake-${CMAKE_VERSION} \
    && ./bootstrap && make && make install

ARG GRPC_VERSION="v1.34.1"
RUN git clone -b ${GRPC_VERSION} https://github.com/grpc/grpc \
    && cd grpc \
    && git submodule update --init \
    && mkdir -p cmake/build \
    && cd cmake/build \
    && cmake -DgRPC_BUILD_TESTS=ON ../.. \
    && make grpc_cli

FROM amazonlinux:2.0.20201218.1
COPY --from=builder /grpc/cmake/build/grpc_cli /usr/local/bin/grpc_cli

CMD [ "grpc_cli" ]
