#!/bin/bash - 
#===============================================================================
#
#          FILE: backup.sh
# 
#         USAGE: ./backup.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 06/01/2014 13:14
#      REVISION:  ---
#===============================================================================

if [ ! -e ~/backup/home/ ]; then
    mkdir ~/backup/home/
fi

cp -r ~/.bash_history ~/backup/home/bash_history
cp -r ~/.bash_profile ~/backup/home/bash_profile
cp -r ~/.bashrc ~/backup/home/bashrc
if [ ! -e ~/backup/home/config/ ]; then
    mkdir -p ~/backup/home/config/
fi
cp -r ~/.config/awesome/ ~/backup/home/config/
cp -r ~/.config/screengen/ ~/backup/home/config/
cp -r ~/.inputrc ~/backup/home/inputrc
cp -r ~/.nanorc ~/backup/home/nanorc
cp -r ~/.tmux.conf ~/backup/home/tmux.conf
cp -r ~/.Xauthority ~/backup/home/Xauthority
cp -r ~/.xinitrc ~/backup/home/xinitrc
cp -r ~/.Xresources ~/backup/home/Xresources
cp -r ~/.xtermcontrol ~/backup/home/xtermcontrol
cp -r ~/.viminfo ~/backup/home/viminfo
cp -r ~/.vimrc ~/backup/home/vimrc
if [ ! -e ~/backup/home/mplayer/ ]; then
    mkdir ~/backup/home/mplayer/
fi
cp -r ~/.mplayer/config ~/backup/home/mplayer/

if [ ! -e ~/backup/system/etc/ ]; then
    mkdir -p ~/backup/system/etc/
fi
cp -r /etc/asound.conf ~/backup/system/etc/
cp -r /etc/bash.bash_logout ~/backup/system/etc/
cp -r /etc/bash.bashrc ~/backup/system/etc/
cp -r /etc/bash_completion.d/ ~/backup/system/etc/
cp -r /etc/color* ~/backup/system/etc/
cp -r /etc/fuse.conf ~/backup/system/etc/
cp -r /etc/inputrc ~/backup/system/etc/
cp -r /etc/mplayer/ ~/backup/system/etc/
cp -r /etc/nanorc ~/backup/system/etc/
cp -r /etc/profile ~/backup/system/etc/
cp -r /etc/tmux.conf ~/backup/system/etc/
cp -r /etc/vimrc ~/backup/system/etc/
cp -r /etc/wgetrc ~/backup/system/etc/
cp -r /etc/mime.types ~/backup/system/etc/

#cp -r / ~/backup/system/
#cp -r / ~/backup/system/
#cp -r / ~/backup/system/

