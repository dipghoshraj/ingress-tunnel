

# AgniStack Registry Service Implementation Roadmap

### **Phase 1: Prototype**

* Implement single-node in-memory registry with gRPC API.  
* CRUD operations for agents/gateways.  
* WAL-based persistence (no replication).  
* Benchmark local latency (p50/p99).  

### **Phase 2: Partitioned Single-Node Cluster**

* Introduce consistent hashing and partition routing logic.  
* Multiple partitions per node.  
* Snapshot + TTL expiry.  

### **Phase 3: Distributed Cluster**

* Add Raft-based replication (etcd/raft or raft-rs).  
* Implement leader election, replica sync, and snapshot streaming.  
* Add cluster join/rebalance protocols.  

### **Phase 4: Optimization & Hardening**

* Leader lease-based reads.  
* Binary serialization and zero-copy decoding.  
* Detailed metrics, monitoring, and admin tooling.  
* Fault injection tests (node kill, network partition).  

### **Phase 5: Production**

* Multi-region replication.  
* Automated rebalancing.  
* Fine-grained ACLs.  
* Integration with AgniStack control plane.