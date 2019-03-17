#!/bin/bash

_start_jenkins_master(){
  # start jenkins docker compose file
  # wait for docker compose healthy or not
  # input: docker-compose file path, container name
  echo "docker-compose path: $1"
  echo "docker container name: $2"
  echo "startup timeout: $3"

  docker_compose_path=$1
  docker_container_name=$2
  startup_timeout=$3

  export DOCKER_CONTAINER_NAME=$docker_container_name
  export STARTUP_TIMEOUT=$startup_timeout
  docker-compose -f $docker_compose_path up -d
  NEXT_WAIT_TIME=0
  CONTAINER_HEALTH_CHECK=$(docker inspect -f '{{json .State.Health.Status}}' $docker_container_name | tr -d \" )

  while [[ ${CONTAINER_HEALTH_CHECK} == "starting" ]];  do
    echo "Health status is ${CONTAINER_HEALTH_CHECK}"
    echo "Waits in ${NEXT_WAIT_TIME} s..."
    CONTAINER_HEALTH_CHECK=$(docker inspect -f '{{json .State.Health.Status}}' $docker_container_name | tr -d \")
    ((NEXT_WAIT_TIME++))
    sleep 1
  done;

  echo "Final container $docker_container_name health is $CONTAINER_HEALTH_CHECK"
  if [ ${CONTAINER_HEALTH_CHECK} == "healthy" ]; then
    echo "Start container $docker_container_name success."
  else
    echo "Fail to start container $docker_container_name"
    exit 1
  fi
}

_stop_jenkins_master(){
  # stop jenkins docker compose file
  # input: docker-compose file path
  echo "docker-compose path: $1"
  docker_compose_path=$1
  docker_container_name=$2

  export DOCKER_CONTAINER_NAME=$docker_container_name
  docker-compose -f $docker_compose_path down

}

_monitor_jenkins_master(){
  # check if jenkins master docker container is healthy or not
  # input: container name
  echo "docker container name: $1"
  docker_container_name=$1
  CONTAINER_HEALTH_CHECK=$(docker inspect -f '{{json .State.Health.Status}}' $docker_container_name | tr -d \")
  if [ ${CONTAINER_HEALTH_CHECK} == "healthy" ]; then
    echo "Container $docker_container_name is healthy."
  else
    echo "Container $docker_container_name is unhealthy."
    exit 1
  fi

}


#Declare action
action=""
docker_compose_path=""
docker_container_name=""
startup_timeout=""

action_command=$1

# Transform remaining options from long options to short ones
while [ -n "$1" ]; do
  case "$1" in
    "--docker-compose")
      docker_compose_path=$2; shift;;
    "--container-name")
      docker_container_name=$2; shift;;
    "--startup-timeout")
      startup_timeout=$2; shift;;
    *)
      shift;;
  esac
done

case "$action_command" in
  "--start")
    _start_jenkins_master $docker_compose_path $docker_container_name $startup_timeout;;
  "--monitor")
    _monitor_jenkins_master $docker_container_name;;
  "--stop")
    _stop_jenkins_master $docker_compose_path $docker_container_name;;
  *)
    echo "Error. First arguments must be --monitor or --start or --stop"
    Exit 1
esac

