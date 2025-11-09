package maps

import (
	mapper "github.com/dipghoshraj/ingress-tunnel/registry/proto"
)

type RPCMap struct {
	mapper.UnimplementedMapsServer
}

var _ mapper.MapsServer = (*RPCMap)(nil)

func NewRPCMap() *RPCMap {
	return &RPCMap{}
}
