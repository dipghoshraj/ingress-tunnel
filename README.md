# Agnistack Ingress  
### Launching April 2026

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Inter&size=22&pause=1200&color=F97316&center=true&vCenter=true&width=700&lines=Secure+Ingress+Without+Port+Forwarding;Distributed+by+Design;Open+Source+and+Self-Hostable" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-Launching%20April%202026-orange" />
  <img src="https://img.shields.io/badge/Edition-Open%20Source%20Core-blue" />
  <img src="https://img.shields.io/badge/Architecture-Distributed-success" />
</p>

---

> **Tunnel, route, and expose applications — securely and without central control.**  
> Built for self-hosted infrastructure, edge environments, and teams that value ownership.

---

## Announcement

A **new and more capable version of Agnistack** is currently under active development and scheduled for release in **April 2026**.

This release represents a major step forward in both **capabilities and philosophy**, with a focus on:

- Stronger security primitives  
- Better visibility and control  
- A more decentralized and resilient network model  

All while remaining **open source** and **self-hostable**.

Community & updates:
- Watch this repository  
- Join the discussion on Discord:  
  https://discordapp.com/channels/1273907702355066961/1393671943286165665

---

## What is Agnistack?

**Agnistack** is a lightweight, distributed ingress platform designed to expose services running behind NATs and firewalls using **outbound connections only**.

Instead of relying on cloud-managed ingress, centralized brokers, or pub/sub systems, Agnistack forms a **cooperative network of proxies, gateways, agents, and registries** that dynamically discover and route traffic.

It removes the need for:

- Port forwarding  
- VPN-based exposure  
- Centralized ingress providers  

Agnistack is particularly suited for:

- Self-hosted and on-prem environments  
- Edge and remote deployments  
- Internal platforms and developer tooling  

---

## Discovery via Registry Mesh

A **distributed registry mesh ** handles service discovery in Agnistack.

There is no central controller and no pub/sub broker. Instead:

- Registries form a **mesh network**
- Routing information is **replicated and queried deterministically**
- Proxies and gateways resolve routes through the registry mesh
- Failure of individual nodes does not compromise the network

This model reduces operational complexity, removes single points of failure, and aligns with Agnistack’s long-term goal of becoming a **protocol-level primitive** rather than a managed service.

---

## Open Source Core

This repository contains the **Open Source Core** of Agnistack.

The OSS Core provides a **minimal but functional implementation** of the Agnistack model, intended for developers who want to:

- Understand the system architecture  
- Operate Agnistack in self-managed environments  
- Extend or experiment with distributed ingress concepts  

More advanced capabilities are planned as part of the future release plans.

---

## Features (Open Source Edition)

- Self-hosted reverse proxy  
- domain-based routing  
- Distributed routing via registry mesh  
- Secure outbound tunnels between agents and gateways  
- Unified agent lifecycle management  
- Operates fully behind NATs and firewalls  

---

## Not Included Yet

This Open Source release is intentionally scoped.  
The following capabilities are under active development:

- Health-aware routing and node scoring  
- Integrated observability (logs, metrics, tracing)  
- Fine-grained access control and policies  
- Automated TLS and DNS coordination  

---

## Project Status

- Actively developed  
- Open Source Core available  
- Full platform release planned for **April 2026**

---

**Agnistack is an attempt to rethink ingress — as infrastructure you own, networks you compose, and trust you can verify.**
