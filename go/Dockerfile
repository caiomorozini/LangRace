FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod tidy && go mod download
COPY . .
RUN go build -o langrace_go main.go
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/langrace_go .

EXPOSE 8082
CMD ["./langrace_go"]
