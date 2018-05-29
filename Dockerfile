## Emacs, make this -*- mode: sh; -*-
 
FROM ubuntu:trusty

## This handle reaches Carl and Dirk
MAINTAINER "Flavio Barros" flaviomargarito@gmail.com

## Set a default user. Available via runtime flag `--user docker` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN apt-get update \ 
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
                ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
        && apt-get update 

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen pt_BR.utf8 \
	&& /usr/sbin/update-locale LANG=pt_BR.UTF-8

## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
## Note 1: we need wget here as the build env is too old to work with libcurl (we think, precise was)
## Note 2: r-cran-docopt is not currently in c2d4u so we install from source
RUN apt-get install -y --no-install-recommends \
                r-cran-littler \
		r-base \
		r-base-dev \
		r-recommended \
                r-cran-stringr \
        && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "wget")' >> /etc/R/Rprofile.site \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds 

ENV LC_ALL pt_BR.UTF-8
ENV LANG pt_BR.UTF-8

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  texlive-full \
  && R -e "source('https://bioconductor.org/biocLite.R')" \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    ggplot2 \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools

## Notes: Above install2.r uses --deps TRUE to get Suggests dependencies as well,
## dplyr and ggplot are already part of tidyverse, but listed explicitly to get their (many) suggested dependencies.
## In addition to the the title 'tidyverse' packages, devtools is included for package development.
## RStudio wants formatR for rmarkdown, even though it's not suggested.
## remotes included for installation from heterogenous sources including git/svn, local, url, and specific cran versions
