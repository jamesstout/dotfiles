#!/usr/bin/env bash

case "$1" in
	*_EDITMSG|*MERGE_MSG|*_TAGMSG )
		/usr/local/bin/subl -w "$1"
		;;
	*.md )
		/usr/local/bin/mmdc "$1"
		;;
	*.txt )
		/usr/local/bin/mmdc "$1"
		;;
	* )
		/usr/local/bin/subl -w "$1"
		;;
esac
