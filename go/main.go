package main

import (
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
)

type BenchmarkResult struct {
	DurationMs int64  `json:"duration_ms"`
	Result     uint64 `json:"result"`
}

func benchmarkHandler(c *fiber.Ctx) error {
	start := time.Now()

	var sum uint64
	for i := uint64(1); i <= 100_000_000; i++ {
		sum += i
	}

	duration := time.Since(start).Milliseconds()
	return c.JSON(BenchmarkResult{
		DurationMs: duration,
		Result:     sum,
	})
}

func main() {
	app := fiber.New()

	app.Get("/benchmark", benchmarkHandler)

	port := 8082
	fmt.Printf("🚀 Starting server on :%d\n", port)
	err := app.Listen(fmt.Sprintf(":%d", port))
	if err != nil {
		panic(err)
	}
}
