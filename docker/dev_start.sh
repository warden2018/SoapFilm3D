#!/usr/bin/env bash

SoapFilm3D_dev_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"


function local_volumes() {
    # slam root
    volumes="-v $SoapFilm3D_dev_ROOT_DIR:/SoapFilm3D_dev"
    case "$(uname -s)" in
        Linux)
            volumes="${volumes} -v /dev:/dev \
                                -v /media:/media \
                                -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
                                -v /etc/localtime:/etc/localtime:ro \
                                -v /usr/src:/usr/src \
                                -v /lib/modules:/lib/modules"
            ;;
        Darwin)
            # MacOS has strict limitations on mapping volumes.
            chmod -R a+wr ~/.cache/bazel
            ;;
    esac
    echo "${volumes}"
}

function stop_containers()
{
running_containers=$(docker ps --format "{{.Names}}")

for i in ${running_containers[*]}
do
  if [[ "$i" =~ apollo_* ]];then
    printf %-*s 70 "stopping container: $i ..."
    docker stop $i > /dev/null
    if [ $? -eq 0 ];then
      printf "\033[32m[DONE]\033[0m\n"
    else
      printf "\033[31m[FAILED]\033[0m\n"
    fi
  fi
done
}


function main(){
    local display=""
    if [[ -z ${DISPLAY} ]];then
        display=":0"
    else
        display="${DISPLAY}"
    fi

    #docker image 
    if [ -z "${DOCKER_REPO}" ]; then
    DOCKER_REPO=ubuntu
    fi

    VERSION="16.04_SoapFilm3D"

    IMG=${DOCKER_REPO}:$VERSION

    echo "docker image is:"
    echo $IMG
    #user id
    USER_ID=$(id -u)
    GRP=$(id -g -n)
    GRP_ID=$(id -g)
    #USER="root"
    echo "Start docker container based on local image : $IMG"
    echo "Starting docker container \"SoapFilm3D_dev\" ..."

    docker run -it \
    -d \
    --privileged \
    --name SoapFilm3D_dev \
    -e DISPLAY=$display \
    -e DOCKER_USER=$USER \
    -e USER=$USER \
    -e DOCKER_USER_ID=$USER_ID \
    -e DOCKER_GRP="$GRP" \
    -e DOCKER_GRP_ID=$GRP_ID \
    -e DOCKER_IMG=$IMG \
    -e QT_X11_NO_MITSHM=1  \
    $(local_volumes) \
    --hostname in_dev_docker \
    --shm-size 2G \
    --pid host \
    --net host \
    -w /SoapFilm3D_dev \
    $IMG \
    /bin/bash

    if [ $? -ne 0 ];then
        echo "Failed to start docker container \"SoapFilm3D_dev\" based on image: $IMG"
        exit 1
    fi

    if [ "${USER}" != "root" ]; then
        docker exec SoapFilm3D_dev bash -c '/SoapFilm3D_dev/docker/docker_adduser.sh'
    fi
}

main


