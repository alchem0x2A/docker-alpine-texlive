![](docker_latex_banner.png)

# docker-alpine-texlive
[![](https://images.microbadger.com/badges/version/luciusm/texlive-minimal.svg)](https://microbadger.com/images/luciusm/texlive-minimal "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/luciusm/texlive-minimal.svg)](https://microbadger.com/images/luciusm/texlive-minimal "Get your own image badge on microbadger.com")

 Minimal TeX Live installation Docker image inspired by
 [`ivanpondal/alpine-latex`](https://github.com/dc-uba/docker-alpine-texlive)
 and [`TinyTeX`](https://yihui.org/tinytex/). Based on `Alpine`.
 
 The image is intended to be the base for most of my Docker images for
 text processing. Nevertheless, the image itself should be sufficient
 as a minimal start point to compile `TeX` and `LaTeX` documents for
 scientific writings.




## Quick usage

1.  Ensure you have `Docker` [installed on your system](https://docs.docker.com/get-docker/).
2.  Pull form docker hub:
	```bash
	docker pull luciusm/texlive-minimal
	```
3.  Run `latex`, `pdflatex` etc using the image:
	```bash
	# Test file small2e. Will output small2e.pdf under your current working directory
	docker run --rm -v $(pwd):/workdir:z luciusm/texlive-minimal pdflatex small2e
	```
	


## Customize your TeXLive packages

Customized packages are listed in `tex-pkgs.txt` file. You can simply
build your own docker images by the following steps:
1. Clone the repo
	```bash
	git clone https://github.com/alchem0x2A/texlive-docker-minimal.git
	cd texlive-docker-minimal
	```
2. Edit the 'tex-pkgs.txt'
	```bash
	#For instance you wish to add pxfonts package
	echo "pxfonts" >> tex-pkgs.txt
	```
3. Build Docker image
   ```bash
   docker build . -t YOUR_IMG_NAME:version
   ```

Replacing `luciusm/texlive-minimal` by `YOUR_IMG_NAME:version` and
your image is ready to be used.


  
 
