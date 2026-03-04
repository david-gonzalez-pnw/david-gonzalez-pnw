## Hi, I'm Gonzo

Dev in Seattle. I turn messy goals into clear plans—and I like it when the system does the tedious work so people (and their pets) can do the rest.

**Right now:** Goal-to-plan platform · Health & productivity app (iOS + Azure) · Clinic platform & dev tooling on the side

---

**What I'm building**

| *Health, productivity & personal insights* | *Goal → plan platform* |
|:---:|:---:|
| <img width="2048" height="1365" alt="fusionhealth_blurred" src="https://github.com/user-attachments/assets/6af48369-a1a1-4b65-9e56-083e53bdd0dc" /> | <img width="2400" height="1600" alt="image" src="https://github.com/user-attachments/assets/af78c2ea-06bc-4404-a9f3-eab61d1d0df3" /> |


- 🗺️ **Goal → plan** - Plain language in, structured plans out. LangGraph, connectors, streaming progress. Human + automation in the same loop.
- 📱 **Health & insights** - iOS + Azure. Energy, calendar, health, AI copilot. Keychain to Key Vault, device to cloud.
- 🔧 **Dev orchestration** - One-click Firebase + Redis. Electron, so you can forget the plumbing.
- ☁️ **Clinic platform (side)** - Multi-tenant. iOS + web, EMR to telemedicine. Azure, Bicep, built to scale.

---

### Agentic loop

I'm playing with a mix of AI tools and processes. I'm using Codex and I've set up an agentic 
loop, without any fancy triggers yet, to run Discovery → Build → Validate with parallel review, audit, and quality—and architecture and docs as assessors. Below is the map.

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

---

![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)
![GraphQL](https://img.shields.io/badge/GraphQL-E10098?logo=graphql&logoColor=white)
![LangChain](https://img.shields.io/badge/LangChain-1C3C3C?logo=langchain&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?logo=dotnet&logoColor=white)
![Codex](https://img.shields.io/badge/Codex-6C2DC7?style=flat-square)
![Electron](https://img.shields.io/badge/Electron-2B2E3A?logo=electron&logoColor=9FEAF9)
![Redis](https://img.shields.io/badge/Redis-DC382D?logo=redis&logoColor=white)
