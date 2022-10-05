#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
UNSET="\e[0m"

export PS1=

set -eo pipefail

if [ -e ~/.zshrc ]; then
    source ~/.zshrc
fi

if [ -z $1 ]; then
    printf "${RED}missing required argument${UNSET}\n"
    exit 1
fi

TASK=$1

set -eou pipefail

mkdir -p $HOME/opt/bin

try_curl() {
    url=$1; dest=$2; command -v curl > /dev/null && curl -fL $url > $dest
}
try_wget() {
    url=$1; dest=$2; command -v wget > /dev/null && wget -O- $url > $dest
}

download() {
    echo "downloading $1 to $2"
    [[ -e $(dirname $2) ]] || mkdir -p $(dirname $2)
    if ! (try_curl $1 $2 || try_wget $1 $2); then
        echo "failed to download $1"
    fi
}

check_opt_bin_in_path() {
    if ! echo $PATH | grep -q "$HOME/opt/bin"; then
        printf "${YELLOW}add $HOME/opt/bin to \$PATH${UNSET}\n"
    fi
}

check_conda_env() {
    check_conda_install
    if conda env list --json | grep -q "/$1\",\$"; then
        printf "${RED}conda env $1 already exists${UNSET}\n"
        return 1
    fi
}

CONDA_LOCATION=
check_conda_install() {
    if command -v conda > /dev/null; then
        CONDA_LOCATION=$(conda info --base)

        # enable "conda activate" without "conda init"
        eval "$(conda shell.bash hook)"
    else
        printf "${RED}cannot find conda installation${UNSET}\n"
        exit 1
    fi
}

#  $1 -- environment name to create
#  $2 -- conda package to install
#  $3 -- executable to symlink to ~/opt/bin
install_env_and_symlink () {
    ENVNAME=$1
    CONDAPKG=$2
    EXECUTABLE=$3

    check_conda_env $ENVNAME
    conda create -y -n $ENVNAME $CONDAPKG
    ln -sf "$CONDA_LOCATION/envs/$ENVNAME/bin/$EXECUTABLE" $HOME/opt/bin/$EXECUTABLE
    printf "${YELLOW}installed $HOME/opt/bin/$EXECUTABLE${UNSET}\n"
    check_opt_bin_in_path
}

if [ $TASK == "--apt-install" ]; then
    sudo apt-get update && \
    sudo apt-get install $(awk '{print $1}' packages.txt | grep -v "^#")

elif [ $TASK == "--install-miniconda" ]; then
    if [[ $OSTYPE == darwin* ]]; then
        download https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh miniconda.sh
    else
        download https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh miniconda.sh
    fi

    set -x
    bash miniconda.sh -b -p $MINICONDA_DIR
    rm miniconda.sh
    set +x
    $MINICONDA_DIR/bin/conda init bash

    if [ -e /data/$USER/miniconda3-tmp ]; then
        rm -r /data/$USER/miniconda3-tmp
    fi

elif [ $TASK == "--conda-channels-pytorch" ]; then
    conda config --add channels defaults
    if [[ $OSTYPE == darwin* ]]; then
        conda config --add channels pytorch-nightly
    else
        conda config --add channels pytorch
    fi
    conda config --add channels conda-forge
    conda config --set channel_priority strict

elif [ $TASK == "--conda-env" ]; then
    conda install --file requirements.txt

elif [ $TASK == "--install-neovim" ]; then
    NVIM_VERSION=0.8.0
    if [[ $OSTYPE == darwin* ]]; then
        download https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-macos.tar.gz nvim-macos.tar.gz
        tar -xzf nvim-macos.tar.gz
        mkdir -p "$HOME/opt/bin"
        mv nvim-osx64 "$HOME/opt/neovim"
    else
        download https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz nvim-linux64.tar.gz
        tar -xzf nvim-linux64.tar.gz
        mv nvim-linux64 "$HOME/opt/neovim"
        rm nvim-linux64.tar.gz
    fi
    ln -sf ~/opt/neovim/bin/nvim ~/opt/bin/nvim

elif [ $TASK == "--neovim-plugins" ]; then
    git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
    printf "${YELLOW}open nvim and run :PackerSync${UNSET}\n"

elif [ $TASK == "--install-ripgrep" ]; then
    RG_VERSION=13.0.0

    if [[ $OSTYPE == darwin* ]]; then
        URL=https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-apple-darwin.tar.gz
    else
        URL=https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz
    fi

    mkdir -p /tmp/rg
    download $URL /tmp/rg/ripgrep.tar.gz
    cd /tmp/rg
    tar -xf ripgrep.tar.gz
    cp ripgrep*/rg ~/opt/bin
    check_opt_bin_in_path

elif [ $TASK == "--install-icdiff" ]; then
    ICDIFF_VERSION=2.0.4
    download https://raw.githubusercontent.com/jeffkaufman/icdiff/release-${ICDIFF_VERSION}/icdiff ~/opt/bin/icdiff
    chmod +x ~/opt/bin/icdiff
    check_opt_bin_in_path

elif [ $TASK == "--dotfiles" ]; then
    set -x

    if [[ $OSTYPE == darwin* ]]; then
        md5program=md5
    else
        md5program=md5sum
    fi

    BACKUP_DIR="$HOME/dotfiles-backup-$(date +%s | $md5program | base64 | head -c 8 | tr [:upper:] [:lower:])"
    cd "$(dirname "${BASH_SOURCE}")";
    rsync --no-perms --backup --backup-dir="$BACKUP_DIR" -avh --files-from=include.file . $HOME

elif [ $TASK == "--diffs" ]; then
    command -v ~/opt/bin/icdiff >/dev/null 2>&1 || {
        printf "${RED}icdiff not found; run ./setup.sh --install-icdiff${UNSET}\n"
            exit 1;
        }
    rdiff="$HOME/opt/bin/icdiff --recursive --line-numbers"
    $rdiff ~ . | grep -v "Only in $HOME" | sed "s|$rdiff||g"

elif [ $TASK == "--vim-diffs" ]; then
    for i in $(git ls-tree -r HEAD --name-only | grep "^\."); do nvim -d $i ~/$i; done

else
    printf "${RED}unsupported argument${UNSET}\n"
    exit 1
fi
