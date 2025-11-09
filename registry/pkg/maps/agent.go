package maps

import (
	"context"

	mapper "github.com/dipghoshraj/ingress-tunnel/registry/proto"
)

func (rpc *RPCMap) SetAgents(ctx context.Context, req *mapper.AgentConnectionRequest) (*mapper.AgentResponse, error) {
	return &mapper.AgentResponse{}, nil
}
