# Starting package
FROM python:3.8-slim-buster

LABEL	maintainer "T.Tian <tian.tian@chem.ethz.ch>"

ENV	LANG=C.UTF-8 \
	LC_ALL=C.UTF-8

# Install TeX Live with some basic collections
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
	cm-super \
	dvipng \
	ghostscript \
	latexmk \
	latexdiff \
	make \
	poppler-utils \
	psutils \
	t1utils \
	texlive-base \
	texlive-binaries \
	texlive-font-utils \
	texlive-latex-base \
	texlive-latex-recommended \
	texlive-luatex \
	texlive-pictures \
	texlive-pstricks \
	texlive-xetex || exit 1 &&\
	# Removing documentation packages *after* installing them is kind of hacky,
	# but it only adds some overhead while building the image.
	# Source: https://github.com/aergus/dockerfiles/blob/master/latex/Dockerfile
	apt-get --purge remove -qy .\*-doc$ && \
	# save some space
	rm -rf /var/lib/apt/lists/* && apt-get clean

# update fontutils and lua
RUN     fc-cache -fv || exit 1 &&\
	texhash --verbose ||exit 1  &&\
	luaotfload-tool --update || exit 1

# Install git-latexdiff
RUN	git clone https://gitlab.com/git-latexdiff/git-latexdiff.git /tmp/gld &&\
	cp /tmp/gld/git-latexdiff /usr/local/bin/ &&\
	chmod a+x /usr/local/bin/git-latexdiff &&\
	rm -rf /tmp/gld


WORKDIR /workdir

CMD ["/bin/bash"]

VOLUME ["/workdir"]

ENTRYPOINT ["bash"]
