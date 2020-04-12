FROM alpine:latest

RUN mkdir /TeX

WORKDIR /TeX

COPY texlive.profile tex-pkgs.txt ./

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Minimal TeXLive installation
# Ideas taken from https://github.com/yihui/tinytex
RUN	REMOTE="http://mirror.ctan.org/systems/texlive/tlnet/" &&\
	TAR="install-tl-unx.tar.gz" &&\
        # Dispensable utils
	apk --no-cache add curl tar xz wget \
	fontconfig perl make bash &&\
	curl -sSL $REMOTE/$TAR | tar -xvz && \
	mkdir texlive &&\
	cd texlive &&\
	TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true \
	../install-tl-*/install-tl --profile=../texlive.profile  &&\
	cd bin/* &&\
	./tlmgr option repository ctan &&\
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
