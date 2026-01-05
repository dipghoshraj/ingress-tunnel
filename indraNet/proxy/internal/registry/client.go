package registry

import (
	"time"

	mp "github.com/Purple-House/mem-sdk/memsdk/maps"
	"github.com/Purple-House/mem-sdk/memsdk/pkg"
)

var client *mp.Client

func init() {

	config := pkg.Config{
		Address:     "localhost:8080",
		Fingerprint: "86f7b7b55c1591c0aafbb9470baff92f1021791ca8f6ee9e372d0986a886be00",
		Timeout:     5 * time.Second,
	}

	sdkClinent, err := mp.NewSdkOperation(config)
	if err != nil {
		panic("create memsdk client: " + err.Error())
	}
	client = sdkClinent
}
func GetClient() *mp.Client {
	return client
}
