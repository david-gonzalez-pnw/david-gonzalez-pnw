## Hi, I'm Gonzo

Dev in Seattle. I turn messy goals into clear plans—and I like it when the system does the tedious work so people (and their pets) can do the rest. I use **Codex** for agentic development.

**Right now:** Goal-to-plan platform · Health & productivity app (iOS + Azure) · Clinic platform & dev tooling on the side

[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)](https://reactjs.org/)
[![GraphQL](https://img.shields.io/badge/GraphQL-E10098?logo=graphql&logoColor=white)](https://graphql.org/)
[![LangChain](https://img.shields.io/badge/LangChain-1C3C3C?logo=langchain&logoColor=white)](https://langchain.com/)

---

**What I'm building**

- 🗺️ **Goal → plan** — Plain language in, structured plans out. LangGraph, connectors, streaming progress. Human + automation in the same loop.
- 📱 **Health & insights** — iOS + Azure. Energy, calendar, health, AI copilot. Keychain to Key Vault, device to cloud.
- 🔧 **Dev orchestration** — One-click Firebase + Redis. Electron, so you can forget the plumbing.
- ☁️ **Clinic platform (side)** — Multi-tenant. iOS + web, EMR to telemedicine. Azure, Bicep, built to scale.

---

### Agentic loop

I run **Discovery → Build → Validate** with parallel review, audit, and quality—plus architecture and docs as assessors. Below is the map.

```mermaid
flowchart TB
  subgraph main [Main path]
    direction LR
    D[Discovery] --> B[Build] --> V[Validate]
    V -.->|iterate| D
  end

  subgraph inner [Parallel inner loops]
    direction LR
    R[Reviewing]
    A[Auditing]
    Q[Quality improvements]
  end

  subgraph assessors [Parallel assessors]
    direction LR
    Arch[Architecture]
    Doc[Documentation]
  end
```
