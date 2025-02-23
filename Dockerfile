# Stage 1: Build Stage
FROM golang:1.20-alpine AS builder

# Set working directory inside container
WORKDIR /app

# Install build dependencies (build tools)
RUN apk add --no-cache make gcc musl-dev

# Copy go.mod and go.sum to leverage cache for dependencies
COPY go.mod go.sum ./

# Install dependencies
RUN go mod tidy

# Copy the entire application code into the container
COPY . .

# Build the Go binary for Linux architecture
RUN GOOS=linux GOARCH=amd64 go build -o app .

# Stage 2: Production Stage
FROM alpine:latest

# Install runtime dependencies (e.g., ca-certificates)
RUN apk add --no-cache ca-certificates

# Set the working directory inside container
WORKDIR /app

# Copy the Go binary from the build stage
COPY --from=builder /app/app .

# Expose the port the application will run on
EXPOSE 8000

# Run the Go binary when the container starts
CMD ["./app"]