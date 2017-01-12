#!/usr/local/bin/bash


######################## DESCRIPTION ################################
# Determine which network interfaces are active						#
# and snag their IP Addresses. Do not display inactive interfaces.	#
# This script is specific to Mac OS, and accounts for irregulari-  #
# ties in the way it assigns network interfaces.
#####################################################################

declare -a currentservices
declare -a devaddress
declare -A SERVICEMAP
# Get list of network interfaces contqining the name and devID
services=$(networksetup -listnetworkserviceorder  | grep -v 'aster') #| grep 'Hardware Port')

#
# Parse the giant string on delimiters... 
while read line; do

    # echo "line is $line"

    LINE_COUNT=$(($LINE_COUNT+1));
    if [[ $LINE_COUNT == 3 ]]; then
       LINE_COUNT=0

       # echo "ccPREVLINE1 = $PREVLINE1"
       #  echo "ccPREVLINE2 = $PREVLINE2"


       # do whatever you want to do with the 3 lines
       fullServiceName=$(echo ${PREVLINE2#\(*\)})

       # echo "fsn = $fullServiceName"

       sname=$(echo $PREVLINE1 | awk -F  "(, )|(: )|[)]" '{print $2}')
       sdev=$(echo $PREVLINE1 | awk -F  "(, )|(: )|[)]" '{print $4}')


         # echo "sdev = $sdev"
         # echo "sname = $sname"

       SERVICEMAP[$sname]=$fullServiceName

           # if device has a valid device ID, 
        if [ -n "$sdev" ]; then
        # ask ifconfig for its status. (2>/dev/null = do it silently)...
            ifconfig $sdev 2>/dev/null | grep 'status: active' > /dev/null 2>&1
        # but capture the return code.     
            rc="$?"
            # If return code is non-zero...
            if [ "$rc" -eq 0 ]; then
                    # replace spaces with underscores to prevent value from 
                    # fragmenting into fields in the array.
                    snameFX=$(echo $sname | sed -e 's/ /_/g')

                    # echo "sname = $sname"
                     # echo "snameFX = $snameFX"
                    # Append service name to this array
                    currentservices=(${currentservices[@]} "$snameFX")

            fi
        fi



    fi
    PREVLINE2="$PREVLINE1"
    PREVLINE1="$line"

    #echo "PREVLINE1 = $PREVLINE1"
    #echo "PREVLINE2 = $PREVLINE2"

done <<< "$(echo "$services")" #'Here-String' to feed the services list into the while loop.

# echo "map"
# echo ${SERVICEMAP[@]}

# for K in "${!SERVICEMAP[@]}"; do echo $K --- ${SERVICEMAP[$K]}; done


# exit;


# If current services array is not empty...
if [ -n $currentservices ]; then
	for i in "${currentservices[@]}"; do
	# Set new var $iFace to hold value of $i, with spaces restored, 
    #get proper name
    iFace=${SERVICEMAP[$i]}
            # echo " the iFace is $iFace"
            # echo " the i is [$i]"

	iFace=$(echo $iFace | sed s/_/\ /g)	

            # echo " the iFace is $iFace"
IPAddy=""
TheLine=""
	# Look up the IP address for each value by "name" using networksetup
	   IPAddy=$(networksetup -getinfo "$iFace"| grep "^IP address" | sed s/"^IP address: "//)
	   TheLine="$i:,$IPAddy"
       #echo " the line is $TheLine"
       #echo " the iFace is $iFace"
	   devaddress=("${devaddress[@]}" "$TheLine")	   
	done
	
	# Format it in pretty-ish columns
	 printf '%s\n' "${devaddress[@]}"|column -s "," -t
else
    >&2 echo "Could not find current service"
    exit 1
fi
