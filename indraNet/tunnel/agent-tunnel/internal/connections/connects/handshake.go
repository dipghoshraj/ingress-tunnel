package connects

import (
	"agent-tunnel/proto"
	"context"
	"time"
)

func (c *TunnelClient) Handshake(ctx context.Context) error {
	nonce := generateNonce()
	timestamp := time.Now().Unix()

	connectReq := &proto.ConnectRequest{
		AgentId:   c.Cfg.AgentID,
		Timestamp: timestamp,
		Nonce:     nonce,
	}

	env := &proto.Envelope{
		Message: &proto.Envelope_Connect{
			Connect: connectReq,
		},
	}

	_ = c.send_envalope(env)
	return nil
}
