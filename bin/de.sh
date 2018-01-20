de ()
{
    containers=( $(docker ps --all | rev | cut -d " " -f1 | rev | grep -v NAMES) )
    usage_containers=$( printf "%s|" "${containers[@]}" )
    usage_containers=${usage_containers::-1}

if [ "$1" = '-l' ]; then
    printf "%s\n" "${containers[@]}"
    return 0
fi

    if [ -z "$1" ]; then
        echo "Usage: de <$usage_containers>";
    else
        if [[ " ${containers[@]} " =~ " ${1} " ]]; then
            case "$1" in
                phpmyadmin)
                    docker exec -it "$1" /bin/ash
                ;;
                crashplan-pro)
                    docker exec -it "${selected_container}" /bin/ash
                ;;
                *)
                    docker exec -it "$1" /bin/bash
                ;;
            esac;
        else
            echo "'$1' - container does not exist";
        fi;
    fi
}

function de2()
{
    containers=( $(docker ps --all | rev | cut -d " " -f1 | rev | grep -v NAMES) )
    usage_containers=$( printf "%s|" "${containers[@]}" )
    usage_containers=${usage_containers::-1}

    options=(backup_*/)

menu() {
    #clear
    echo "Avaliable containers:"
    for i in ${!containers[@]}; do 
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${containers[i]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

prompt="Choose a container (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#containers[@]} )) || {
        msg="Invalid option: $num"; continue
    }
    ((num--)); msg="${containers[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="[+]"
done

printf "You selected"; msg=" nothing"
for i in ${!containers[@]}; do 
    [[ "${choices[i]}" ]] && { printf " %s" "${containers[i]}"; msg=""; }
done
echo "$msg"
}


function de2()
{
    containers=( $(docker ps --all | rev | cut -d " " -f1 | rev | grep -v NAMES) )
    
    read -p "$(
            f=0
            for container in "${containers[@]}" ; do
                echo "$((++f)): $container"
            done

            echo -ne 'Please select a container > '
    )" selection

    selected_container="${containers[$((selection-1))]}"

    echo " Executing docker exec -it '$selected_container'"

    
    
        if [[ " ${containers[@]} " =~ " ${selected_container} " ]]; then
            case "${selected_container}" in
                phpmyadmin)
                    docker exec -it "${selected_container}" /bin/ash
                ;;
                crashplan-pro)
                    docker exec -it "${selected_container}" /bin/ash
                ;;
                *)
                    docker exec -it "${selected_container}" /bin/bash
                ;;
            esac;
        else
            echo "'$1' - container does not exist";
        fi;
    

}

