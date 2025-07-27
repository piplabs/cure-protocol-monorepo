-include .env

.PHONY: all test clean coverage format abi lint frontend contracts install build deploy

all: clean install build

# function: generate abi for given contract name
# requires contract name to match the file name in contracts/
define generate_abi
	$(eval $@_CONTRACT_NAME = $(1))
	jq '.abi' out/${$@_CONTRACT_NAME}.sol/${$@_CONTRACT_NAME}.json > abi/${$@_CONTRACT_NAME}.json
endef

# Clean the entire repo
clean:
	@echo "🧹 Cleaning repository..."
	forge clean
	rm -rf out
	rm -rf coverage
	rm -rf node_modules
	rm -rf frontend/node_modules
	rm -rf frontend/.next
	rm -rf frontend/out

# Install all dependencies
install:
	@echo "📦 Installing dependencies..."
	cd contracts && yarn install
	cd frontend && npm install
	forge install

# Build all contracts
build:
	@echo "🔨 Building contracts..."
	cd contracts && forge build
	cd frontend && npm run build

# Run all tests
test:
	@echo "🧪 Running tests..."
	cd contracts && forge test --no-match-path "test/integration/**"
	cd contracts && forge test --match-path "test/integration/**" --fork-url https://aeneid.storyrpc.io/


# Format Solidity code
format:
	@echo "🎨 Formatting code..."
	cd contracts && forge fmt
	cd frontend && npm run lint:fix


# Generate ABIs for core contracts
abi:
	@echo "📄 Generating ABIs..."
	rm -rf abi
	mkdir -p abi
	@$(call generate_abi,"AscCurate")
	@$(call generate_abi,"AscCurateFactory")
	@$(call generate_abi,"AscStaking")
	@$(call generate_abi,"IAscCurate")
	@$(call generate_abi,"IAscCurateFactory")
	@$(call generate_abi,"IAscFundRaising")
	@$(call generate_abi,"IAscStaking")

# Lint Solidity code
lint:
	@echo "🔍 Linting code..."
	cd contracts && npx solhint contracts/**/*.sol
	cd frontend && npm run lint

# Start local anvil node
anvil:
	@echo "🚀 Starting local anvil node..."
	anvil -m 'test test test test test test test test test test test junk'

# Start frontend development server
dev:
	@echo "🌐 Starting frontend development server..."
	cd frontend && npm run dev

# Deploy contracts (requires .env with PK and ADMIN)
deploy:
	@echo "🚀 Deploying contracts..."
	cd contracts && forge script script/LaunchCurateWithIpRegistration.s.sol --rpc-url https://aeneid.storyrpc.io/ --broadcast --verify

# Setup development environment
setup: clean install build abi
	@echo "✅ Development environment setup complete!"

# Quick development workflow
dev-workflow: clean install build dev
	@echo "🚀 Development workflow started!"

# Production build
prod: clean install build
	@echo "🏭 Production build complete!"

