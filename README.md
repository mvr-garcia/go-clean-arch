# Go Clean Architecture - Order System

A complete order management system built with Clean Architecture principles in Go, featuring REST API, gRPC, and GraphQL interfaces.

> **Note:** This project is forked from [devfullcycle/goexpert](https://github.com/devfullcycle/goexpert/tree/main/20-CleanArch). We added the list orders functionality across all entry points (REST API, gRPC, and GraphQL).

## Architecture

This project implements Clean Architecture with the following layers:

- **Entity**: Business entities and interfaces
- **Use Cases**: Application business rules
- **Infrastructure**: External interfaces (Database, gRPC, GraphQL, REST API)
- **Events**: Event-driven architecture with RabbitMQ

## Prerequisites

- Go 1.21+
- MySQL
- RabbitMQ
- Protocol Buffers compiler (protoc)
- Docker & Docker Compose (optional)

## Setup

1. **Install dependencies:**
```bash
go mod download
```

2. **Install development tools:**
```bash
go install github.com/google/wire/cmd/wire@latest
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

3. **Configure environment:**

Create a `.env` file in the project root:
```env
DB_DRIVER=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=orders
WEB_SERVER_PORT=8000
GRPC_SERVER_PORT=50051
GRAPHQL_SERVER_PORT=8080
```

4. **Start infrastructure (MySQL & RabbitMQ):**
```bash
docker-compose up -d
```

5. **Generate code:**
```bash
make generate-all
```

6. **Run the application:**
```bash
make run
```

## Makefile Commands

- `make generate-grpc` - Generate Protocol Buffer files
- `make generate-graphql` - Generate GraphQL files
- `make generate-wire` - Generate Wire dependency injection
- `make generate-all` - Generate all files (gRPC, GraphQL, Wire)
- `make run` - Run the application
- `make clean` - Clean generated files

## API Examples

### 1. REST API

**Endpoint:** `http://localhost:8000`

#### Create Order
```bash
curl -X POST http://localhost:8000/order \
  -H "Content-Type: application/json" \
  -d '{
    "id": "order-001",
    "price": 100.50,
    "tax": 10.05
  }'
```

**Response:**
```json
{
  "id": "order-001",
  "price": 100.50,
  "tax": 10.05,
  "final_price": 110.55
}
```

### 2. gRPC

**Endpoint:** `localhost:50051`

#### Create Order

Using `grpcurl`:
```bash
grpcurl -plaintext \
  -d '{
    "id": "order-002",
    "price": 250.75,
    "tax": 25.08
  }' \
  localhost:50051 \
  pb.OrderService/CreateOrder
```

**Response:**
```json
{
  "id": "order-002",
  "price": 250.75,
  "tax": 25.08,
  "finalPrice": 275.83
}
```

#### List Orders

```bash
grpcurl -plaintext \
  localhost:50051 \
  pb.OrderService/ListOrders
```

**Response:**
```json
{
  "orders": [
    {
      "id": "order-001",
      "price": 100.50,
      "tax": 10.05,
      "finalPrice": 110.55
    },
    {
      "id": "order-002",
      "price": 250.75,
      "tax": 25.08,
      "finalPrice": 275.83
    }
  ]
}
```

#### Using Go Client

```go
package main

import (
    "context"
    "log"
    
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    "google.golang.org/protobuf/types/known/emptypb"
    "github.com/mvr-garcia/go-clean-arch/internal/infra/grpc/pb"
)

func main() {
    conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatal(err)
    }
    defer conn.Close()
    
    client := pb.NewOrderServiceClient(conn)
    
    // Create Order
    order, err := client.CreateOrder(context.Background(), &pb.CreateOrderRequest{
        Id:    "order-003",
        Price: 150.00,
        Tax:   15.00,
    })
    if err != nil {
        log.Fatal(err)
    }
    log.Printf("Created: %+v\n", order)
    
    // List Orders
    orders, err := client.ListOrders(context.Background(), &emptypb.Empty{})
    if err != nil {
        log.Fatal(err)
    }
    log.Printf("Orders: %+v\n", orders)
}
```

### 3. GraphQL

**Endpoint:** `http://localhost:8080/query`

**Playground:** `http://localhost:8080` - Interactive GraphQL playground

#### Create Order (Mutation)

```graphql
mutation {
  createOrder(input: {
    id: "order-003"
    Price: 350.00
    Tax: 35.00
  }) {
    id
    Price
    Tax
    FinalPrice
  }
}
```

**Response:**
```json
{
  "data": {
    "createOrder": {
      "id": "order-003",
      "Price": 350.00,
      "Tax": 35.00,
      "FinalPrice": 385.00
    }
  }
}
```

#### List Orders (Query)

```graphql
query {
  listOrders {
    id
    Price
    Tax
    FinalPrice
  }
}
```

**Response:**
```json
{
  "data": {
    "listOrders": [
      {
        "id": "order-001",
        "Price": 100.50,
        "Tax": 10.05,
        "FinalPrice": 110.55
      },
      {
        "id": "order-002",
        "Price": 250.75,
        "Tax": 25.08,
        "FinalPrice": 275.83
      },
      {
        "id": "order-003",
        "Price": 350.00,
        "Tax": 35.00,
        "FinalPrice": 385.00
      }
    ]
  }
}
```

#### Using cURL

**Create Order:**
```bash
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { createOrder(input: { id: \"order-004\", Price: 450.00, Tax: 45.00 }) { id Price Tax FinalPrice } }"
  }'
```

**List Orders:**
```bash
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { listOrders { id Price Tax FinalPrice } }"
  }'
```

## Project Structure

```
.
├── cmd/
│   └── ordersystem/          # Application entry point
├── configs/                   # Configuration management
├── internal/
│   ├── entity/               # Business entities
│   ├── usecase/              # Use cases
│   ├── event/                # Event handlers
│   └── infra/                # Infrastructure layer
│       ├── database/         # Database implementation
│       ├── grpc/             # gRPC server
│       ├── graph/            # GraphQL server
│       └── web/              # REST API
└── pkg/                      # Shared packages
```

## Testing

Run tests:
```bash
go test ./...
```

Run tests with coverage:
```bash
go test -cover ./...
```

## Technologies

- **Web Framework**: Native `net/http`
- **gRPC**: Protocol Buffers
- **GraphQL**: gqlgen
- **Database**: MySQL
- **Message Queue**: RabbitMQ
- **Dependency Injection**: Google Wire
- **Configuration**: Viper

## Events

The system publishes an `OrderCreated` event to RabbitMQ whenever a new order is created. This allows for asynchronous processing and integration with other services.

## License

MIT
