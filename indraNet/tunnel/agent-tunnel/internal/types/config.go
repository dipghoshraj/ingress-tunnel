package types

type ClientConfig struct {
	GatewayURL  string
	AgentDomain string
	AgentID     string
	Portforward string // Local port to forward
	VFID        string // verifiable ID or similar identifier
}
