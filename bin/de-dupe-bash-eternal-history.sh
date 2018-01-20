#!/usr/bin/env bash

cp .bash_eternal_history .bash_eternal_history.bak3
cp .bash_eternal_history .bash_eternal_history.bak
#cp .bash_eternal_history.bak .bash_eternal_history

sort .bash_eternal_history.bak4 |grep '^[0-9]' |  sort -k2 -u > new6
sort .bash_eternal_history.bak4 |grep '^[0-9]' | sed 's/ *$//' | sort -k2 -u > new7

sort .bash_eternal_history.bak4 |grep '^[0-9]' | sed 's/ *$//' | sort -k2 -u > .bash_eternal_history
