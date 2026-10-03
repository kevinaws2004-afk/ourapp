# Future Backend & Synchronization

> **Nothing in this document is built in V1.** V1 has no backend, no account, no network calls (ADR-008, §7, §42).
> This document explains how V1 is shaped so a future opt-in cloud layer can be added **without rewriting the app**, and lists the V1 rules that keep that door open.

---

## 1. Target evolution

```text
V1                              Future (opt-in)
──                              ───────────────
Flutter App                     Flutter App
    ↓                               ↓
Repository                      Repository            (same interfaces)
    ↓                               ↓
Local SQLite                    Local SQLite  ◀── still the source of truth for the UI
                                    +
                                Sync engine (outbox / pull)
                                    ↓
                                Remote API
                                    ↓
                                Cloud Database
```

The UI and domain keep reading from local SQLite. Sync is a background process that reconciles local and remote; it is not a different data path for screens.

## 2. What V1 must do now (cheap, required)

| Rule | Why it matters later | Where |
|---|---|---|
| Client-generated globally unique `public_id`s (UUIDv7); local `internal_id` integers never leave the device | Records created offline on two devices never collide. Sync and export use `public_id`; each device maps `public_id` ↔ its own `internal_id` | ADR-017, [database.md §2](database.md#2-conventions) |
| `created_at`, `updated_at` on every mutable row, set on every change (`app_preferences` is a documented exception with `updated_at` only, ADR-012) | Change detection, last-writer-wins baseline | database.md |
| Soft delete (`deleted_at`) on user-owned entities; aggregate children (`log_values`) sync with their log | Deletions must propagate as tombstones; hard deletes are invisible to sync | ADR-022 |
| Aggregates defined (type+fields, log+values) | Sync unit boundaries are clear | [data_architecture.md §2](data_architecture.md#2-identity-ownership--aggregates) |
| Stable IDs inside JSON (items, rows, options, sub-fields, columns) | Merging edits to structured values and configs | data_architecture.md §5 |
| Versioned JSON payloads (`"v": 1`) | Different app versions on different devices | data_architecture.md §5 |
| User unit + write-time normalized value, UTC instants + tz offset + `local_date` | Same meaning on every device/locale | ADR-013, ADR-020 |
| Repository interfaces own all persistence | A sync-aware implementation can be swapped in | ADR-007 |
| No business logic depends on "this device is the only device" | e.g. "only one active focus session" becomes per-device | domain rules |
| Preferences in SQLite | Can sync settings selectively | ADR-012 |
| Export format includes IDs, timestamps, deleted flags | Doubles as a migration path into a future account | FR-DA-01 |

## 3. What V1 must NOT do (deferred until sync is real)

- No `sync_status`, `dirty`, `version`, `server_id` or outbox tables. They are trivially added by a migration when sync is designed, and premature versions tend to be wrong.
- No auth, accounts, tokens, network clients or remote config.
- No conflict-resolution UI.
- No dependency on any cloud SDK (Firebase, Supabase, AWS, …).

## 4. Likely future design (non-binding sketch)

1. **Outbox:** every local write in a syncable aggregate also records a change entry (table, id, op, updated_at) in the same transaction.
2. **Push:** a sync worker sends outbox entries to the API when online and the user has opted in.
3. **Pull:** fetch remote changes since a cursor; upsert locally by ID; apply tombstones.
4. **Conflicts:** start with per-aggregate last-writer-wins on `updated_at` (with a hybrid logical clock or server-assigned revision to avoid clock skew), field-level merge for structured JSON using stable item IDs where valuable.
5. **Schema compatibility:** the server stores the same generic model (activity types, fields, logs, values, plans, measurements, focus sessions); no per-activity tables server-side either.
6. **Privacy:** cloud is opt-in (§39). Consider end-to-end encryption, since the product positioning is "your data stays on your device".
7. **Migration of existing users:** first sync uploads the full local DB keyed by `public_id` (already global, so no remapping). Internal integer keys are rebuilt locally on other devices.

## 5. Repository evolution

V1:
```text
ActivityLogRepository (interface) ◀── DbActivityLogRepository (SQLite)
```
Future:
```text
ActivityLogRepository (interface) ◀── DbActivityLogRepository (SQLite, now also writes outbox entries)
                                        SyncService (separate; reads outbox, talks to RemoteApi)
```
Screens, notifiers and domain do not change.

## 6. Open questions for when sync is scoped (not V1)

Conflict policy per entity; encryption model; multi-device focus sessions; account deletion & data export obligations; pricing (subscriptions are out of V1, §42).
