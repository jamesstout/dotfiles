#!/usr/bin/env bash
flagLocation="/Volumes/CCC"
flagRemoved=".ney_the_index"  # a new name

if [ -d "$flagLocation" ]; then
    if [ -a "$flagLocation/$flagRemoved" ]; then
        mv "$flagLocation/$flagRemoved" "$flagLocation/.metadata_never_index"
        echo "moved .ney_the_index to .metadata_never_index"
    else
        echo ".ney_the_index not present"
    fi

    if [ ! -a "$flagLocation/$flagRemoved" ] || [ ! -a "$flagLocation/.metadata_never_index" ] ; then
        touch "$flagLocation/.metadata_never_index"
        echo "created .metadata_never_index"
    else
        echo ".metadata_never_index already existed"
    fi
fi

