#!/bin/bash

echo "********************************************************************************** "
echo "HOSTNAME: ${HOSTNAME}"
echo 'num of args: '$#
i=0
xxargs=""
for arg in "$@"; do
   #echo 'arg: '$arg;
   if [ $i -ge "0" ]; then
      xxargs=$xxargs" "$arg
   fi;
   i=$((i + 1))
done

newargs=""
while [[ $# -gt 0 ]]
do
    key="$1"
    #echo "$key"
    case $key in

        -h|--help)
        help="true"
        shift # past argument
        ;;

        -c|--command)
        command="$2"
        shift # past argument
        ;;


        --default)
        ;;

        *)
        echo "$key=\"$2\""
        key2=$(echo $key|tr --delete -)
        eval "export $key2=\"$2\""

        if [ "$key2" == "peer" ]; then
            if [ "$TASK_SLOT" != "1" ]; then
                #newargs=$newargs" $key $2"
                echo "*** OTHER ZERO NODE"
            else    
                echo "*** FIRST ZERO NODE"
            fi;
        else
            if [ "$key2" == "zero" ]; then
                echo "*** SERVER NODE"
            else
                newargs=$newargs" $key $2"
            fi;
        fi;
        shift
        ;;
    esac
    shift # past argument or value
done

if [ "$help" == "true" ]; then
    echo "********************************************************************************** "
    echo ""
    echo "dgraph [OPTIONS]"
    echo " "
    echo "OPTION:"
    echo ""
    echo "  -h | --help             : This Help"
    echo "  -c | --command          : "
    echo ""
    echo "********************************************************************************** "
    exit 0;
fi



echo "*** Wait for redis to be up"
/dgraph/wait-for-it.sh redis:6379 -t 60

if [ "$command" == "zero" ]; then
    if [ "$TASK_SLOT" = "1" ]; then
        echo "FIRST ZERO";
        port=$(echo  "$peer"|awk '{split($0,p1,":")system("echo "p1[2]) }')
        #echo "$peer" | /dgraph/redi.sh -H redis -P 6379 -s zero
        #echo "$HOSTNAME:$port" | /dgraph/redi.sh -H redis -P 6379 -s zero
        echo "$(hostname -i):$port" | /dgraph/redi.sh -H redis -P 6379 -s zero
    else
        echo "OTHER ZERO";

        zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
        while [ "$zz" == "" ]
        do
            zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
            echo "**** Sleep 10s ...[$error]"
            sleep 10s
        done


        echo "*** Record found $zz"
        peer="$zz"
        newargs=$newargs" --peer $peer"
        echo "*** Wait for $peer to be up"
        /dgraph/wait-for-it.sh $peer -t 30

    fi;
fi;

if [ "$command" == "server" ]; then


    zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
    while [ "$zz" == "" ]
    do
        zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
        echo "**** Sleep 10s ...[$error]"
        sleep 10s
    done
    echo "*** Record found $zz"
    zero="$zz"
    newargs=$newargs" --zero $zero"
    echo "*** Wait for $zero to be up"
    /dgraph/wait-for-it.sh $zero -t 30
fi;


command="dgraph $command $newargs"


echo "COMMAND: `echo ${command}|envsubst`"
env
echo "********************************************************************************** "

echo $command|sh -


