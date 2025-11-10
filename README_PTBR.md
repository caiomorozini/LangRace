## LangRace — Benchmark comparativo de linguagens backend

Este repositório contém implementações equivalentes de um serviço HTTP simples em quatro linguagens modernas (Java, Go, Rust e .NET/C#), empacotadas como containers Docker para permitir comparação controlada de desempenho, footprint e experiência de desenvolvimento.

O foco é comparar o comportamento dos runtimes e das toolchains sob cargas reproduzíveis, minimizando variáveis externas (I/O, banco de dados, lógica complexa).

## Sumário

- Visão geral e objetivos
- Metodologia e conceitos teóricos relevantes
- Estrutura do projeto e notas por linguagem
- Instruções profissionais para executar e medir (Docker / Make / docker-compose)
- Interpretação de resultados e recomendações
- Extensões e integração em CI

## 1. Objetivos

- Comparar latência e throughput entre implementações com mesma API.
- Medir footprint de memória, uso de CPU e tempo de startup.
- Oferecer um fluxo reprodutível para executar benchmarks e agregar resultados.

## 2. Metodologia e conceitos

2.1. Modelo do experimento

Cada serviço expõe endpoints simples (por exemplo `/benchmark` e `/health`) que retornam uma resposta constante. Isso reduz a variabilidade proveniente de I/O e destaca diferenças no runtime e no framework HTTP.

2.2. Métricas importantes

- Latência (p50, p90, p95, p99) — indica comportamento médio e cauda.
- Throughput (requests/sec) — taxa sustentada que a aplicação consegue servir.
- Tempo de startup (cold start vs warm start).
- Uso de memória e CPU ao longo do teste.
- Erros e códigos HTTP inválidos.

2.3. Fontes de ruído e como mitigá-las

- Interferência do sistema host (outros processos, swap, I/O): preferir um host dedicado.
- Warm-up: JIT (JVM), caches e pools costumam precisar de um período de aquecimento antes de medições.
- Variabilidade de rede: se possível, executar benchmark localmente (localhost) para reduzir latência de rede.
- Repetição de runs e agregação estatística (média + desvio padrão).

2.4. Ferramentas recomendadas

- wrk, hey, vegeta ou k6 para geração de carga.
- docker stats, cAdvisor, Prometheus para métricas de uso de recursos.

## 3. Estrutura do repositório

```
LangRace/
├── docker-compose.yml
├── Makefile
├── setup.sh
├── scripts/
│   └── benchmark.sh
├── java/       # implementação Java
├── go/         # implementação Go
├── rust/       # implementação Rust
└── dotnet/     # implementação .NET
```

Cada subdiretório contém o código da aplicação, o `Dockerfile` e os arquivos de build da linguagem correspondente.

## 4. Notas por linguagem

- Java: executa em JVM; considere o aquecimento do JIT e tuning de heap para testes estáveis.
- Go: binários nativos, startup rápido e footprint reduzido; ideal para microsserviços de baixa latência.
- Rust: binários otimizados com baixo uso de memória; builds mais lentos, mas runtime muito eficiente.
- .NET: runtimes modernos (.NET 6/7/8); suporte a AOT/Trim pode reduzir footprint em produção.

## 5. Ports e healthchecks (conforme `docker-compose.yml`)

- `langrace-java`  -> host:8085 -> container:8080 (health: http://localhost:8080/health)
- `langrace-go`    -> host:8082 -> container:8082 (health: http://localhost:8082/health)
- `langrace-rust`  -> host:8083 -> container:8080 (health: http://localhost:8080)
- `langrace-dotnet`-> host:8084 -> container:8084 (health: http://localhost:8084)

Confirme essas portas no arquivo `docker-compose.yml` caso precise alterá-las.

## 6. Requisitos e preparação

Requisitos mínimos no host:

- Docker (recomendado versão estável atual)
- docker-compose (ou Docker Compose v2 integrada)
- make
- Ferramentas de benchmark (recomendadas): `wrk`, `hey`, `vegeta` ou `k6`.

Exemplo (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose make curl
sudo usermod -aG docker $USER
# faça logout/login para aplicar grupo docker
```

O repositório também contém `setup.sh` com instruções para distribuir pacotes em Arch Linux (use com cuidado e privilegios apropriados).

## 7. Como executar (modo profissional e reprodutível)

1) Build & levantar todos os serviços (Makefile usa `docker compose` internamente):

```bash
make up
```

Este comando fará build das imagens e levantará os containers em segundo plano.

2) Verifique o estado dos serviços:

```bash
make ps
docker-compose ps
```

3) Teste rápido de sanity:

```bash
curl -sS http://localhost:8082/health
curl -sS http://localhost:8083/
curl -sS http://localhost:8085/health
curl -sS http://localhost:8084/
```

4) Executar benchmark automatizado (script incluído):

```bash
make benchmark
# ou
bash scripts/benchmark.sh
```

O script presente em `scripts/benchmark.sh` é uma base; revise-o e ajuste parâmetros de concorrência, duração e endpoints conforme o hardware disponível.

Exemplo manual com `wrk` (warm-up + medição):

```bash
# Warm-up (20s)
wrk -t2 -c50 -d20s http://127.0.0.1:8082/benchmark

# Medição (3 runs de 30s)
for i in 1 2 3; do
	wrk -t4 -c200 -d30s --latency http://127.0.0.1:8082/benchmark > results_go_run${i}.txt
done
```

Repita para cada serviço nas portas correspondentes e colete p50/p95/p99 e requests/sec.

## 8. Interpretação e análise

- Foque nos quantis de latência (p95/p99) para avaliar experiência sob stress.
- Se throughput aumentar mas p99 subir muito, avalie GC, locks ou contentions.
- Monitore uso de memória: crescimento linear durante o teste pode indicar vazamento.
- Consulte `docker stats <container>` e logs (`docker-compose logs <service>`) para diagnosticar.

## 9. Integração CI e automação

- Crie jobs que façam build das imagens com tags imutáveis (por commit SHA) e executem benchmarks em runners com recursos controlados.
- Armazene artefatos (resultados CSV/JSON, logs) e gere relatórios automáticos ou dashboards (Prometheus/Grafana).

## 10. Boas práticas para experimentos reproducíveis

- Documente: versão do SO, kernel, versão do Docker, CPU/RAM disponíveis.
- Separe runs de warm-up e runs de medição; repita várias vezes e reporte média + desvio.
- Use container images com tags fixas (não `latest`) ao versionar os resultados.

## 11. Extensões sugeridas

- Adicionar instrumentação (Prometheus exporters) e dashboards (Grafana).
- Incluir mais linguagens/implementações e variações (AOT, builds com flags de otimização).
- Automatizar coleta de métricas do host e do container para análise mais rica.

## 12. Troubleshooting rápido

- Container não sobe: `docker-compose logs <service>`.
- Porta em uso: `ss -ltnp | grep <porta>` e ajuste `docker-compose.yml`.
- Erros de DNS/rede em container: teste com `docker exec -it <container> /bin/sh`.

## 13. Licença e contribuições

Este projeto está licenciado sob a licença MIT. Contribuições são bem-vindas. Abra issues para discutir mudanças grandes antes de PRs.
