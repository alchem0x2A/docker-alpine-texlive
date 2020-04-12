FROM alpine:latest

RUN mkdir /TeX

WORKDIR /TeX

COPY texlive.profile pkgs-custom.txt ./

# Minimal TeXLive installation
# Ideas taken from https://github.com/yihui/tinytex
RUN	REMOTE="https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/" &&\
	TAR="install-tl-unx.tar.gz" &&\
	VER=2019 &&\
	REPO="https://texlive.info/tlnet-archive/2019/12/31/tlnet/" &&\
	apk --no-cache add perl curl tar xz wget fontconfig &&\
	curl -sSL $REMOTE/$VER/$TAR | tar -xvz && \
	mkdir texlive &&\
	cd texlive &&\
	TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true \
	../install-tl-*/install-tl --profile=../texlive.profile \
	-repository $REPO && \
	cd bin/* &&\
	./tlmgr option repository $REPO &&\
	./tlmgr install latex-bin luatex xetex &&\
	# Clean up insallation
	rm -rf /TeX/install-tl-* textlive.profile pkgs-custom.txt &&\
	# Clean up unused packages
	apk del perl curl tar xz wget
	

ENV PATH="/TeX/texlive/bin/x86_64-linuxmusl:${PATH}"

WORKDIR /workdir

VOLUME ["/workdir"]
