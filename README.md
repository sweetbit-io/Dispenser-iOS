# 🍬 Candy Dispenser iOS App

<img width="380" alt="Candy Dispenser iOS app" src="https://user-images.githubusercontent.com/198988/46317920-140e7d80-c5d5-11e8-98fa-dd0566e291ab.png">

## What is this?



## Features

* 

## Project structure

* `Dispenser`
* * `AppDelegate`
* * `Actions/`
* * `State/`
* * `Reducers/`
* * `Service/`
* * `RPC/`
* * `Views/`
* * `ViewControllers/`
* * `Extensions/`

## Regenerate gRPC files

```
export PATH=$PATH:/Users/davidknezic/repos/github.com/grpc/grpc-swift
protoc -I $GOPATH/src/github.com/the-lightning-land/sweetd/sweetrpc $GOPATH/src/github.com/the-lightning-land/sweetd/sweetrpc/rpc.proto --swift_out=Dispenser/RPC/ --swiftgrpc_out=Client=true,Server=false:Dispenser/RPC/
```
