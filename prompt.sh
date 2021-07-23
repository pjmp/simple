#!/usr/env bash

# shellcheck disable=SC1091,SC2155

simple-bash-prompt-main() {
    # shellcheck disable=SC2128
    local ORIGINAL_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")

    source "$ORIGINAL_DIR/libs/git-prompt.sh"
    source "$ORIGINAL_DIR/libs/bash-preexec/bash-preexec.sh"

    humanize-time() {
        local out
        local time=$1
        local days=$((time / 60 / 60 / 24))
        local hours=$((time / 60 / 60 % 24))
        local minutes=$((time / 60 % 60))
        local seconds=$((time % 60))
        ((days > 0)) && out="${days}d"
        ((hours > 0)) && out="$out ${hours}h"
        ((minutes > 0)) && out="$out ${minutes}m"
        out="$out ${seconds}s"
        echo "$out"
    }

    preexec() {
        TIMER_INNER=${TIMER_INNER:-$SECONDS}
    }

    precmd() {
        TMP_TIME="$((SECONDS - TIMER_INNER))"

        if [ $TMP_TIME -ge 1 ]; then
            EXPOSE_TIMER="$(humanize-time $TMP_TIME)"
        fi

        unset TIMER_INNER
    }

    prompt-symbol() {
        # shellcheck disable=SC2181
        if [ "$?" -ne 0 ]; then
            echo -e "\n$(tput setaf 9)λ$(tput sgr0)"
        else
            echo -e "\n$(tput setaf 10)λ$(tput sgr0)"
        fi
    }

    # note: using tput here can mess exit code, best not to use it
    PS1='\[\e[34m\]\u\[\e[m\]'             # username
    PS1+='\[\e[1m\]\[\e[36m\]@\[\e[m\]'    # literal '@' symbol
    PS1+='\[\e[33m\]\w\[\e[m\]'            # current directory
    PS1+='\[\e[35m\]$(__git_ps1)\[\e[m\]'  # git prompt
    PS1+='\[\e[90m\]$EXPOSE_TIMER\[\e[m\]' # last command execution time
    PS1+='$(prompt-symbol)'                # "fancy" prompt symbol
    PS1+=' '
}

simple-bash-prompt-main

# remove function to prevent pollution of global namespace
unset simple-bash-prompt-main
