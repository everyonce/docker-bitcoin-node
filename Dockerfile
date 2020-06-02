FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install git -y
RUN mkdir -p /opt/bitcoin-source && cd /opt/bitcoin-source
WORKDIR /opt/bitcoin-source
RUN ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime
RUN apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3
RUN apt-get install -y libboost-all-dev wget
# RUN wget http://download.oracle.com/otn/berkeley-db/db-18.1.32.tar.gz
COPY db-18.1.32.tar.gz .
RUN echo 'fa1fe7de9ba91ad472c25d026f931802597c29f28ae951960685cde487c8d654  db-18.1.32.tar.gz' | sha256sum -c
RUN tar -xvf db-18.1.32.tar.gz
WORKDIR /opt/bitcoin-source/db-18.1.32/build_unix
RUN mkdir -p build
RUN BDB_PREFIX=$(pwd)/build
RUN ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX
RUN make install
WORKDIR /opt/bitcoin-source
RUN git clone https://github.com/bitcoin/bitcoin.git
RUN apt-get install -y libminiupnpc-dev
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
RUN apt-get install -y libqrencode-dev
WORKDIR /opt/bitcoin-source/bitcoin
RUN git checkout tags/v0.19.1
RUN ./autogen.sh
RUN ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/" --disable-wallet
RUN make
RUN make install
CMD bitcoind
