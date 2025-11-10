## LangRace — Comparative backend language benchmark

This repository contains equivalent implementations of a simple HTTP service in four modern languages (Java, Go, Rust and .NET/C#), packaged as Docker containers to allow controlled comparison of performance, resource footprint and developer experience.

The goal is to compare runtime and toolchain behavior under reproducible load, minimizing external variables (I/O, databases, complex business logic).

Contents

- Overview and objectives
- Methodology and theoretical concepts
- Project structure and per-language notes
- Professional instructions to run and measure (Docker / Make / docker-compose)
- How to interpret results and recommendations
- Extensions and CI integration

1. Objectives

- Compare latency and throughput between implementations exposing the same API.
- Measure memory footprint, CPU usage and startup time.
- Provide a reproducible flow to run benchmarks and aggregate results.

2. Methodology and concepts

2.1 Experiment model

Each service exposes simple endpoints (for example `/benchmark` and `/health`) that return a constant response. This reduces variability from I/O and highlights differences in the runtime and HTTP frameworks.

2.2 Key metrics

- Latency (p50, p90, p95, p99) — typical and tail behavior.
- Throughput (requests/sec) — sustained serving capacity.
- Startup time (cold start vs warm start).
- Memory and CPU usage during the test.
- Errors and non-200 responses.

2.3 Noise sources and mitigation

- Host interference (other processes, swap, I/O): prefer a dedicated host.
- Warm-up: JIT (JVM), caches and pools usually require an initial warm-up before measurement.
- Network variability: run benchmarks locally (localhost) when possible to reduce network latency.
- Repeat runs and aggregate statistics (mean and standard deviation).

2.4 Recommended tools

- wrk, hey, vegeta or k6 for load generation.
- docker stats, cAdvisor or Prometheus for resource metrics.

3. Repository structure

```
LangRace/
├── docker-compose.yml
├── Makefile
├── setup.sh
├── scripts/
│   └── benchmark.sh
├── java/       # Java implementation
├── go/         # Go implementation
├── rust/       # Rust implementation
└── dotnet/     # .NET implementation
```

Each language folder contains application code, a `Dockerfile` and language-specific build files.

4. Language notes

- Java: runs on the JVM; consider JIT warm-up and heap tuning for stable tests.
- Go: produces native binaries with fast startup and low footprint.
- Rust: optimized native binaries with low memory usage; longer build times.
- .NET: modern runtimes (.NET 6/7/8) with AOT/Trim options to reduce footprint.

5. Ports and healthchecks (from `docker-compose.yml`)

- `langrace-java`  -> host:8085 -> container:8080 (health: http://localhost:8080/health)
- `langrace-go`    -> host:8082 -> container:8082 (health: http://localhost:8082/health)
- `langrace-rust`  -> host:8083 -> container:8080 (health: http://localhost:8080)
- `langrace-dotnet`-> host:8084 -> container:8084 (health: http://localhost:8084)

Double-check the `docker-compose.yml` file if you need to customize ports.

6. Requirements and preparation

Minimum host requirements:

- Docker (stable release)
- docker-compose (or Docker Compose v2)
- make
- Benchmarking tools (recommended): `wrk`, `hey`, `vegeta` or `k6`.

Example for Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose make curl
sudo usermod -aG docker $USER
# log out and log in to apply docker group
```

The repository includes `setup.sh` for Arch Linux package installation (use with care and appropriate privileges).

7. How to run (professional and reproducible)

1) Build & bring up all services (Makefile uses `docker compose`):

```bash
make up
```

This command builds images and starts containers in detached mode.

2) Verify service status:

```bash
make ps
docker-compose ps
```

3) Quick sanity checks:

```bash
curl -sS http://localhost:8082/health
curl -sS http://localhost:8083/
curl -sS http://localhost:8085/health
curl -sS http://localhost:8084/
```

4) Run automated benchmark (included script):

```bash
make benchmark
# or
bash scripts/benchmark.sh
```

The included script is a baseline; review and adjust concurrency, duration and endpoints according to your hardware.

Manual example with `wrk` (warm-up + measurement):

```bash
# Warm-up (20s)
wrk -t2 -c50 -d20s http://127.0.0.1:8082/benchmark

# Measurement (3 runs of 30s)
for i in 1 2 3; do
  wrk -t4 -c200 -d30s --latency http://127.0.0.1:8082/benchmark > results_go_run${i}.txt
done
```

Repeat for each service and collect p50/p95/p99 and requests/sec.

8. Interpretation and analysis

- Focus on latency quantiles (p95/p99) to evaluate tail behavior under stress.
- If throughput increases but p99 rises significantly, investigate GC, locks or contention.
- Monitor memory: linear growth during tests may indicate leaks.
- Use `docker stats <container>` and `docker-compose logs <service>` for diagnostics.

9. CI integration and automation

- Create CI jobs that build images with immutable tags (commit SHA) and run benchmarks on dedicated runners.
- Store artifacts (CSV/JSON results, logs) and generate automated reports or dashboards (Prometheus/Grafana).

10. Reproducible experiment best practices

- Document OS version, kernel, Docker version, CPU/RAM available.
- Separate warm-up runs from measurement runs and repeat multiple times; report mean + standard deviation.
- Use pinned image tags (avoid `latest`) when archiving results.

11. Suggested extensions

- Add instrumentation (Prometheus exporters) and Grafana dashboards.
- Include more languages/implementations and variations (AOT, optimization flags).
- Automate host and container metric collection for richer analysis.

12. Quick troubleshooting

- Container fails to start: `docker-compose logs <service>`.
- Port already in use: `ss -ltnp | grep <port>` and update `docker-compose.yml`.
- Network/DNS issues inside container: `docker exec -it <container> /bin/sh` to debug.

13. License and contributions

This project is licensed under the MIT license. Contributions are welcome — please open an issue to discuss large changes before submitting a PR.
