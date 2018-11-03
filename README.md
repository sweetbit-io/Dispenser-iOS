# 🍬 Candy Dispenser iOS app

[![license](https://img.shields.io/github/license/the-lightning-land/Dispenser-iOS.svg)](https://github.com/the-lightning-land/Dispenser-iOS/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/the-lightning-land/Dispenser-iOS.svg)](https://github.com/the-lightning-land/Dispenser-iOS/releases)

> 📱 Pair and control your Bitcoin-enabled candy dispenser

<img width="380" alt="Candy Dispenser iOS app" src="https://user-images.githubusercontent.com/198988/46317920-140e7d80-c5d5-11e8-98fa-dd0566e291ab.png">

## Intro

...

## Features

...

## App structure

```
AppCoordinator
|____ PairingCoordinator
|____ DispenserCoordinator
| |____ UpdateCoordinator
| |____ RemoteNodeCoordinator
```

## Regenerate gRPC files

```
export PATH=$PATH:/Users/davidknezic/repos/github.com/grpc/grpc-swift
protoc -I $GOPATH/src/github.com/the-lightning-land/sweetd/sweetrpc $GOPATH/src/github.com/the-lightning-land/sweetd/sweetrpc/rpc.proto --swift_out=Dispenser/RPC/ --swiftgrpc_out=Client=true,Server=false:Dispenser/RPC/
```
