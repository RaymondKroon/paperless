#FROM multiarch/ubuntu-core:amd64-xenial
FROM ubuntu

RUN apt-get update && apt-get install -yqq --no-install-recommends \
		libsane sane sane-utils libsane-extras && \
	rm -rf /var/lib/apt/lists/*

ADD 79-scanner.rules /etc/udev/rules.d

RUN mkdir -p /usr/share/sane/epjitsu/
ADD drivers/1300i_0D12.nal /usr/share/sane/epjitsu

RUN echo "sane-port 65666/tcp saned # SANE network scanner daemon"  >> /etc/services