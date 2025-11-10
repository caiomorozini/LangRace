package com.polypredict;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@SpringBootApplication
@RestController
public class Application {

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("status", "ok", "language", "Java");
    }

    @GetMapping("/benchmark")
    public Map<String, Object> benchmark() {
        long startTime = System.nanoTime();
        long sum = 0;
        for (long i = 0; i < 100_000_000L; i++) {
            sum += i;
        }
        long endTime = System.nanoTime();
        long durationMs = (endTime - startTime) / 100_000_000;
        return Map.of("language", "Java", "duration_ms", durationMs, "result", sum);
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
