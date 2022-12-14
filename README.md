# Dockerized Plutus Development Environment
Contains required tools and libraries for building Cardano Plutus Scripts.
Start the cardano-node and plutus-dev-env containers for the preprod test network by running the ```run-preprod``` script.
Supported networks: mainnet, preprod, preview, vasil.
```run-preprod-full``` runs the ```docker-compose-full.yml``` file, which starts (cardano-node)[https://github.com/input-output-hk/cardano-node], postgres, (ogmios)[https://github.com/CardanoSolutions/ogmios], (cardano-graphql)[https://github.com/input-output-hk/cardano-graphql], (cardano-db-sync)[https://github.com/input-output-hk/cardano-db-sync], hasura and plutus-dev-env.

The workspace directory contains the code for your plutus project, to begin with its loaded with a (plutus-starter-kit)[https://github.com/txpipe/plutus-starter-kit] example

## Connecting to Plutus Development Environment
To get a commandline interface type:
```
docker exec -it <ContainerName> bash
```

or use VS Code "Remote Window" > "Attach to Running Container" to attach to a running container.

## Building
To build the plutus script run the following commands from the plutus-starter-kit directory:
```
cabal update
cabal run plutus-starter-kit -- assets/contract.plutus
```
Building the first time will take some time.

## Configs
If you run the full environment with postgres container, you will have to modify the postgres settings user in config/postgres/.

## Obtaining test ADA
To obtain test ADA you can use the (Faucet)[https://docs.cardano.org/cardano-testnet/tools/faucet].