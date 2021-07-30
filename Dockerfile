FROM wordpress:latest

ARG GIT_VERSION=2.30.2
ARG NVIM_VERSION=0.5.0
ARG ARCH_TYPE

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y \
 #
 # locale
 && apt-get install -y locales git tig \
 && sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=ja_JP.UTF-8 \
 #
 # timezone
 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# git
RUN apt-get install -y \
      gettext \
      libcurl4-gnutls-dev \
      libexpat1-dev \
      libghc-zlib-dev \
      libssl-dev \
      make \
      wget \
 && cd /tmp \
 && wget -O git.tar.gz https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz \
 && tar -xzf git.tar.gz \
 && cd git-* \
 && make prefix=/usr/local all \
 && make prefix=/usr/local install \
 && cd .. && rm -Rf git*

# neovim
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
 && apt-get update && apt-get install -y \
      autoconf \
      automake \
      cmake \
      g++ \
      gettext \
      libncurses5-dev \
      libtool \
      libtool-bin \
      libunibilium-dev \
      libunibilium4 \
      ninja-build \
      nodejs \
      pkg-config \
      python-pip \
      python3-pip \
      software-properties-common \
      sudo \
      unzip \
      wget \
 && pip install setuptools \
 && pip install --upgrade pynvim \
 && pip3 install setuptools \
 && pip3 install --upgrade pynvim \
 && npm install -g neovim \
 && cd /tmp \
 && wget -O neovim.tar.gz "https://github.com/neovim/neovim/archive/v${NVIM_VERSION}.tar.gz" \
 && tar xvfz neovim.tar.gz \
 && cd neovim-* \
 && make CMAKE_BUILD_TYPE=RelWithDebInfo \
 && make install \
 && cd .. && rm -Rf neovim* 

# tools
RUN apt-get install -y direnv fasd fzf silversearcher-ag tig zsh \
 && git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions/ \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/local/share/zsh-syntax-highlighting \
 && cd /tmp \
 #
 # starship
 && curl -fsSL https://starship.rs/install.sh -o /tmp/install.sh \
 && sh /tmp/install.sh -y  \
 && rm /tmp/install.sh \
 #
 # lsd
 && wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_${ARCH_TYPE}.deb \
 && dpkg -i lsd_0.20.1_${ARCH_TYPE}.deb \
 && rm -f lsd* 

# php
RUN pecl install xdebug-2.8.1 \
 && docker-php-ext-enable xdebug

# dotfiles
RUN git clone https://github.com/jozuo/dotfiles.git ${HOME}/dotfiles/ \
 && bash ${HOME}/dotfiles/bin/install.sh

# env
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP.UTF-8

# volume
RUN mkdir -p ${HOME}/.vim/ \
 && mkdir -p ${HOME}/dotfiles/.config/coc/ 
VOLUME ["${HOME}/.vim/", "${HOME}/dotfiles/.config/coc/"]
