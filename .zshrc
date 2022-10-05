for file in ~/.{aliases,exports}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

[ -z "$PS1" ] && return

export PROMPT='%F{51}%n%f@%T~$'

if [[ $HOSTNAME == *".crc.nd.edu" ]]; then
    export PROMPT='%F{11}%n%f@%T~$'
fi
if [[ $HOSTNAME == *".cse.nd.edu" ]]; then
    export PROMPT='%F{10}%n%f@%T~$'
fi

export PATH=$PATH:$HOME/opt/bin
export PATH=$PATH:$HOME/miniconda3/bin
