package connects

import (
	"agent-tunnel/proto"
	"context"
	"fmt"
	"log"
	"net"
	"time"

	"github.com/gorilla/websocket"
)

func (c *TunnelClient) Start(ctx context.Context) error {
	for {
		err := c.runSessions(ctx)
		if err != nil {
			log.Printf("Session ended: %v, reconnecting...", err)
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(5 * time.Second): // TODO: use exponential backoff
			}
		} else {
			return nil // exited cleanly
		}
	}
}

func (c *TunnelClient) runSessions(ctx context.Context) error {
	conn, _, err := websocket.DefaultDialer.DialContext(ctx, c.Cfg.GatewayURL, nil)

	if err != nil {
		return fmt.Errorf("connect to gateway: %w", err)
	}
	c.conn = conn
	c.conn.SetCloseHandler(func(code int, text string) error {
		log.Printf("WebSocket closed: code=%d, text=%s", code, text)
		return nil
	})
	c.Streams = make(map[string]net.Conn)

	defer conn.Close()

	if err := c.Handshake(ctx); err != nil {
		return fmt.Errorf("handshake failed: %w", err)
	}

	log.Printf("Connected to gateway: %s", c.Cfg.GatewayURL)

	msgs := make(chan *proto.Envelope)
	errs := make(chan error, 2)

	go c.readLoop(ctx, msgs, errs)
	// go c.heartbeatLoop(ctx, errs)

	for {
		select {
		case msg := <-msgs:
			if err := c.handleMessage(ctx, msg); err != nil {
				log.Printf("error handling message: %v", err)
			}
			log.Printf("Received message: %v", msg)
		case err := <-errs:
			return err
		case <-ctx.Done():
			return ctx.Err()
		}
	}
}
