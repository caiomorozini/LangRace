#!/usr/bin/env bash
set -e

# ----------------------------------------------------------
# LangRace Benchmark Script
# ----------------------------------------------------------
# Queries all microservices (Java, Go, Rust, and .NET)
# at the /benchmark endpoint and compares the results.
#
# Each endpoint is expected to return a JSON:
#   { "result": <numeric_value> }
# ----------------------------------------------------------

# Definition of services and their ports
declare -A services=(
  [".net"]=8084
  ["java"]=8085
  ["go"]=8082
  ["rust"]=8083
)

# Cabeçalho
echo "==========================================="
echo "           LangRace Benchmark Tool          "
echo "==========================================="
printf "%-10s | %-20s | %-10s | %-10s\n" "Service" "Result" "Status" "Duration (ms)"
echo "-------------------------------------------"

# Loop through services
for service in "${!services[@]}"; do
  port=${services[$service]}
  url="http://localhost:${port}/benchmark"

  # Make the request and capture response + status code
  response=$(curl -s -w "\n%{http_code}" "$url" || echo -e "{}\n000")
  json=$(echo "$response" | head -n 1)
  code=$(echo "$response" | tail -n 1)

  if [ "$code" -eq 200 ]; then
    # Extract the value of the "result" and "duration_ms" fields
    result=$(echo "$json" | grep -oE '"result"\s*:\s*[-0-9.]+' | awk -F':' '{print $2}' | tr -d ' ')
    duration=$(echo "$json" | grep -oE '"duration_ms"\s*:\s*[-0-9.]+' | awk -F':' '{print $2}' | tr -d ' ')
    printf "%-10s | %-20s | %-10s | %-10s\n" "$service" "$result" "$code" "$duration"
  else
    printf "%-10s | %-20s | %-10s | %-10s\n" "$service" "N/A" "$code" "N/A"
  fi
done

echo "-------------------------------------------"
echo "Benchmark concluído com sucesso!"
