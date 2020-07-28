xhost +local:root 1>/dev/null 2>&1
docker exec \
    -u $USER \
    -it SoapFilm3D_dev \
    /bin/bash
xhost -local:root 1>/dev/null 2>&1