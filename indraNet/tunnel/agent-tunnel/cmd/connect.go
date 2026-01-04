package cmd

import (
	"agent-tunnel/internal/connections/connects"
	"agent-tunnel/internal/connections/registry"
	"context"
	"log"
	"net"

	"github.com/spf13/cobra"
)

var (
	gatewayURL  string
	token       string
	secret      string
	agentID     string
	portforward string
)

var connectCmd = &cobra.Command{
	Use:   "connect",
	Short: "Connect and authenticate to the agent tunnel",
	Long:  `This command establishes and authenticates a connection to the agent tunnel, allowing you to interact with the IndraNet network.`,
	Run: func(cmd *cobra.Command, args []string) {

		log.Println("📝 Registering agent with the registry...")
		agent, fingerprint, err := registry.AgentRegistry("app.example.com", "global")
		if err != nil {
			log.Fatalf("❌ Failed to register agent: %v", err)
		}
		log.Printf("✅ Agent registered successfully: ID=%s, Domain=%s", agent.ID, agent.Domain)
		log.Println("🔌 Connecting to the agent tunnel...")

		client := &connects.TunnelClient{
			Cfg: connects.ClientConfig{
				GatewayURL:  agent.GatewayAddress,
				AgentID:     agentID,
				Portforward: portforward,
				VFID:        fingerprint,
			},
			Close:   make(chan struct{}),
			Streams: make(map[string]net.Conn),
		}

		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()

		if err := client.Start(ctx); err != nil {
			log.Fatalf("❌ Tunnel client exited: %v", err)
		}

	},
}

func init() {

	connectCmd.Flags().StringVar(&gatewayURL, "gateway", "", "Gateway WebSocket URL (wss://)")
	connectCmd.Flags().StringVar(&agentID, "id", "", "Agent ID")
	connectCmd.Flags().StringVar(&portforward, "port", "", "local port to forward")

	connectCmd.MarkFlagRequired("gateway")
	connectCmd.MarkFlagRequired("token")
	connectCmd.MarkFlagRequired("secret")
	connectCmd.MarkFlagRequired("id")
	connectCmd.MarkFlagRequired("port")

	rootCmd.AddCommand(connectCmd)

}
