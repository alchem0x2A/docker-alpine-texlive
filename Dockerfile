# Starting package
# FROM python:3.8-slim-buster
FROM debian:latest as build

LABEL	maintainer "T.Tian <tian.tian@chem.ethz.ch>"

ENV	LANG=C.UTF-8 \
	LC_ALL=C.UTF-8

RUN mkdir /TeX

WORKDIR /TeX

COPY	texlive.profile tex-pkgs.txt /TeX/

# Install some basic collections
RUN	apt-get update -qy &&\
	# Install necessary certificate?
	apt-get install -f -qy --no-install-recommends apt-utils || exit 1 &&\
	# get and update certificates, to hopefully resolve mscorefonts error
	apt-get install -f -qy --no-install-recommends ca-certificates || exit 1  &&\
	update-ca-certificates &&\
	# Basic utils
	apt-get install -f -y --no-install-recommends \
	fontconfig \
	git \
	wget \
	xz-utils || exit 1  &&\
	rm -rf /var/lib/apt/lists/* &&\
	apt-get clean

# Install newest TeXLive
RUN	TAR="http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz" &&\
	wget -nv $TAR && tar -xvf *.tar.gz && \
	mkdir texlive && cd texlive &&\
	TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true \
	../install-tl-*/install-tl --profile=../texlive.profile && cd bin/* &&\
	./tlmgr install latex-bin luatex xetex latexmk latexdiff &&\
	# Install custom packages
        ./tlmgr install $(cat /TeX/tex-pkgs.txt | tr "\n" " ") &&\
	# Clean up insallation
        cd /TeX/ &&\
	rm -rf install-tl-* textlive.profile tex-pkgs.txt

# where to find the bin
# ENV PATH="/TeX/texlive/bin/x86_64-linux/:${PATH}"

# Install git-latexdiff
RUN	git clone https://gitlab.com/git-latexdiff/git-latexdiff.git /tmp/gld &&\
	cp /tmp/gld/git-latexdiff /TeX/texlive/bin/x86_64-linux/ &&\
	chmod a+x /TeX/texlive/bin/x86_64-linux/git-latexdiff &&\
	rm -rf /tmp/gld

# update fontutils and lua
# RUN     fc-cache -fv || exit 1 &&\
	# texhash --verbose ||exit 1

FROM	debian:latest

COPY	--from=build /TeX /TeX

ENV	PATH="/TeX/texlive/bin/x86_64-linux/:${PATH}"

# Delete possibly unused stuff

# RUN	fc-cache -fv || exit 1 &&\
	# texhash --verbose ||exit 1

WORKDIR /workdir

CMD ["/bin/bash"]

VOLUME ["/workdir"]

