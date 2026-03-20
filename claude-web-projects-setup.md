# Claude.ai Web Projects — Setup Guide

Create each project at https://claude.ai/projects → "Create Project"

---

## 1. Fusion Health

**Files to upload:**
- `CLAUDE.md` (root)
- `AGENTS.md`
- `README.md`
- `fusion-api/ARCHITECTURE.md`
- `fusion-app/CLAUDE.md`
- `fusion-api/CLAUDE.md`
- `fusion-admin/CLAUDE.md`
- `.github/pull_request_template.md`

**Custom instructions (paste into Project Instructions):**

```
You are helping David Gonzalez work on Fusion Health, a monorepo with four components:

- fusion-app/ — iOS app (SwiftUI, Swift 6 strict concurrency, MVVM, CocoaPods, Factory DI)
- fusion-api/ — Azure Functions API (.NET 9/C#, EF Core, endpoint→service→entity layering)
- fusion-admin/ — React admin portal (Vite, React 19, MUI 7, TanStack Query)
- shared-protos/ — Protocol Buffer schemas shared between iOS and API

Key rules:
- Proto changes are cross-component: update .proto sources, regenerate, commit generated output for both platforms. Never reuse or renumber proto fields.
- Never hand-edit generated files (fusion-app/Generated/, fusion-api/app/Generated/).
- iOS uses MVVM with @Observable and Factory @Injected. API follows endpoint→service→entity layering.
- Conventional Commits required with monorepo scopes: app, api, admin, protos, agents, repo.
- No secrets, tokens, or credentials in source, logs, or test fixtures.
- See ARCHITECTURE.md for the full system diagram and data flow.
```

---

## 2. Cheerful

**Files to upload:**
- `CLAUDE.md` (root)
- `README.md`
- `.claude/rules/general.md`
- `.claude/rules/backend.md`
- `.claude/rules/webapp.md`
- `apps/context-engine/.claude/CLAUDE.md`

**Custom instructions (paste into Project Instructions):**

```
You are helping David Gonzalez work on Cheerful, an AI context engine monorepo with four apps:

- backend (FastAPI + Temporal workers, Python/uv)
- webapp (Next.js 14+, TypeScript)
- context-engine (Claude Agent SDK Slack bot, Python/uv, FCIS architecture)
- cli (Rust CLI, Cargo)

Key rules:
- Context-engine follows FCIS (Functional Core, Imperative Shell) architecture. Core layer is pure functions with no I/O. Services are thin async orchestrators. Entrypoints handle platform-specific concerns (Slack).
- Pydantic models at system boundaries, dataclasses internally. No nested contexts.
- Backend uses SQLAlchemy Core (not ORM), FastAPI, and Temporal for workflows.
- Webapp uses Next.js App Router, TanStack Query, Zustand, and Shadcn/ui.
- Git flow: feature branches → staging → main. Never PR directly to main. Both branches auto-deploy.
- Never run Supabase migrations directly — use the deploy workflow.
- Testing: real Postgres, no mocks. Skip glue code tests. Modules should be <100 lines.
```

---

## 3. Planapus

**Files to upload:**
- `CLAUDE.md`
- `README.md`
- `AGENTS.md`
- `.codex-agent-instructions.md`
- `PLANAPUS_CONTEXT.md` (if it exists)
- `docs/conventions.md` (if it exists)

**Custom instructions (paste into Project Instructions):**

```
You are helping David Gonzalez work on Planapus, an AI-powered plan generation platform. Firebase + GraphQL + React monorepo.

Architecture:
- apps/web/ — React frontend (MUI v7, Apollo Client, HashRouter)
- firebase/functions/ — Backend (Apollo Server 5, Cloud Functions 2nd gen, LangGraph + OpenAI for AI)
- Schema-first GraphQL: edit .graphql files in firebase/functions/src/schemas/, then run codegen

Key rules:
- Firestore nested docs: steps are nested arrays inside plan documents, not subcollections. Never query steps independently.
- All mutations require Firebase Auth. Resolvers call getUserIdFromContext() and verify ownership.
- Google TypeScript Style (gts). No `any` types — use `unknown` with type guards. Strict mode everywhere.
- apps/web is NOT in npm workspaces. Install separately with --legacy-peer-deps.
- Node 24 required (.nvmrc). Java 21+ for Firebase Emulators. Docker for Redis (BullMQ).
- /docs is source of truth. Proposals in /docs/rfcs, decisions in /docs/adr.
- Naming: files kebab-case, components PascalCase, functions camelCase, enums UPPER_SNAKE_CASE.
```

