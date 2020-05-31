# Starting package
FROM python:3.8-slim-buster

LABEL	maintainer "T.Tian <tian.tian@chem.ethz.ch>"

ENV	LANG=C.UTF-8 \
	LC_ALL=C.UTF-8

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
	# Install the basic tex
	apt-get install -f -qy --no-install-recommends \
	dvipng \
	ghostscript \
	make \
	poppler-utils \
	psutils \
	t1utils || exit 1 &&\
	# Removing documentation packages *after* installing them is kind of hacky,
	# but it only adds some overhead while building the image.
	# Source: https://github.com/aergus/dockerfiles/blob/master/latex/Dockerfile
	# apt-get --purge remove -qy .\*-doc$ && \
	# save some space
	rm -rf /var/lib/apt/lists/* &&\
	apt-get clean

RUN mkdir /TeX

WORKDIR /TeX

COPY	texlive.profile tex-pkgs.txt /TeX/

# Install newest TeXLive
RUN	TAR="http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz" &&\
	wget -nv $TAR && tar -xvf *.tar.gz && \
	mkdir texlive && cd texlive &&\
	TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true \
	../install-tl-*/install-tl --profile=../texlive.profile && cd bin/* &&\
	./tlmgr option repository $REPO &&\
	./tlmgr install latex-bin luatex xetex &&\
	# Install custom packages
        ./tlmgr install $(cat /TeX/tex-pkgs.txt | tr "\n" " ") &&\
	# Clean up insallation
        cd /TeX/ &&\
	rm -rf install-tl-* textlive.profile tex-pkgs.txt

# Install git-latexdiff
RUN	git clone https://gitlab.com/git-latexdiff/git-latexdiff.git /tmp/gld &&\
	cp /tmp/gld/git-latexdiff /usr/local/bin/ &&\
	chmod a+x /usr/local/bin/git-latexdiff &&\
	rm -rf /tmp/gld

# update fontutils and lua
RUN     fc-cache -fv || exit 1 &&\
	texhash --verbose ||exit 1

# Delete possibly unused stuff
RUN	rm -rf /usr/share/icons &&\
	mkdir -p /usr/share/icons &&\
	rm -rf /usr/share/man &&\
	mkdir -p /usr/share/man &&\
	find /usr/share/doc -depth -type f ! -name copyright -delete &&\
	find /usr/share/doc -type f -name "*.pdf" -delete &&\
	find /usr/share/doc -type f -name "*.gz" -delete &&\
	find /usr/share/doc -type f -name "*.tex" -delete &&\
	find /usr/share/doc -type d -empty -delete || true &&\
	mkdir -p /usr/share/doc &&\
	rm -rf /var/cache/apt/archives &&\
	mkdir -p /var/cache/apt/archives &&\
	rm -rf /tmp/* /var/tmp/* &&\
	find /usr/share/ -type f -empty -delete || true &&\
	find /usr/share/ -type d -empty -delete || true &&\
	mkdir -p /usr/share/texmf/source &&\
	mkdir -p /usr/share/texlive/texmf-dist/source	 


ENV PATH="/TeX/texlive/bin/x86_64-linux/:${PATH}"

WORKDIR /workdir

CMD ["/bin/bash"]

VOLUME ["/workdir"]

