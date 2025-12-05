PROTO_DIR=internal/infra/grpc/protofiles
OUT_DIR=internal/infra/grpc/pb/

# Generate Go files from proto definitions
generate-grpc:
	protoc --go_out=. --go-grpc_out=. internal/infra/grpc/protofiles/*.proto

# Generate GraphQL files
generate-graphql:
	go run github.com/99designs/gqlgen generate -v

# Generate Wire dependency injection
generate-wire:
	cd cmd/ordersystem && wire

# Run the application
run:
	go run cmd/ordersystem/main.go cmd/ordersystem/wire_gen.go

up:
	@echo "Starting containers..."
	docker compose up -d

# Stop containers
down:
	@echo "Stopping containers..."
	docker-compose down
