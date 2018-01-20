#!/usr/bin/env bash

# Array of possible Firefox application names.
appname="TextMate"    # "Firefox" "IceWeasel" "etc

#
# Calls lsregister -dump and parses the output for "/Firefox.app", etc.
# Returns the very first result found.
#
function get_osx_ffdir()
{
    # OSX Array of possible lsregister command locations
    # I'm only aware of this one currently
    lsregs=("/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister")

    for i in "${lsregs[@]}"; do
            if [ -f $i ]; then
                echo "$i"
                # Some logic to parse the output from lsregister
                 pathArray=($($i -dump |grep -E "/$appname.app$" |cut -d'/' -f2-))
                # pathArray=("Volumes/HKBNLocalSpeedTest/HKBNLocalSpeedTest.app" "Volumes/Hard Drive 2/james/Downloads/HKBNLocalSpeedTest.app")

                # ffdir=$($i -dump |grep -E "/$appname.app$" |cut -d'/' -f2- |head -1)
                for path in "${pathArray[@]}"
                do
                    echo "$path"
                    ffdir="/$path"

                    if [[ "$path" =~ ^Application* ]]; then
                        echo "in regex, breaking"
                        ffdir="/$path"
                    fi
                    echo "ffdir = $ffdir"
                done

                return 0
            fi
    done
    return 1
}

#
# Uses "which" and "readlink" to locate firefox on Linux, etc
#



echo "Searching for Firefox..."

ffdir=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    get_osx_ffdir
else
    # Linux, etc
    get_ffdir
fi

echo "Found application here: $ffdir"

