#!/bin/bash
cd "$(dirname "${BASH_SOURCE}")"

# backup
cp ~/.{bash_profile,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc,utils} ~/.backups
cp -r ~/.vim ~/.backups

source ./.brew

cp -rf .vim ~
cp .{bash_profile,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc,utils} ~

source ~/.bash_profile