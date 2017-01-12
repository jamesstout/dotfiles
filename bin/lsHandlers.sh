#!/usr/bin/env bash

PLIST="$HOME/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
BUDDY=/usr/libexec/PlistBuddy

# the key to match with the desired value
KEY=LSHandlerRoleAll

# the value for which we'll replace the handler
VALUE=public.plain-text

# the new handler for all roles
HANDLER=com.sublimetext.2
HANDLER2=com.sublimetext.3

# $BUDDY -c 'Print "LSHandlers"' $PLIST 

# exit
# declare -i I=4

# $BUDDY -c "Print 'LSHandlers:$I:$KEY'" $PLIST
# $BUDDY -c "Print 'LSHandlers:$I:LSHandlerContentType'" $PLIST



# exit


$BUDDY -c 'Print "LSHandlers"' $PLIST >/dev/null 2>&1
ret=$?
if [[ $ret -ne 0 ]] ; then
        echo "There is no LSHandlers entry in $PLIST" >&2
        exit 1
fi

function create_entry {
        $BUDDY -c "Add LSHandlers:$I dict" $PLIST
        $BUDDY -c "Add LSHandlers:$I:$KEY string $VALUE" $PLIST
        $BUDDY -c "Add LSHandlers:$I:LSHandlerRoleAll string $HANDLER" $PLIST
}

declare -i I=0

while [ true ] ; do

        $BUDDY -c "Print LSHandlers:$I" $PLIST >/dev/null 2>&1
        #[[ $? -eq 0 ]] || { echo "Finished, no $VALUE found, setting it to $HANDLER" ; create_entry ; exit ; }

        OUT="$( $BUDDY -c "Print 'LSHandlers:$I:$KEY'" $PLIST 2>/dev/null )"
        if [[ $? -ne 0 ]] ; then 
                I=$I+1
                continue
        fi


        CONTENT=$( echo "$OUT" )
        if [[ $CONTENT = $HANDLER ]] ; then

                OLD="$($BUDDY -c "Print 'LSHandlers:$I:LSHandlerContentType'" $PLIST )" # 2>/dev/null)"

                if [[ $? -ne 0 ]] ; then 
                        echo "No LSHandlers:$I:LSHandlerContentType for $CONTENT"
                        I=$I+1
                        continue
                else
                        echo "Replacing $CONTENT handler with $HANDLER2 for $OLD"
                        echo "Replacing $I"
                #$BUDDY -c "Delete 'LSHandlers:$I'" $PLIST
                #create_entry
                I=$I+1
                continue   
                fi


 
        else
                I=$I+1 
        fi
        echo $I
done

exit
