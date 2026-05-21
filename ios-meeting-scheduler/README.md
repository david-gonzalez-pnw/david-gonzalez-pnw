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

## Status

Phase 0 (this scaffold): models, poll engine, message URL codec, on‑device
EventKit writes, **stubbed** backend + OAuth, host‑app onboarding shell.
Cross‑provider sync (Cronofy / Nylas / Composio) is behind the
`CalendarSyncProvider` protocol and lands in a later phase.
