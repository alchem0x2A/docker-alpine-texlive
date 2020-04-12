FROM alpine:latest

RUN mkdir /TeX

WORKDIR /TeX

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY texlive.profile  ./


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
	# Clean up insallation
        cd /TeX/ &&\
	rm -rf install-tl-* textlive.profile tex-pkgs.txt &&\
	# Clean up unused packages
	apk del curl tar xz wget

# Second layer for additional packages
COPY    tex-pkgs.txt ./

RUN     cd /TeX/texlive/bin/* &&\
        apk add --no-cache wget tar xz &&\
	# Install custom packages
	./tlmgr install $(cat /TeX/tex-pkgs.txt | tr "\n" " ") &&\
	rm -rf /TeX/tex-pkgs.txt &&\
	apk del wget tar xz

	

ENV PATH="/TeX/texlive/bin/x86_64-linuxmusl:${PATH}"

WORKDIR /workdir

CMD ["/bin/bash"]

VOLUME ["/workdir"]
