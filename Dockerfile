FROM alpine:latest

RUN mkdir /TeX

WORKDIR /TeX

COPY texlive.profile tex-pkgs.txt ./

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Minimal TeXLive installation
# Ideas taken from https://github.com/yihui/tinytex
RUN	REMOTE="https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/" &&\
	TAR="install-tl-unx.tar.gz" &&\
	VER=2019 &&\
	REPO="https://texlive.info/tlnet-archive/2019/12/31/tlnet/" &&\
        # Dispensable utils
	apk --no-cache add curl tar xz wget \
	fontconfig perl make bash &&\
	curl -sSL $REMOTE/$VER/$TAR | tar -xvz && \
	mkdir texlive &&\
	cd texlive &&\
	TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true \
	../install-tl-*/install-tl --profile=../texlive.profile \
	-repository $REPO && \
	cd bin/* &&\
	./tlmgr option repository $REPO &&\
	./tlmgr install latex-bin luatex xetex &&\
	# Install custom packages
        ./tlmgr install $(cat /TeX/tex-pkgs.txt | tr "\n" " ") &&\
	# Clean up insallation
        cd /TeX/ &&\
	rm -rf install-tl-* textlive.profile tex-pkgs.txt &&\
	# Clean up unused packages
	apk del curl tar xz wget
	

ENV PATH="/TeX/texlive/bin/x86_64-linuxmusl:${PATH}"

WORKDIR /workdir

CMD ["/bin/bash"]

VOLUME ["/workdir"]
