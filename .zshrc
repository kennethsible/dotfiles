[ -r "~/.bash_profile" ] && source ~/.bash_profile

for file in ~/.{aliases, exports}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

export PS1="\u@\h:\w\\$ "

if [[ $HOSTNAME == *".crc.nd.edu" ]]; then
    export PS1="\u@\[$(tput sgr0)\]\[\033[38;5;214m\]\h\[$(tput sgr0)\]:\w\\$ "
fi
if [[ $HOSTNAME == *".cse.nd.edu" ]]; then
    export PS1="\u@\[$(tput sgr0)\]\[\033[38;5;174m\]\h\[$(tput sgr0)\]:\w\\$ "
fi

export PATH=$PATH:$HOME/opt/bin
export PATH=$PATH:$HOME/miniconda3/bin

[ -z "$PS1" ] && return
