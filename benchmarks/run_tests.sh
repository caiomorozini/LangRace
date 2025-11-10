#!/bin/bash
services=("go" "rust" "dotnet" "java")

for s in "${services[@]}"; do
  echo "Testing $s..."
  hey -n 1000 -c 50 http://localhost:$(grep $s docker-compose.yml | grep ports | awk -F: '{print $2}' | cut -d'"' -f2)/predict \
    > results_${s}.txt
done
