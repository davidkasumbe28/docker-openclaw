#!/usr/bin/env bash

set -e


echo "===================================="
echo " Docker Installation"
echo " OpenClaw Linux Deployment"
echo "===================================="


if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: lancer avec sudo"
    exit 1
fi


# -------------------------------
# OS verification
# -------------------------------

echo ""
echo "[1/8] Verification OS"


if [ -f /etc/os-release ]; then

    . /etc/os-release

    echo "$PRETTY_NAME"

else

    echo "OS non supporte"
    exit 1

fi


case "$ID" in

 ubuntu|debian)
     echo "OS compatible"
     ;;

 *)
     echo "Distribution non testee"
     exit 1
     ;;

esac



# -------------------------------
# Hardware
# -------------------------------

echo ""
echo "[2/8] Verification hardware"


RAM=$(free -m | awk '/Mem:/ {print $2}')

CPU=$(nproc)


echo "CPU : $CPU cores"
echo "RAM : $((RAM/1024)) GB"


if [ "$RAM" -lt 4096 ]; then

    echo "WARNING: RAM inferieure a 4GB"

fi



# -------------------------------
# Dependencies
# -------------------------------

echo ""
echo "[3/8] Installation dependances"


apt update


apt install -y \
ca-certificates \
curl \
gnupg \
lsb-release



# -------------------------------
# Docker repository
# -------------------------------

echo ""
echo "[4/8] Ajout repository Docker"


install -m 0755 -d /etc/apt/keyrings


curl -fsSL \
https://download.docker.com/linux/ubuntu/gpg \
-o /etc/apt/keyrings/docker.asc


chmod a+r /etc/apt/keyrings/docker.asc



echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" \
> /etc/apt/sources.list.d/docker.list



# -------------------------------
# Docker install
# -------------------------------

echo ""
echo "[5/8] Installation Docker"


apt update


apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin



# -------------------------------
# Service
# -------------------------------

echo ""
echo "[6/8] Activation Docker"


systemctl enable docker

systemctl start docker



# -------------------------------
# User docker
# -------------------------------

echo ""
echo "[7/8] Configuration utilisateur"


if [ -n "$SUDO_USER" ]; then

    usermod -aG docker "$SUDO_USER"

    echo "Utilisateur ajoute au groupe docker: $SUDO_USER"

fi



# -------------------------------
# Test
# -------------------------------

echo ""
echo "[8/8] Test"


docker version

docker compose version



echo ""
echo "===================================="
echo " Docker installe"
echo " Reconnexion utilisateur necessaire"
echo "===================================="