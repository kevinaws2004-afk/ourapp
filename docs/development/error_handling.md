# Error Handling

> How failures are represented, propagated, shown, and logged. Decision: ADR-025 (accepted). Implemented in Phase 2.

---

## 1. Principles

1. **Expected outcomes are values; unexpected failures are exceptions.** Validation results are returned, not thrown.
2. **Never swallow errors.** Every `catch` either handles meaningfully (recover, map, show) or rethrows/logs.
3. **Map at boundaries.** Driver/library exceptions never leave the data layer; they become `AppException`s.
4. **Users see calm, actionable messages**, never stack traces or SQL text.
5. **Data safety first.** On any write failure, nothing is half-written (transactions) and user input is not lost (draft stays in form).
6. **Local only.** Errors are logged on-device; nothing is transmitted (NFR-03).

## 2. Types (`lib/core/errors/app_exception.dart`)

```text
sealed class AppException            category    debugContext? (IDs/operation only)   cause?
├── ValidationException(issues)      validation  a domain rule was broken (incl. DB trigger 'activity_field_semantics_locked')
├── NotFoundException                notFound    entity missing (or deleted where that matters)
├── StorageException                 storage     DB/IO failure, or a constraint violation the domain should have prevented
├── MigrationException               migration   schema can't be opened/migrated (unknown/newer version)
└── UnsupportedException             unsupported data from a newer format (e.g. unknown JSON "v")

ValidationResult(issues)  NOT an exception: pure domain validation for live form feedback
ValidationIssue(code, target)   target = field public ID or a form key ('name', 'duration', 'notes', …)
ValidationCode                  stable enum; mapped to localized copy in shared/errors/error_copy.dart
```

Add new categories only when justified (ADR-025). There is no `Either`/`Result` library.

## 3. Propagation

```text
Data layer:        guardStorage('operation', () => db op)   // core/database/storage_guard.dart translates drift/SQLite errors (incl. wrapped DriftRemoteException)
Domain/use case:   validates → ValidationResult; use cases throw ValidationException / NotFoundException
Notifier:          catches ValidationException → inline issues in state; rethrows other AppExceptions
Widget:            AsyncValueView → AppErrorState for load failures; save failures → snackbar via errorMessage(l10n, error)
```

## 4. Presenting errors

| Situation | Presentation |
|---|---|
| Field validation | Inline under the field, calm tone, field scrolled into view and focused; submit button stays enabled (validation on submit + after first attempt, live) |
| Screen data failed to load | Shared `ErrorState` view in place of content: plain-language message + "Try again" |
| Action failed (save/delete) | Non-blocking message (snackbar/toast) with retry when meaningful; the form keeps the user's input |
| Corrupt/undecodable stored value | Render the rest of the log. The unreadable value is skipped, and a warning is logged with field IDs only (`DbActivityLogRepository`). Phase 2 doesn't yet show an inline "couldn't read this value" marker |
| DB cannot open / migration failed | Fatal startup screen: explain, offer "Try again"; never auto-delete data; (if export exists) offer raw DB file export for recovery |
| Unexpected exception (bug) | Generic friendly message; logged with stack; app continues where possible |

Copy guidelines (tone, wording) are in [ui_guidelines.md §8](../ui/ui_guidelines.md#8-voice--copy).

## 5. Global handlers

Installed in `bootstrap` (implemented in Phase 1, except the custom `ErrorWidget.builder`, which comes with the first data screens):
- `FlutterError.onError` → log; in debug also `FlutterError.presentError`.
- `PlatformDispatcher.instance.onError` → log; return `true` after logging.
- Riverpod `ProviderObserver` → logs provider failures in debug/profile.
- A custom `ErrorWidget.builder` in release shows a minimal, on-brand fallback instead of the grey box.

## 6. Logging

- `AppLogger` wraps `dart:developer` `log` with levels (`debug`, `info`, `warning`, `error`).
- Debug builds: verbose. Release: warnings and errors only, written to the platform log.
- **No user content** (notes, names, values) in logs at `info` level or above; log IDs and operation names instead.
- An optional rolling local log file for user-initiated "share diagnostics" is a possible later feature; not V1 unless approved.

## 7. Defensive decoding

All JSON decoding (configs, structured values) goes through domain decoders that:
- accept every historical `"v"`,
- ignore unknown keys (forward compatibility),
- tolerate references to archived options/columns,
- throw `UnsupportedException` (with field ID, never the content) only when the payload is unusable, e.g. an unknown `"v"`.
