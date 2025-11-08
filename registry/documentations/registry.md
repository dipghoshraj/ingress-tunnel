# AgniStack Central Registry Service Technical Planning Document

## Objective

Design and implement a highly available, ultra-low-latency registry service responsible for maintaining real-time state and connection metadata of all agents and gateways in the AgniStack ecosystem.
This service will act as the single source of truth for component discovery and routing decisions, enabling proxies and controllers to resolve live endpoint details with minimal latency and maximal consistency.

**System Defination**
- Read-dominant: 95–99% of operations are reads.
- Write-minimal: Writes limited to registration, renewal, and state updates.
- Horizontally scalable: Adding nodes increases read throughput linearly.
- Highly available: Operates with no single point of failure.
- Predictably low-latency: p50 read < 200µs, p99 read < 2ms in local DC.

