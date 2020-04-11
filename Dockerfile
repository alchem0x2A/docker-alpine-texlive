FROM frolvlad/alpine-glibc:latest

RUN mkdir /tmp/install-tl

WORKDIR /tmp/install-tl

COPY texlive.profile .

# Install TeX Live 2016 with some basic collections
RUN	REMOTE="https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/" &&\
	TAR="install-tl-unx.tar.gz" &&\
	VER=2019 &&\
	apk --no-cache add perl curl tar xz wget&& \
	curl -sSL $REMOTE/$VER/$TAR | tar -xvz --strip-components=1 && \
	TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true \
	perl ./install-tl --profile=texlive.profile && \
	tlmgr install latex-bin luatex xetex\
	# collection-basic \
	# collection-latex \
	# collection-latexrecommended \
	# collection-luatex \
	# collection-mathscience \
	# collection-xetex \                              
	&& \
	apk del perl curl tar xz&& \
	cd && rm -rf /tmp/install-tl

# Install additional packages
# RUN apk --no-cache add perl wget && \
	# tlmgr install bytefield algorithms algorithm2e ec fontawesome && \
	# apk del perl wget && \
	# mkdir /workdir

ENV PATH="/usr/local/texlive/2019/bin/x86_64-linux:${PATH}"

WORKDIR /workdir

VOLUME ["/workdir"]