---

## 4. VetsPR Platform

**Files to upload:**
- `CLAUDE.md`
- `README.md`
- `docs/README.md`
- `docs/engineering/architecture/engineering-design-and-implementation-plan.md`

**Custom instructions (paste into Project Instructions):**

```
You are helping David Gonzalez work on VetsPR, a cloud-native veterinary clinic management platform. Monorepo with five areas:

- apps/ios — Swift 6/SwiftUI iOS 18+ app (XcodeGen, CocoaPods, MVVM with @Observable, Factory DI)
- apps/api — .NET 9 Azure Functions (EF Core + PostgreSQL, Service Bus, Redis, Entra ID auth)
- apps/web — Next.js staff/admin portal (MSAL React, Vitest, Tailwind, i18n: en/es)
- infra/bicep — Azure Bicep IaC (modules under infra/bicep/modules/)
- docs/ — Architecture, epics, roadmap

Key rules:
- iOS: XcodeGen project — never hand-edit project.pbxproj. Regenerate with `xcodegen generate`.
- API: endpoint→service→entity layering. OpenTelemetry to Application Insights.
- Use `make <target> COMPONENT=<name>` for all build/test/deploy operations.
- Always run `make doctor` before first build on a fresh clone.
- Doc precedence: docs/README.md > architecture plan > .cursor/rules/.
- Discovery first: check docs/roadmap/epics/ and docs/engineering/epics/ for specs before implementing.
- No secrets, .env.local, or local.settings.json in source control.
- Codex→Claude migration is in progress. See MIGRATION_PLAN.md for status.
```

---

## 5. Planapus Dev Console

**Files to upload:**
- `CLAUDE.md`
- `README.md`

**Custom instructions (paste into Project Instructions):**

```
You are helping David Gonzalez work on Planapus Dev Console, an Electron desktop app for orchestrating Planapus development services (Firebase Emulator, Redis Queue Worker, Redis Docker).

Stack: Electron + React 18 + MUI 6 + xterm.js + node-pty + TypeScript.

Architecture — three Electron process layers:
- main/ — Node.js main process. IPC handlers in ipc/handlers.ts. PTY management in services/pty-manager.ts.
- preload/ — Context bridge exposing IPC API to renderer.
- renderer/ — React UI with xterm.js terminal panes.
- shared/ — Types and service command registry used by both main and renderer.

Key rules:
- Renderer must never import node-pty or Node APIs directly — always go through the IPC layer.
- Services stop via SIGINT first, then SIGTERM after 3s timeout.
- To add a new service: (1) add ServiceId to shared/types.ts, (2) add definition to shared/services.ts, (3) add to serviceConfigs in renderer App.tsx.
- Don't hardcode absolute paths to the Planapus project root — it's user-selected at runtime.
```

---

## 6. GitHub Profile (optional)

**Files to upload:**
- `README.md`

**Custom instructions (paste into Project Instructions):**

```
You are helping David Gonzalez maintain his GitHub profile README (david-gonzalez-pnw/david-gonzalez-pnw).

This is a single Markdown file with no build system. It renders as his GitHub profile page.

Conventions:
- Badges use Shields.io img.shields.io/badge/ format with ?logo=<slug>&logoColor=<hex>. Keep existing color/logo style. All badges in a single block at the bottom, one per line, no blank lines between them.
- Mermaid diagrams use fenced ```mermaid blocks. Prefer flowchart TB with named subgraphs.
- Images are hosted via GitHub user-attachments and referenced with <img> tags.
- Tone: concise, professional, technically accurate. No filler.
- Single branch (main), direct push.
```
