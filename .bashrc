for file in ~/.{path,exports,bash_prompt,functions,aliases}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# check for interactive session, continue if not
[ -z "$PS1" ] && return

# append to the history file, avoid overwriting
shopt -s histappend

# check the window size after each command and,
# if necessary, update the values of LINES/COLUMNS
shopt -s checkwinsize

# if set, a command name that is the name of a directory
# is executed as if it were the argument to the cd command
shopt -s autocd 2> /dev/null || true

# if set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories
shopt -s globstar 2> /dev/null || true

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi

# make less more user-friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and add useful aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# enable git tab autocompletion on macOS
if [[ $OSTYPE == darwin* ]]; then
    test -f ~/.git-completion.bash && source ~/.git-completion.bash
fi
