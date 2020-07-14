#!/usr/bin/env bash
#cd "$(dirname "${BASH_SOURCE}")"
# shellcheck disable=SC1091,SC1117

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR" || return 1

# shellcheck source=.emails
source ./.emails
# shellcheck source=.utils
source ./.utils

e_header "Setting LoginwindowText if required"
#logn "Configuring security settings:"
#addLoginwindowText

BACKUPS_DIR="$HOME"/.backups

if [ ! -d "$BACKUPS_DIR" ]; then
	printf "$(tput setaf 136)! %s$(tput sgr0)\n" "$BACKUPS_DIR does not exist, creating..."
	mkdir "$BACKUPS_DIR" || return 1
fi

# backup
# backup .z - it contains all the z directory info, just in case
cp ~/.{bash_profile,iterm2_shell_integration.bash,bash_prompt,path,emails,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,gitignore_global,inputrc,hgignore,wgetrc,vimrc,utils,bashrc,z,gemrc,tmux.conf,npmrc,ackrc} "$BACKUPS_DIR"
cp -R ~/.vim "$BACKUPS_DIR"
cp -R ~/.git_template "$BACKUPS_DIR"

# do we have an updated .iterm2_shell_integration.bash?
if ! doiTermIntegrationCheck; then
	e_error "Something went wrong"
	return 1
fi

# update dotfiles
cp -Rf .vim ~
cp -Rf .git_template ~
cp .{bash_profile,bash_prompt,iterm2_shell_integration.bash,path,emails,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,gitignore_global,inputrc,hgignore,wgetrc,vimrc,utils,bashrc,gemrc,tmux.conf,npmrc,ackrc} ~

# move down here, depends on .utils
# shellcheck source=.brew
source ./.brew

# for testing without .brew
# source ./.utils

# setup vars for dirs and symlinks
BIN_DIR="$HOME"/bin
STATS_DIR="$HOME"/stats
Z_REPO="third-party/z"

#### update npm
e_header "Updating npm..."
npm update npm -g
npm update npm
npm update -g
npm install -g npm

#### update rust
# rustup update

#### update ruby gems
e_header "Updating gems..."
for version in $(rbenv whence gem); do
	rbenv shell "$version"

    e_debug "Updating rubygems for $version"
	gem update --system --no-document #--quiet
    
    yes | gem update
	
	gem cleanup -v
    rbenv rehash
	echo ""
done

# check stats dir
if [ ! -d "$STATS_DIR" ]; then
	e_warning "$STATS_DIR does not exist, creating..."
	if mkdir "$STATS_DIR"; then
		e_debug "Done"
	else
		e_error "Could not create $STATS_DIR"
		e_warning "git post-commit hook will not record commits"
	fi
fi

# check on bin and links
# should exist but if not...
if [ ! -d "$BIN_DIR" ]; then
	e_warning "$BIN_DIR does not exist, creating..."
	if mkdir "$BIN_DIR"; then

		# update z repo and copy
		cd "$Z_REPO" || return 1
		git_info=$(get_git_branch)
		git pull -v origin "$git_info"
		cp -f z.sh "$BIN_DIR"
		chmod +x "$BIN_DIR"/z.sh
		cd - || return 1
	else
		e_error "Could not create $BIN_DIR"
		e_warning "z will not be installed"
	fi
else

	e_debug "Copying bins"
	cp -f bin/{tdu,piper,merge-branch.sh,editor.sh,extract,ixio,httpcompression,bashmarks.sh,de-dupe-bash-eternal-history.sh,startup-gpg-agent.sh,itunes-apps-periodic-cleanup.py,blame-bird.py,tm-log} "$BIN_DIR"
	chmod +x "$BIN_DIR"/{tdu,piper,merge-branch.sh,editor.sh,extract,ixio,httpcompression,bashmarks.sh,de-dupe-bash-eternal-history.sh,startup-gpg-agent.sh,itunes-apps-periodic-cleanup.py,blame-bird.py,tm-log}

	# update z repo and copy
	cd "$Z_REPO" || return 1
	git_info=$(get_git_branch)
	e_debug "cd $Z_REPO. Branch is $git_info"

	e_debug "cmd is git pull -v origin $git_info"

	git pull -v origin "$git_info"
	cp -f z.sh "$BIN_DIR"
	chmod +x "$BIN_DIR"/z.sh
	cd - || return 1

fi
# shellcheck source=$HOME/.bash_profile
source ~/.bash_profile
