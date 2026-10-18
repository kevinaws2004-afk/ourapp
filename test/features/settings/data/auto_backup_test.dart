import 'dart:io';

import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/json_preferences.dart';
import 'package:daylog/features/settings/data/auto_backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';

/// Backups kept on the phone: "Back up now" is dated now, and one dated
/// ahead (a changed clock) doesn't hold off the daily backup.
void main() {
  late AppDatabase db;
  late Directory root;
  late AutoBackup backup;
  final now = DateTime.utc(2026, 10, 18, 8);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    root = Directory.systemTemp.createTempSync('backups');
    backup = AutoBackup(
      db,
      JsonPreferences(db, FakeClock(now)),
      root: () async => root,
    );
  });

  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  test('a backup made now is dated now', () async {
    final made = await backup.backupNow(now);

    expect(made.madeAt, now);
    expect((await backup.list()).single.madeAt, now);
  });

  test('a daily backup is due again after a day', () async {
    await backup.runIfDue(now);
    await backup.runIfDue(now.add(const Duration(hours: 2)));
    expect(await backup.list(), hasLength(1));

    await backup.runIfDue(now.add(const Duration(days: 1)));
    expect(await backup.list(), hasLength(2));
  });

  test(
    'a backup dated in the future does not hold off the daily one',
    () async {
      await backup.backupNow(now.add(const Duration(days: 1)));

      await backup.runIfDue(now);

      expect((await backup.list()).map((s) => s.madeAt), contains(now));
    },
  );
}
