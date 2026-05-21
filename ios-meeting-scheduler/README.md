# Convene

An iOS app + iMessage extension for scheduling meetings without leaving the
thread: run a date/time **poll** in iMessage, then turn the winning slot into a
**calendar event** that syncs to all your calendars and that recipients add to
their own calendar with one tap.

> Working scaffold. Authored without Xcode and **not yet compiled** — see
> [`ARCHITECTURE.md`](ARCHITECTURE.md) §9. Expect minor first‑build fixes.

## Getting started

```bash
brew install xcodegen          # one time
cd ios-meeting-scheduler
xcodegen generate              # produces Convene.xcodeproj
open Convene.xcodeproj
```

Then in Xcode: set your Development Team, run the **Convene** scheme on a
device (the iMessage extension needs a real device or the Messages simulator),
open Messages, and find Convene in the app drawer ("+" button).

## Layout

| Path | What |
| --- | --- |
| `ARCHITECTURE.md` | Design of record: flow, message payload, sync, phasing |
| `project.yml` | XcodeGen project definition (3 targets) |
| `Sources/App` | SwiftUI host app — connect accounts, pick default calendar |
| `Sources/MessagesExtension` | The iMessage experience (poll + event) |
| `Sources/Shared` | `ConveneKit`: models, poll engine, codecs, services |
| `Tests/ConveneKitTests` | Unit tests for the poll engine and message codec |

## Calendar provider: Cronofy

Convene uses **Cronofy** so there are no per‑provider OAuth apps and no
Google/Microsoft production verification — one app in the Cronofy dashboard
covers Google, Outlook, and iCloud. The real `CronofyCalendarSyncProvider` and
hosted‑auth wiring are implemented; only the secret‑bearing token exchange is
stubbed until you stand up the backend.

To go live:
1. Create an application in the Cronofy dashboard; register the redirect URI
   `convene://oauth/cronofy`.
2. Set `clientID` (and `dataCenter`) in `CronofyConfig.shared`
   (`Sources/Shared/Calendar/Cronofy/CronofyConfig.swift`).
3. Implement the backend's `/oauth/token` exchange + refresh (holds the client
   secret) and point `StubBackendClient` at it.

With `clientID` empty, the app runs offline against `StubCalendarSyncProvider`.

## Status

Phase 0 (this scaffold): models, poll engine, message URL codec, on‑device
EventKit writes, host‑app onboarding shell, and the **real Cronofy REST
provider + `ASWebAuthenticationSession` hosted auth** behind a stubbed token
broker. Other providers (Nylas / Composio) remain drop‑in via the
`CalendarSyncProvider` protocol.
