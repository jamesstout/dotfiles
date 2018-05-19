#!/usr/bin/env bash
#cd "$(dirname "${BASH_SOURCE}")"


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$SCRIPT_DIR" || return 1

source ./.utils

BACKUPS_DIR="$HOME"/.backups

if [ ! -d "$BACKUPS_DIR" ]; then
    printf "$(tput setaf 136)! %s$(tput sgr0)\n" "$BACKUPS_DIR does not exist, creating..."
    mkdir "$BACKUPS_DIR" ||  return 1
fi

# backup
# backup .z - it contains all the z directory info, just in case
cp ~/.{bash_profile,iterm2_shell_integration.bash,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,gitignore_global,inputrc,hgignore,wgetrc,vimrc,utils,bashrc,z,gemrc,tmux.conf,npmrc,ackrc} "$BACKUPS_DIR"
cp -R ~/.vim "$BACKUPS_DIR"
cp -R ~/.git_template "$BACKUPS_DIR"

# do we have an updated .iterm2_shell_integration.bash?
if ! doiTermIntegrationCheck ; then
    e_error "Something went wrong"
    return 1
fi

# update dotfiles
cp -Rf .vim ~
cp -Rf .git_template ~
cp .{bash_profile,bash_prompt,iterm2_shell_integration.bash,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,gitignore_global,inputrc,hgignore,wgetrc,vimrc,utils,bashrc,gemrc,tmux.conf,npmrc,ackrc} ~

# move down here, depends on .utils
source ./.brew

# for testing without .brew
#source ./.utils

# setup vars for dirs and symlinks
BIN_DIR="$HOME"/bin
STATS_DIR="$HOME"/stats
SUBL_SYMLINK="$BIN_DIR"/subl
SUBL2_APP="/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl"
SUBL3_APP="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
# default to v2
SUBL_APP="$SUBL2_APP"
Z_REPO="third-party/z"
#RBENV_REPO="$HOME/.rbenv"
ST3_DIR="$HOME/Library/Application Support/Sublime Text 3/Packages"
ST3_BH_DIR="$ST3_DIR/BracketHighlighter"
ST3_TS_DIR="$ST3_DIR/Theme - Soda"
ST3_B16_DIR="$ST3_DIR/Base16"
ST3_USER_DIR="$ST3_DIR/User"
ST3_BH_FILE="$ST3_BH_DIR/bh_core.sublime-settings"
ST3_BH_USER_FILE="$ST3_USER_DIR/bh_core.sublime-settings"
ST3_BH_USER_FILE_BAK="$ST3_USER_DIR/bh_core.sublime-settings.bak"

declare -a dirs_to_check=("$ST3_BH_DIR" "$ST3_TS_DIR")

for ((i=0; i<${#dirs_to_check[@]}; ++i));
do
    if ! dir_exists "${dirs_to_check[$i]}"; then
        e_error "${dirs_to_check[$i]} does not exist. Exiting"
        return 23
    fi
done

#ST3 stuff
# e_header "Updating ST3 packages..."

# e_debug "Updating BracketHighlighter"
# # if not already up to date, there could be new settings to copy
# if ! [[ $(cd_and_git_pull "$ST3_BH_DIR" 2> /dev/null | tail -n1) =~ ^Already ]]; then
# 	# back up current settings
# 	e_debug "Copying BracketHighlighter settings"
# 	mv "$ST3_BH_USER_FILE" "$ST3_BH_USER_FILE_BAK"
# 	cp "$ST3_BH_FILE" "$ST3_BH_USER_FILE"
# fi

# e_debug "Updating Theme Soda"
# cd_and_git_pull "$ST3_TS_DIR"

# e_debug "Updating Base16 Theme"
# cd_and_git_pull "$ST3_B16_DIR"

#### update npm
# e_header "Updating npm..."
# npm update npm -g
# npm update npm
# npm update -g

# e_header "Updating gems..."
# for version in $(rbenv whence gem); do
#   rbenv shell "$version"
#   echo "Updating rubygems for $version"
#   gem update --system --no-document #--quiet
#   yes | gem update
#   gem cleanup
#   echo ""
# done
# rbenv rehash

if file_exists "$SUBL3_APP"; then
    SUBL_APP="$SUBL3_APP"
fi

# check stats dir
if [ ! -d "$STATS_DIR" ]; then
    e_warning "$STATS_DIR does not exist, creating..."
    if mkdir "$STATS_DIR"; then
        e_debug "Done"
    else
        e_error "Could not create $STATS_DIR" ;
        e_warning "git post-commit hook will not record commits";
    fi
fi

# check on bin and links
# should exist but if not...
if [ ! -d "$BIN_DIR" ]; then
    e_warning "$BIN_DIR does not exist, creating..."
    if mkdir "$BIN_DIR"; then
        printf "Creating subl symlink"
        ln -s "$SUBL_APP" "$SUBL_SYMLINK"
        
        # update z repo and copy
        cd "$Z_REPO" || return 1
        git_info=$(get_git_branch)
        git pull -v origin "$git_info"
        cp -f z.sh "$BIN_DIR"
        chmod +x "$BIN_DIR"/z.sh
        cd - || return 1
    else
        e_error "Could not create $BIN_DIR" ;
        e_warning "Sublime Text symlink and z will not be installed";
    fi
else
    
    # check subl symlink exists if not create it
    if ! file_exists "$SUBL_SYMLINK"; then
        printf "Creating subl symlink"
        ln -s "$SUBL_APP" "$SUBL_SYMLINK"
    fi
    
    e_debug "Copying bins"
    cp -f bin/{tdu,piper,merge-branch.sh,editor.sh,extract,ixio,httpcompression,parallel,bashmarks.sh,de-dupe-bash-eternal-history.sh,startup-gpg-agent.sh,itunes-apps-periodic-cleanup.py,blame-bird.py,tm-log} "$BIN_DIR"
    chmod +x "$BIN_DIR"/{tdu,piper,merge-branch.sh,editor.sh,extract,ixio,httpcompression,parallel,bashmarks.sh,de-dupe-bash-eternal-history.sh,startup-gpg-agent.sh,itunes-apps-periodic-cleanup.py,blame-bird.py,tm-log}
    
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
# shellcheck source=/Users/james/.bash_profile
source ~/.bash_profile






