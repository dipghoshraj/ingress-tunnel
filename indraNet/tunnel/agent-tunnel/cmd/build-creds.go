package cmd

import (
	"agent-tunnel/internal/connections/registry"
	"log"

	"github.com/spf13/cobra"
)

var (
	dns  string
	name string
)

// make gen-cert ip=127.0.0.1 dns=localhost name=mycert
var buildCredsCmd = &cobra.Command{
	Use:   "gen-creds",
	Short: "Generate TLS credentials for the agent tunnel",
	Long:  `This command generates TLS credentials (certificates and keys) for secure communication in the IndraNet agent tunnel.`,
	Run: func(cmd *cobra.Command, args []string) {
		log.Println("🔐 Generating TLS credentials...")
		err := registry.BuildCreds(dns, name)
		if err != nil {
			log.Fatalf("❌ Failed to generate TLS credentials: %v", err)
		}
	},
}

func init() {
	buildCredsCmd.Flags().StringVar(&dns, "dns", "", "DNS name for the certificate")
	buildCredsCmd.Flags().StringVar(&name, "name", "agent-tunnel", "Base name for the generated certificate files")
	buildCredsCmd.MarkFlagRequired("dns")
	buildCredsCmd.MarkFlagRequired("name")
}
