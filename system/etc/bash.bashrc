#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="\[\033[0;37m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[0;31m\]\h'; else echo '\[\033[0;35m\]\u\[\033[0;37m\]'; fi)\[\033[0;37m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;37m\]]\n\[\033[0;37m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]"
PS2='> '
PS3='> '
PS4='+ '

[[ "$PS1" ]] && /usr/bin/fortune /usr/share/fortune/firefly

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion

#Disable bell
xset b off
set bell-style none

alias less='/usr/share/vim/vim74/macros/less.sh'
alias diff='colordiff'
alias more='less'
alias mkdir='mkdir -pv'
alias nano='nano -w'
alias ping='ping -c 5'
alias dmesg='dmesg -HL'

alias da='date "+%A, %B %d, %Y [%T]"'
alias du1='du --max-depth=1'
alias hist='history | grep'         # requires an argument
alias openports='ss --all --numeric --processes --ipv4 --ipv6'
alias pgg='ps -Af | grep'           # requires an argument
alias ..='cd ..'

# Privileged access
if [ $UID -ne 0 ]; then
        alias sudo='sudo '
        alias scat='sudo cat'
        alias svim='sudoedit'
        alias root='sudo -s'
        alias reboot='sudo systemctl reboot'
        alias poweroff='sudo systemctl poweroff'
        alias update='sudo pacman -Su'
        alias netctl='sudo netctl'
fi

alias ls='ls -h --color=auto'
alias lr='ls -R'                   # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -BX'                  # sort by extension
alias lz='ll -rS'                  # sort by size
alias lss='ll -rS'                 # sort by size
alias lt='ll -t'                   # sort by date
alias lm='la | more'
alias l.='ls -dh .* --color=auto'
eval $(dircolors -b)

export TERM=xterm
export EDITOR=vim
export HISTTIMEFORMAT='%F %T '
# avoid duplicates..
export HISTCONTROL=ignoredups:erasedups  
# append history entries..
shopt -s histappend
export HISTSIZE=9999999
export HISTFILESIZE=99999999
export XDG_CONFIG_HOME=$HOME/.config

# TODO
#rm() {
    #date >> ~/.rm_log
    #/usr/bin/rm $@ >> ~/.rm_log
    #echo "" >> ~/.rm_log
    #echo "-------------------------------------------------" >> ~/.rm_log
    #echo "" >> ~/.rm_log
#}

alias arch='uname -m'
alias pacman='pacman --color=auto'
alias cp='cp -r'
#alias cp='acp -rg'
#alias mv='amv -g'
alias df='df -h'
alias du='du -hc'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias findman='man -wa'
alias grep='grep -I --color=auto'
alias rm='rm -rv --preserve-root'
alias :q=' exit'
alias :Q=' exit'
alias :x=' exit'
alias cd..='cd ..'
# Remove the specified package(s), retaining its configuration(s) and required dependencies
alias pacremove='sudo pacman -R'
# Remove the specified package(s), its configuration(s) and unneeded dependencies
alias pacuninstall='sudo pacman -Rns'
# '[r]emove [o]rphans' - recursively remove ALL orphaned packages
alias pacro="pacman -Qtdq > /dev/null && sudo pacman -Rns \$(pacman -Qtdq | sed -e ':a;N;$!ba;s/\n/ /g')"
alias paclsearch='pacman --color auto -Ss'
alias pacsearch='packer-color -Ss'
alias vi='vim'
alias spdtest='wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'
alias wifitop='sudo iftop -i wlp2s0'
alias gits='git status'
alias gitd='git diff'
alias gita='git add'
alias gitr='git rm'
alias gitcm='git commit -m'
alias shiny='/usr/bin/fortune /usr/share/fortune/firefly'
#TODO
#make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}'  

# cd aliases
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../'
alias ......='cd ../../../../'
alias .......='cd ../../../../../'
alias ........='cd ../../../../../../'
alias .........='cd ../../../../../../../'
alias ..........='cd ../../../../../../../../'
alias ...........='cd ../../../../../../../../../'
alias ............='cd ../../../../../../../../../../'
#alias .4='cd ../../../../'
#alias .5='cd ../../../../..'

alias bc='bc -l'
alias sha1='openssl sha1'
# Vim aliases
alias svi='sudo vi'
alias vis='vim "+set si"'
alias edit='vim'

alias fastping='ping -c 100 -s.2'
alias ports='netstat -tulanp'


## shortcut  for iptables and pass it via sudo#
alias ipt='sudo /sbin/iptables'
 
# display all rules #
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'
alias firewall=iptlist

# get web server headers #
alias header='curl -I'
 
# find out if remote server supports gzip / mod_deflate or not #
alias headerc='curl -I --compress'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

# Resume wget by default
alias wget='wget -c'

alias top='htop'
alias tree='tree --dirsfirst'
alias free='free -h'

man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *.jar) c=(unzip);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
   done
   return "$e"
}

_extract(){
    local 
    COMPREPLY=( $(compgen -W "${napp_opts}" -- ${cur}) )
}

# cd and ls in one
cl() {
    dir=$1
    if [[ -z "$dir" ]]; then
        dir=$HOME
    fi
    if [[ -d "$dir" ]]; then
        cd "$dir"
        ls
    else
        echo "bash: cl: '$dir': Directory not found"
    fi
}

note () {
    # if file doesn't exist, create it
    if [[ ! -f $HOME/.notes ]]; then
        touch "$HOME/.notes"
    fi

    if ! (($#)); then
        # no arguments, print file
        cat "$HOME/.notes"
    elif [[ "$1" == "-c" ]]; then
        # clear file
        > "$HOME/.notes"
    else
        # add all arguments to file
        printf "%s\n" "$*" >> "$HOME/.notes"
    fi
}

todo() {
    if [[ ! -f $HOME/.todo ]]; then
        touch "$HOME/.todo"
    fi

    if ! (($#)); then
        cat "$HOME/.todo"
    elif [[ "$1" == "-l" ]]; then
        nl -b a "$HOME/.todo"
    elif [[ "$1" == "-c" ]]; then
        > $HOME/.todo
    elif [[ "$1" == "-r" ]]; then
        nl -b a "$HOME/.todo"
        printf "----------------------------\n"
        read -p "Type a number to remove: " number
        ex -sc "${number}d" "$HOME/.todo"
    else
        printf "%s\n" "$*" >> "$HOME/.todo"
    fi
}

calc() {
    echo "scale=3;$@" | bc -l
}

#TODO make this handle more than 1 arg
oct(){
    printf "%o\n" $1
}

dec(){
    printf "%d\n" $1
}

hex(){
    printf "%x\n" $1
}

mount(){
/usr/bin/mount $@ | column -t
}

#alias mount='pretty_mount'
#alias mounts='mount $@ | column -t'

#mount(){
    #echo `mount $@ | column -t`
#}
#alias mount=mount

alias rsync='rsync -rP'
alias fucking="sudo "
#alias info='pinfo'
shopt -s autocd
