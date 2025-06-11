-include .env

.PHONY: all test clean coverage typechain format abi

all: clean install build

# function: generate abi for given contract name (key)
# requires contract name to match the file name
define generate_abi
    $(eval $@_CONTRACT_NAME = $(1))
		$(eval $@_CONTRACT_PATH = $(2))
		forge inspect --json --optimize --optimizer-runs 20000 contracts/${$@_CONTRACT_PATH}/${$@_CONTRACT_NAME}.sol:${$@_CONTRACT_NAME} abi > abi/${$@_CONTRACT_NAME}.json
endef

# Clean the repo
forge-clean :; forge clean
clean :; npx hardhat clean

# Remove modules
forge-remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :
	yarn install 

# Update Dependencies
forge-update :; forge update

forge-build :; forge build
build :; npx hardhat compile

test :; forge test --ffi

snapshot :; forge snapshot

slither :; slither ./contracts

# glob doesn't work for nested folders, so we do it manually
format:
	npx prettier --write contracts

# generate forge coverage on pinned mainnet fork
# process lcov file, ignore test, script, and contracts/mocks folders
# generate html report from lcov.info (ignore "line ... has branchcov but no linecov data" error)
coverage:
	mkdir -p coverage
	forge coverage --report lcov --no-match-path "test/foundry/invariants/*"
	lcov --remove lcov.info -o coverage/lcov.info 'test/*' 'script/*' --rc lcov_branch_coverage=1
	genhtml coverage/lcov.info -o coverage --rc lcov_branch_coverage=1

abi:
	rm -rf abi
	mkdir -p abi
	@$(call generate_abi,"IAscCurate","./interfaces")
	@$(call generate_abi,"IAscCurateFactory","./interfaces")
	@$(call generate_abi,"IAscFundRaising","./interfaces")
	@$(call generate_abi,"IAscStaking","./interfaces")


typechain :; npx hardhat typechain

# solhint should be installed globally
lint :; npx solhint contracts/**/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'
