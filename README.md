## Hi, I'm Gonzo

Dev in Seattle. Into AI, automation, and building things that turn messy goals into clear plans. I use **Codex** for agentic development.

**Currently:** AI plan automation, dev tooling, healthcare & vet platforms.

[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)](https://reactjs.org/)
[![GraphQL](https://img.shields.io/badge/GraphQL-E10098?logo=graphql&logoColor=white)](https://graphql.org/)
[![LangChain](https://img.shields.io/badge/LangChain-1C3C3C?logo=langchain&logoColor=white)](https://langchain.com/)

- Turning natural language into structured, executable plans
- Dev tooling for Firebase, Redis, and local workflows
- Work in healthcare and veterinary platforms
- FOIA-style connectors, queues, and streaming progress to the UI
- Cloud-native clinic platform: Azure, .NET 8, native iOS (Swift/SwiftUI), PostgreSQL, multi-tenant, EMR, telemedicine, Bicep/azd

### Agentic loop (Codex SDLC)

```mermaid
flowchart LR
  subgraph sequential [Sequential]
    A[Discover]
    B[Review RFC]
    C[Spec]
    D[Build]
  end
  subgraph reviewPR [Review PR - parallel or staggered]
    E[RFC expert review]
    F[PR review]
  end
  subgraph afterReview [After review]
    G[Fix]
    H[Ship]
  end
  I[Assess - weekly]
  A --> B --> C --> D --> reviewPR --> G --> H
  I -.->|off critical path| I
```
