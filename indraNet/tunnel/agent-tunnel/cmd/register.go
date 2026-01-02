package cmd

import (
	"agent-tunnel/internal/connections/registry"
	"log"

	"github.com/spf13/cobra"
)

var (
	domainname string
	region     string
)

// make register-agent domain=example.com region=us-west
var registerAgentCmd = &cobra.Command{
	Use:   "register-agent",
	Short: "Register the agent tunnel with the central registry",
	Long:  `This command registers the agent tunnel with the central registry to enable secure communication and management.`,
	Run: func(cmd *cobra.Command, args []string) {
		log.Println("� Registering agent tunnel...")
		err := registry.AgentRegistry(domainname, region)
		if err != nil {
			log.Fatalf("Failed to register agent tunnel: %v", err)
		}
	},
}

func init() {
	registerAgentCmd.Flags().StringVar(&domainname, "domain", "", "Domain name for the agent tunnel")
	registerAgentCmd.Flags().StringVar(&region, "region", "us-west", "Region for the agent tunnel")
	registerAgentCmd.MarkFlagRequired("domain")
	rootCmd.AddCommand(registerAgentCmd)
}
