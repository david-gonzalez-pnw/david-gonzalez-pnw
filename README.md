## Hi, I'm Gonzo

Dev in Seattle. Into AI, automation, and building things that turn messy goals into clear plans. I use **Codex** for agentic development.

I'm happiest when the system handles the tedious bits so people can focus on the parts that actually need a human—and I like it when those systems help real people (and their pets) instead of just moving pixels around.

**Currently:** AI plan automation, dev tooling, healthcare & vet platforms.

[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)](https://reactjs.org/)
[![GraphQL](https://img.shields.io/badge/GraphQL-E10098?logo=graphql&logoColor=white)](https://graphql.org/)
[![LangChain](https://img.shields.io/badge/LangChain-1C3C3C?logo=langchain&logoColor=white)](https://langchain.com/)

- 🗺️ Turning natural language into structured, executable plans
- 🔧 Dev tooling for Firebase, Redis, and local workflows
- 🐾 Healthcare & vet platforms (side projects)
- ⚡ Goals → plans with LangGraph; connectors, queues, and streaming progress in the UI
- ☁️ Cloud-native clinic platform: Azure, .NET 8, native iOS (Swift/SwiftUI), PostgreSQL, multi-tenant, EMR, telemedicine, Bicep/azd

### Agentic loop (Codex SDLC)

I'm playing with **agentic loops**—scheduled automations, skills, and human-in-the-loop handoffs—to see where "AI as a teammate" is actually going. Not one-shot prompts, but a repeatable loop: **Discovery → Build → Validate**, with **parallel inner loops** (reviewing, auditing, quality improvements) and **parallel assessors** (architecture, documentation) running alongside. The diagram below is the loop I run. It's my working map for how AI-assisted building is evolving.

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
