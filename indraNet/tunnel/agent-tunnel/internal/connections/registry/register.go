package registry

import (
	"context"
	"crypto/sha256"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"log"
	"os"
	"time"

	mp "github.com/Purple-House/mem-sdk/memsdk/maps"
	"github.com/Purple-House/mem-sdk/memsdk/pkg"
)

func AgentFingerprint() (string, error) {
	permfile := "certs/client.pem"
	certPEM, err := os.ReadFile(permfile)
	if err != nil {
		return "", fmt.Errorf("failed to read certificate file: %v", err)
	}

	block, _ := pem.Decode(certPEM)

	if block == nil || block.Type != "CERTIFICATE" {
		return "", fmt.Errorf("failed to decode PEM block containing certificate")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return "", err
	}

	sum := sha256.Sum256(cert.Raw)
	fingerprint := hex.EncodeToString(sum[:])
	log.Printf("Client CERT fingerprint (SHA256): %s", fingerprint)
	return fingerprint, nil
}

func AgentRegistry(agent_domain string, region string) error {

	config := pkg.Config{
		Address:     "localhost:8080",
		Fingerprint: "",
		Timeout:     5 * time.Second,
	}

	client, err := mp.NewSdkOperation(config)
	if err != nil {
		return fmt.Errorf("create memsdk client: %w", err)
	}

	gateways, err := client.ResolveGatewayForAgent(context.Background(), region)
	if err != nil {
		return fmt.Errorf("resolve gateway: %w", err)
	}

	if len(gateways) == 0 {
		return fmt.Errorf("no gateways found")
	}

	gw := gateways[0]
	fmt.Printf("Resolved Gateway: %s (%s)\n", gw.IP, gw.ID)

	fingerprint, err := AgentFingerprint()
	if err != nil {
		return fmt.Errorf("get agent fingerprint: %w", err)
	}
	fmt.Printf("Using Agent Fingerprint: %s\n", fingerprint)

	agent, err := client.ConnectAgent(context.Background(), agent_domain, gw.ID, gw.Domain)
	if err != nil {
		return fmt.Errorf("connect agent: %w", err)
	}

	fmt.Printf("Connected Agent: %s (%s)\n", agent.ID, agent.Domain)
	return nil
}
