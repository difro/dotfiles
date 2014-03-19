#!/bin/bash
# vim: ts=8 sw=8 noet
########## Variables

olddir=.dotfiles_old             # old dotfiles backup directory

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in *; do
	echo $file
	echo "Moving any existing dotfiles from ~ to $olddir"
	mv -f ~/.$file $olddir/
	echo "Creating symlink to $file in home directory."
	ln -s `pwd`/$file ~/.$file
done
