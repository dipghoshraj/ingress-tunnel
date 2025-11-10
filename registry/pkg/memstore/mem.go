package memstore

import (
	"sync"

	"github.com/google/btree"
)

type Resource string

const (
	ResourceGateway Resource = "Gateway"
	ResourceAgent   Resource = "Agent"
)

type MemStore struct {
	mu      sync.RWMutex
	regions map[string]*MemData
	global  *MemData
}

type MemData struct {
	Gateways map[string]*GatewayData
	Agents   map[string]*AgentData
	ranked   *btree.BTree
	mu       sync.RWMutex
}

type AgentData struct {
	AgentID       string
	AgentDomain   string
	GatewayID     string
	GatewayDomain string
}

type GatewayData struct {
	GatewayID     string
	GatewayIP     string
	GatewayDomain string
	Capacity      Capacity
}

type Capacity struct {
	CPU       int32
	Memory    int32
	Storage   int32
	Bandwidth int32
}
