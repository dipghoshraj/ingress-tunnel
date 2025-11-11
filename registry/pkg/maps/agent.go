package maps

import (
	"context"

	mapper "github.com/dipghoshraj/ingress-tunnel/registry/proto"
)

func (rpc *RPCMap) RegisterAgent(ctx context.Context, req *mapper.AgentConnectionRequest) (*mapper.AgentResponse, error) {
	return &mapper.AgentResponse{}, nil
}

func (rpc *RPCMap) ResolveGatewayForAgent(ctx context.Context, req *mapper.GatewayHandshake) (*mapper.MultipleGateways, error) {

	gateways := rpc.MemStore.GetTopKGateways("global", 10)

	var gatewayResponses []*mapper.GatewayResponse
	for _, gateway := range gateways {
		gatewayResponses = append(gatewayResponses, &mapper.GatewayResponse{
			GatewayId:     gateway.GatewayID,
			GatewayDomain: gateway.GatewayDomain,
			GatewayIp:     gateway.GatewayIP,
		})
	}

	if len(gatewayResponses) == 0 {
		return &mapper.MultipleGateways{
			Gateways: []*mapper.GatewayResponse{},
			Error: &mapper.Error{
				Code:    2,
				Message: "no gateway found",
			},
		}, nil
	}
	return &mapper.MultipleGateways{
		Gateways: gatewayResponses,
		Error:    nil,
	}, nil
}
