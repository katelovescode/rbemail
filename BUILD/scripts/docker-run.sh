#!/bin/bash

# TODO: user input for postgres version?
# TODO: user input for postgres username & db?
# TODO: user input for app image name?

# Usage info
show_help() {
  cat << EOF
  Usage: ${0##*/}
  Builds necessary containers and runs app on specified port (default 8080)

  -h display this help and exit

EOF
}


go() {

  # stop and remove existing containers for this app to avoid conflicts
  FILES=../container-definitions/*
  for f in $FILES
  do
    unset CONTAINER_NAME

    source $f

    # check CONTAINER_NAME against currently running containers.  stop and rm by ID if found
    containerID=$(docker ps -a | grep -w $CONTAINER_NAME | awk '{print $1}')
    if [ -n "$containerID" ] ; then
      echo stopping and removing existing container $CONTAINER_NAME by id $containerID
      docker stop $containerID
      docker rm $containerID
    else
      echo no currently running container found by name $CONTAINER_NAME
    fi
  done

  FILES=../container-definitions/*
  for f in $FILES
  do
    unset GET_ABSOLUTE_LATEST
    unset CONTAINER_NAME
    unset HOSTNAME
    unset LINKS
    unset EXPOSE_PORTS
    unset PORTS
    unset CLEANUP
    unset ENV
    unset ENV_FILE
    unset IMAGE_NAME
    unset VOLUMES
    unset RUN

    source $f

    docker_run_command="docker run "
    docker_run_command+=" --name $CONTAINER_NAME"
    docker_run_command+=" $LINKS"

    if [ "$EXPOSE_PORTS" = true ];
    then
      docker_run_command+=" --publish-all=true"
    else
      for portmapping in $PORTS
      do
        docker_run_command+=" --publish=$portmapping"
      done
    fi

    for vol in $VOLUMES
    do
      docker_run_command+=" --volume $vol"
    done

    if [ -n "$HOSTNAME" ];
    then
      docker_run_command+=" --hostname $HOSTNAME"
    fi

    if [ -n "$ENV" ];
    then
      # split into array by spaces
      env_array=($ENV)
      for this_env in "${env_array[@]}"
      do
        docker_run_command+=" -e $this_env"
      done
    fi

    if [ -n "$ENV_FILE" ];
    then
      docker_run_command+=" --env-file $ENV_FILE"
    fi

    if [ "$CLEANUP" = true ];
    then
      docker_run_command+=" --rm"
    else
      docker_run_command+=" -d"
    fi

    if [ "$GET_ABSOLUTE_LATEST" = true ];
    then
      IMAGE_NAME=` echo $IMAGE_NAME | cut -f1 -d":"`
      LATEST_IMAGE_TAG=`cd .. && git rev-parse HEAD | cut -c1-12`
      IMAGE_NAME+=":$LATEST_IMAGE_TAG"
    fi

    docker_run_command+=" $IMAGE_NAME "
    docker_run_command+=${RUN[@]}

    echo $docker_run_command
    # eval $docker_run_command

    sleep 3
  done

}

OPTIND=1 # Reset is necessary if getopts was used previously in the script. It is a good idea to make this local in a function.
while getopts "hp:" opt; do
  case "$opt" in
    h)
      show_help
      exit 0
      ;;
    p) PORTNUMBER=$OPTARG
      go
      exit 0
      ;;
    '?')
      show_help >&2
      exit 1
      ;;
  esac
done

# if no arguments, just run with PORTNUMBER 8080
PORTNUMBER=8080
go
exit 0
