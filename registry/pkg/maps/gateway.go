package maps

import (
	"context"

	mapper "github.com/dipghoshraj/ingress-tunnel/registry/proto"
)

func (rpc *RPCMap) SetGateway(ctx context.Context, req *mapper.GatewayPutRequest) (*mapper.GatewayResponse, error) {
	return &mapper.GatewayResponse{}, nil
}

func (rpc *RPCMap) GetRegionalGateway(ctx context.Context, req *mapper.GatewayHandshak) (*mapper.GatewayResponse, error) {
	return &mapper.GatewayResponse{}, nil
}

func (rpc *RPCMap) GetProxyGateway(ctx context.Context, req *mapper.GatewayProxy) (*mapper.GatewayResponse, error) {
	return &mapper.GatewayResponse{}, nil
}
