# solc_docker
docker build file for solc with z3 enabled

## Build
```
docker build . --tag solc_z3
```

## Run

```
docker run --rm -v /home/user/sources:/sources solc_z3 /sources/contract.sol
docker run --rm solc_z3 --help
docker run --rm solc_z3 --version
```


## Documentation
[https://solidity.readthedocs.io/en/v0.6.0/installing-solidity.html#docker](https://solidity.readthedocs.io/en/v0.6.0/installing-solidity.html#docker)
