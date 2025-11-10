package maps

import (
	"context"

	mapper "github.com/dipghoshraj/ingress-tunnel/registry/proto"
)

func (rpc *RPCMap) RegisterGateway(ctx context.Context, req *mapper.GatewayPutRequest) (*mapper.GatewayResponse, error) {
	return &mapper.GatewayResponse{}, nil
}

func (rpc *RPCMap) ResolveGatewayForProxy(ctx context.Context, req *mapper.GatewayProxy) (*mapper.GatewayResponse, error) {
	return &mapper.GatewayResponse{}, nil
}
