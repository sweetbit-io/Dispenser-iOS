# Candy Dispenser iOS App

## Regenerate gRPC files

```
export PATH=$PATH:/Users/davidknezic/repos/github.com/grpc/grpc-swift
protoc -I $GOPATH/src/github.com/the-lightning-land/sweetd/sweetrpc $GOPATH/src/github.com/the-lightning-land/sweetd/sweetrpc/rpc.proto --swift_out=Dispenser/RPC/ --swiftgrpc_out=Client=true,Server=false:Dispenser/RPC/
```
