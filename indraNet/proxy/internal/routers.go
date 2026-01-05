package internal

import (
	"context"
	"cosmo-proxy/internal/registry"
	"fmt"
	"log"

	"github.com/Purple-House/mem-sdk/memsdk/maps"
)

func GetRouter(addr string) (string, error) {

	registy := registry.GetClient()
	log.Println("find the gateway ", addr)
	gateway, err := registy.GetAgentProxyMapping(context.Background(), "global", addr)
	if err != nil {
		return "", fmt.Errorf("key %s not found in Redis", addr)
	}

	if gateway == (maps.Gateway{}) {
		return "", fmt.Errorf("key %s not found in Redis", addr)
	}

	gateway_address := fmt.Sprintf("%s:%d", gateway.IP, gateway.GatewayPort)
	log.Printf("agent %s is connected to gateway %s", addr, gateway_address)

	return gateway_address, nil
}
