#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"

BACKUPS_DIR="$HOME"/.backups

if [ ! -d "$BACKUPS_DIR" ]; then
	printf "$(tput setaf 136)! %s$(tput sgr0)\n" "$BACKUPS_DIR does not exist, creating..."
	mkdir "$BACKUPS_DIR" || printf "$(tput setaf 1)x %s$(tput sgr0)\n" "Could not create $BACKUPS_DIR" ; printf "Aborting...\n"; return 1
fi

# backup
# backup .z - it contains all the z directory info, just in case
cp ~/.{bash_profile,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc,utils,bashrc,z} "$BACKUPS_DIR"
cp -r ~/.vim "$BACKUPS_DIR"

# update dotfiles
cp -rf .vim ~
cp .{bash_profile,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc,utils,bashrc} ~

# move down here, depends on .utils
source ./.brew

# for testing without .brew
#source ./.utils

# setup vars for dirs and symlinks
BIN_DIR="$HOME"/bin
SUBL_SYMLINK="$BIN_DIR"/subl
SUBL2_APP="/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl"
SUBL3_APP="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
# default to v2
SUBL_APP="$SUBL2_APP"
Z_REPO="third-party/z"
RBENV_REPO="$HOME/.rbenv"

# update rbenv
e_header "Updating rbenv..."
cd "$RBENV_REPO"
git_info=$(get_git_branch)
git pull -v origin "$git_info"
cd -

# update npm
e_header "Updating npm..."
npm update npm -g
npm update npm
npm update -g

# gem update
e_header "Updating gems..."
gem update
gem cleanup
rbenv rehash

if file_exists "$SUBL3_APP"; then
	SUBL_APP="$SUBL3_APP"
fi

# check on bin and links
# should exist but if not...
if [ ! -d "$BIN_DIR" ]; then
	e_warning "$BIN_DIR does not exist, creating..."
	if mkdir "$BIN_DIR"; then
		printf "Creating subl symlink"
		ln -s "$SUBL_APP" "$SUBL_SYMLINK"

		# update z repo and copy
		cd "$Z_REPO"
		git_info=$(get_git_branch)
		git pull -v origin "$git_info"
		cp -f z.sh "$BIN_DIR"
		chmod +x "$BIN_DIR"/z.sh
		cd -
	else
		e_error "Could not create $BIN_DIR" ; 
		e_warning "$(tput setaf 136)! %s$(tput sgr0)\n" "Sublime Text symlink and z will not be installed";
	fi
else

	# check subl symlink exists if not create it
	if ! file_exists "$SUBL_SYMLINK"; then
		printf "Creating subl symlink"
		ln -s "$SUBL_APP" "$SUBL_SYMLINK"
	fi

	# cp extract and editor
	cp -f bin/editor.sh "$BIN_DIR"
	cp -f bin/extract "$BIN_DIR"
	cp -f bin/ixio "$BIN_DIR"
	cp -f bin/httpcompression "$BIN_DIR"
	chmod +x "$BIN_DIR"/extract
	chmod +x "$BIN_DIR"/editor.sh
	chmod +x "$BIN_DIR"/ixio
	chmod +x "$BIN_DIR"/httpcompression

	# update z repo and copy
	cd "$Z_REPO"
	git_info=$(get_git_branch)
	git pull -v origin "$git_info"
	cp -f z.sh "$BIN_DIR"
	chmod +x "$BIN_DIR"/z.sh
	cd -

fi

source ~/.bash_profile