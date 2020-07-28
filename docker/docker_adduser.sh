#!/usr/bin/env bash

ARCH=$(uname -m)

addgroup --gid "$DOCKER_GRP_ID" "$DOCKER_GRP"
adduser --disabled-password --force-badname --gecos '' "$DOCKER_USER" \
    --uid "$DOCKER_USER_ID" --gid "$DOCKER_GRP_ID" 2>/dev/null
usermod -aG sudo "$DOCKER_USER"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
cp -r /etc/skel/. /home/${DOCKER_USER}

if [ "$ARCH" == 'aarch64' ]; then
  echo "
export PATH=\$PATH:/usr/lib/java/bin:/apollo/scripts:/usr/local/miniconda2/bin/
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib:/usr/lib/aarch64-linux-gnu/tegra:/usr/local/ipopt/lib:/usr/local/cuda/lib64/stubs
export NVBLAS_CONFIG_FILE=/usr/local/cuda
if [ -e "/apollo/scripts/apollo_base.sh" ]; then 
  source /apollo/scripts/apollo_base.sh; 
fi
ulimit -c unlimited" >> /home/${DOCKER_USER}/.bashrc
  source /home/${DOCKER_USER}/.bashrc
else
  echo '
  export PATH=${PATH}:/apollo/scripts:/usr/local/miniconda2/bin
   if [ -e "/apollo/scripts/apollo_base.sh" ]; then
    source /apollo/scripts/apollo_base.sh
  fi
   ulimit -c unlimited
   export NVBLAS_CONFIG_FILE=/apollo/nvblas.conf
  ' >> "/home/${DOCKER_USER}/.bashrc"
fi
echo '
genhtml_branch_coverage = 1
lcov_branch_coverage = 1
' > "/home/${DOCKER_USER}/.lcovrc"

chown -R ${DOCKER_USER}:${DOCKER_GRP} "/home/${DOCKER_USER}"

