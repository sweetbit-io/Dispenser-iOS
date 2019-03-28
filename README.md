# 🍬 Candy Dispenser iOS app

[![license](https://img.shields.io/github/license/the-lightning-land/Dispenser-iOS.svg)](https://github.com/the-lightning-land/Dispenser-iOS/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/the-lightning-land/Dispenser-iOS.svg)](https://github.com/the-lightning-land/Dispenser-iOS/releases)

> 📱 Pair and control your Bitcoin-enabled candy dispenser

<img width="320" alt="Candy Dispenser iOS Pairing" src="https://user-images.githubusercontent.com/198988/48008452-01c6b880-e11a-11e8-8023-484681b0fd8a.png"><img width="320" alt="Candy Dispenser iOS Overview" src="https://user-images.githubusercontent.com/198988/48008450-01c6b880-e11a-11e8-88be-47aa3b3ec64d.png">

## Intro

...

## Run

```
gem install xcodeproj
```

```
carthage bootstrap --platform ios
```

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
