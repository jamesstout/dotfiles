#!/bin/bash
cd "$(dirname "${BASH_SOURCE}")"

cp ~/.{bash_profile,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc} ~/.backups

source ./.brew

cp .{bash_profile,bash_prompt,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc} ~

source ~/.bash_profile