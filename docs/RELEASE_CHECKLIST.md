# Release checklist

Run through this for every upload to Google Play. `tool/release_check.sh`
does the automatic parts (steps 1–4) and stops at the first failure.

## Before building

1. **Version bumped** in `pubspec.yaml` (`version: 1.2.0+14`). The part
   after `+` is the Play version code and must be higher than the last
   upload. The app reads it at runtime (Me → About), so there is nothing
   else to keep in step.
2. **Static checks pass**: `flutter analyze` shows no issues.
3. **Tests pass**: `flutter test`. This includes the database migration
   tests (`test/drift/`), which upgrade every earlier schema to the current
   one, and the backup → restore tests.
4. **Release build works**: `flutter build appbundle --release` produces
   `build/app/outputs/bundle/release/app-release.aab`.

## If the database schema changed

- `schemaVersion` bumped in `lib/core/database/app_database.dart`, with a
  `fromXToY` step.
- `dart run drift_dev make-migrations` run (writes `drift_schemas/` and
  `test/drift/app_database/generated/`); both committed.
- A data-keeping test added to `test/drift/app_database/migration_test.dart`
  for the new step.
- **Upgrade tested on a real phone**: install the version that's live on
  Play, use it a little, then install the new build over it (no
  uninstall) and check Today, Plan, Progress and Goals still show the data.
- A backup made by the previous version restores in the new one
  (Me → Backup & restore → Restore from a backup file).

## On a real phone (release build)

- `flutter install --release` (or the `.aab` through Play's internal test
  track).
- First run: onboarding → first plan → Today.
- A timer: start, Pause/Resume from the notification, Finish.
- Pomodoro on: a round ends, the break starts, the next round starts.
- A reminder and the Sunday recap notification arrive (change the phone's
  time to test).
- Home-screen widget added and updates; Quick Settings tile opens Quick
  start.
- Backup & restore: back up now, restore it.
- App lock on, leave for a minute, come back: it asks.
- Dark mode, each theme, and the largest font size (Settings → Display).

## Play Console

- Release notes written (what's new, in plain words).
- **Data safety** form still true. Daylog collects nothing. If anything
  was added that sends data, update the form first.
- **Health Connect**: the app reads weight, height and body fat. Play
  requires the Health Connect declaration in App content, and the
  privacy policy must say what's read and why (it does:
  `store/privacy-policy.md`).
- Privacy policy URL still opens.
- Roll out to internal testing first, then a staged production rollout
  (for example 20 % → 100 %).

## After release

- Watch **Play Console → Android vitals** (crashes, ANRs) for the first
  days. Problem reports people send from Me → Send feedback include the
  last errors from their phone.
- Keep the upload keystore (`android/key.properties` and the `.jks` file)
  backed up somewhere safe. Losing it means you can't update the app.
