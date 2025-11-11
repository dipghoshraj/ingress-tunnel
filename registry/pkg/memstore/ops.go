package memstore

import "github.com/google/btree"

func (mem *MemStore) AddGateway(region string, gateway *GatewayData) {
	data := mem.RegionExist(region)

	data.mu.Lock()
	defer data.mu.Unlock()

	gatewayData, exist := data.Gateways[gateway.GatewayDomain]
	if exist {
		// Remove old rank item
		oldRank := gatewayData.Capacity.Rank()
		data.ranked.Delete(&GatewayRankItem{
			Rank: oldRank,
			ID:   gateway.GatewayDomain,
		})
	}
	data.Gateways[gateway.GatewayDomain] = gateway
	data.ranked.ReplaceOrInsert(&GatewayRankItem{
		Rank: gateway.Capacity.Rank(),
		ID:   gateway.GatewayDomain,
	})
}

func (mem *MemStore) RegionExist(region string) *MemData {
	mem.mu.RLock()
	data, ok := mem.regions[region]
	mem.mu.RUnlock()

	if !ok {
		mem.mu.Lock()
		_, exists := mem.regions[region]
		if !exists {
			mem.regions[region] = &MemData{
				Gateways: make(map[string]*GatewayData),
				Agents:   make(map[string]*AgentData),
				ranked:   btree.New(2),
			}
		}
		data = mem.regions[region]
		mem.mu.Unlock()
	}
	return data

}
