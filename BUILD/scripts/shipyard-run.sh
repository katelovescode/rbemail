#!/bin/bash

SHIPYARD_CLI=$PWD/shipyard-cli.sh
DOCKER_STAGING=docker-staging.dnc.org

# Usage info
show_help() {
  cat << EOF
  Usage: ${0##*/} [-d DATAPATH]
  Wrapper for Shipyard CLI to run containers on docker-staging server

  -h display this help and exit

  -d DATAPATH

EOF
}


go() {

  # destroy containers being replaced
  FILES=../container-definitions/*
  for f in $FILES
  do
    unset CONTAINER_NAME

    source $f

    # check CONTAINER_NAME against currently running containers.  destroy by ID if found
    containerID=$($SHIPYARD_CLI shipyard containers | grep -w $CONTAINER_NAME | awk '{print $1}')
    if [ -n "$containerID" ] ; then
      echo destroying existing container $CONTAINER_NAME by id $containerID
      $SHIPYARD_CLI shipyard destroy $containerID
    else
      echo no currently running container found by name $CONTAINER_NAME
    fi
  done

  # ssh to docker-staging and make sure that the images we need are available
  # (this is a workaround for shipyard's inability to use docker's auth to
  # download images from private repositories)
  FILES=../container-definitions/*
  for f in $FILES
  do
    unset IMAGE_NAME
    unset GET_ABSOLUTE_LATEST
 
    source $f

    if [ "$GET_ABSOLUTE_LATEST" = true ];
    then
      IMAGE_NAME=` echo $IMAGE_NAME | cut -f1 -d":"`
      LATEST_IMAGE_TAG=`cd .. && git rev-parse HEAD | cut -c1-12`
      IMAGE_NAME+=":$LATEST_IMAGE_TAG"
    fi

    echo "ssh $DOCKER_STAGING docker pull $IMAGE_NAME"
    ssh $DOCKER_STAGING docker pull $IMAGE_NAME

  done

  # execute bash script that defines necessary variables (this is the only argument)
  FILES=../container-definitions/*
  for f in $FILES
  do
    unset GET_ABSOLUTE_LATEST 
    unset CONTAINER_NAME
    unset HOSTNAME
    unset LINKS
    unset EXPOSE_PORTS 
    unset PORTS 
    unset ENV
    unset ENV_FILE
    unset IMAGE_NAME
    unset VOLUMES
    unset RUN

    source $f

    if [ "$GET_ABSOLUTE_LATEST" = true ];
    then
      IMAGE_NAME=` echo $IMAGE_NAME | cut -f1 -d":"`
      LATEST_IMAGE_TAG=`cd .. && git rev-parse HEAD | cut -c1-12`
      IMAGE_NAME+=":$LATEST_IMAGE_TAG"
    fi
    
    shipyard_command="$SHIPYARD_CLI shipyard run --container-name $CONTAINER_NAME "
    shipyard_command+="--name $IMAGE_NAME "
    # shipyard_command+="--cpus 0.1 "
    # shipyard_command+="--memory 32 "
    shipyard_command+="--domain dnc.org "
    shipyard_command+="--label staging "
    # shipyard_command+="--pull "
    shipyard_command+="$LINKS "   # if links are defined, they'll be added here

    # if [ "$RESTART" == "temporary" ];
    # then
      # shipyard_command+="--restart 'no' "
      # shipyard_command+="--type unique "
    # else
      # shipyard_command+="--restart 'no' "
      # shipyard_command+="--type service "
    # fi

    # if the container has exposed ports turned on, publish them all
    if [ "$EXPOSE_PORTS" = true ];
    then
      shipyard_command+="--publish "
    else
      for portmapping in $PORTS
      do
        shipyard_command+="--port tcp/0.0.0.0:$portmapping "
      done
    fi

    for vol in ${VOLUMES[@]}
    do
      # if DATAPATH is specified, use it to replace the host path in volume configuration
      IFS=$' '
      volArray=(${vol//:/ })
      if [ -n "$DATAPATH" ] ; then
        volArray[0]=$DATAPATH
      fi
      shipyard_command+="--vol ${volArray[0]}:${volArray[1]} "
    done

    # add in HOSTNAME, if available
    if [ -n "$HOSTNAME" ];
    then
      shipyard_command+="--hostname $HOSTNAME "
    fi

    # add in environment variables, if available
    if [ -n "$ENV" ];
    then
      # split into array by spaces
      env_array=($ENV)
      for this_env in "${env_array[@]}"
      do
        shipyard_command+="--env $this_env "
      done
    fi

    # if an ENV_FILE is specified, loop through and add one at a time 
    # (it looks like there's no env-file support in shipyard CLI yet!)
    if [ -n "$ENV_FILE" ];
    then
      while read env; do
        shipyard_command+="--env \"$env\" "
      done <$ENV_FILE
    fi

    IFS=$'\n'
    for arg in ${RUN[@]}
    do
      shipyard_command+="--arg $arg "
    done

    echo $shipyard_command
    output=$(eval $shipyard_command)
    if echo "$output" | grep -q "error running container"; then
        # there was an error running the container (based on output)
        # explicitlye exit with a non-zero code to make sure that Jenkins knows
        # that there was a problem
        exit 1
    fi


    sleep 5
  done

}

OPTIND=1 # Reset is necessary if getopts was used previously in the script. It is a good idea to make this local in a function.
while getopts "hc:d:" opt; do
  case "$opt" in
    h)
      show_help
      exit 0
      ;;
    d) DATAPATH=$OPTARG
      ;;
    '?')
      show_help >&2
      exit 1
      ;;
  esac
done

go
exit 0

