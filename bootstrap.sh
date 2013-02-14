#!/bin/bash
cd "$(dirname "${BASH_SOURCE}")"

cp .{bash_profile,path,exports,aliases,functions,extra,gitattributes,gitconfig,gitignore,inputrc,hgignore,wgetrc,vimrc} ~

source ~/.bash_profile