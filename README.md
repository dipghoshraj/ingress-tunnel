# Agnistack Ingress

> **Tunnel, route, and expose your apps — securely and simply. Built for self-hosters, edge compute, and dev teams.**

Agnistack is a lightweight, self-hostable, distributed ingress platform that lets you expose services running behind NAT/firewalls using outbound tunnels — without port forwarding, complex VPNs, or cloud lock-in.

This is the **Open Source Core** of Agnistack — a minimal but working version designed for developers and builders.

---

## ✨ Features (Open Source Edition)

✅ Self-hosted reverse proxy layer  
✅ Subdomain-based routing  
✅ Distributed proxy-to-gateway routing via registry  
✅ Secure outbound agent socket tunnel  
✅ Unified agent lifecycle  
✅ Works behind NAT/firewalls  

---

## ❗ What’s Not Included (Yet)

This OSS release is intentionally minimal. Features below are in development and will be included in the full platform:

🚫 Health checks for gateways/proxies  
🚫 Dynamic router discovery  
🚫 Integrated observability (tracing, logs, metrics)  
🚫 Web dashboard / UI  
🚫 Agent RBAC / ACL policies  
🚫 Auto TLS / DNS sync  

<!-- Want early access to the full version? [Join our waitlist](#) or follow [@agnistack](#) for updates. -->

---

## 📦 Architecture Overview

```mermaid
graph LR
    Client -->|DNS| Proxy
    Proxy -->|Lookup| Registry
    Registry --> Proxy
    Proxy -->|Forward Request| Gateway
    Gateway -->|Outbound Socket| Agent
    Agent --> Gateway --> Proxy --> Client
