#!/usr/bin/env bash
set -e

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm docker docker-compose go rust dotnet-sdk jdk17-openjdk maven

sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Ambiente configurado com sucesso!"
