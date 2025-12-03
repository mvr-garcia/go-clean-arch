PROTO_DIR=internal/infra/grpc/protofiles
OUT_DIR=internal/infra/grpc/pb/

# Generate Go files from proto definitions
generate-grpc:
	@echo "Generating Protocol Buffer files..."
	protoc --go_out=. --go-grpc_out=. internal/infra/grpc/protofiles/*.proto
	@echo "Generation completed!"

# Clean generated Protocol Buffer files
clean:
	@echo "Cleaning generated files..."
	rm -f internal/infra/grpc/pb/*.pb.go
	@echo "Clean completed!"

# Generate GraphQL files
generate-graphql:
	go run github.com/99designs/gqlgen generate -v
