FROM ubuntu:22.04 as BUILDER
RUN apt update
RUN apt install wget -y
RUN apt install build-essential -y
RUN apt install perl -y
RUN apt install libz-dev -y
RUN apt remove openssl -y

WORKDIR /openssl-download
RUN wget https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.1.tar.gz --no-check-certificate
RUN tar -xf *.gz && rm *.gz 
WORKDIR /openssl-download/openssl-openssl-3.0.1
RUN ./config --prefix=/usr --openssldir=/etc/ssl 
RUN make
RUN sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
RUN make MANSUFFIX=ssl install
# RUN mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.1
# RUN cp -vfr doc/* /usr/share/doc/openssl-3.0.1

# RUN apt remove build-essential -y
# RUN apt remove perl -y
# RUN apt remove libz-dev -y
# RUN apt remove wget -y
# RUN apt autoremove -y
# RUN rm -rf /openssl-download

FROM ubuntu:22.04
COPY --from=BUILDER /etc/ssl /etc/ssl
COPY --from=BUILDER /usr/include/openssl /usr/include/openssl
COPY --from=BUILDER /usr/lib/engines /usr/lib/engines
COPY --from=BUILDER /usr/share/doc/openssl-3.0.1 /usr/share/doc/openssl-3.0.1

WORKDIR /workspace
RUN useradd -u 1000 openssl
USER openssl
