use axum::{routing::get, Router, Json};
use std::time::Instant;
use serde::Serialize;

#[derive(Serialize)]
struct BenchmarkResult {
    duration_ms: u128,
    result: u64,
}

async fn benchmark() -> Json<BenchmarkResult> {
    let start = Instant::now();
    let mut sum: u64 = 0;

    for i in 1..=10_000_000 {
        sum = sum.wrapping_add(i);
    }

    let duration = start.elapsed().as_millis();
    Json(BenchmarkResult {
        duration_ms: duration,
        result: sum,
    })
}

#[tokio::main]
async fn main() {
    std::env::set_var("RUST_BACKTRACE", "1");
    let app = Router::new().route("/benchmark", get(benchmark));

    let addr: std::net::SocketAddr = "0.0.0.0:8080".parse().unwrap();

    println!("🚀 Starting server on {}", addr);
    use std::io::Write;
    std::io::stdout().flush().unwrap(); // força flush imediato

    axum::serve(
        tokio::net::TcpListener::bind(addr).await.unwrap(),
        app,
    )
    .await
    .unwrap();
}
