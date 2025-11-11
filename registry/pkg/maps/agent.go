package maps

import (
	"context"

	mapper "github.com/dipghoshraj/ingress-tunnel/registry/proto"
)

func (rpc *RPCMap) RegisterAgent(ctx context.Context, req *mapper.AgentConnectionRequest) (*mapper.AgentResponse, error) {
	return &mapper.AgentResponse{}, nil
}

func (rpc *RPCMap) ResolveGatewayForAgent(ctx context.Context, req *mapper.GatewayHandshake) (*mapper.GatewayResponse, error) {

	gateways := rpc.MemStore.GetTopKGateways("global", 1)
	if len(gateways) > 0 {
		gateway := gateways[0]
		return &mapper.GatewayResponse{
			GatewayId:     gateway.GatewayID,
			GatewayDomain: gateway.GatewayDomain,
			GatewayIp:     gateway.GatewayIP,
		}, nil
	}
	return &mapper.GatewayResponse{
		Error: &mapper.Error{
			Code:    2,
			Message: "no gateway found",
		},
	}, nil
}
