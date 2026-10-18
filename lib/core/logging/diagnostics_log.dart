import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The last warnings and errors (crashes included), kept in a small file on
/// the phone so a problem can be reported after it happened. Never sent
/// anywhere by itself: Me → Send feedback shares it only when the person
/// chooses to. Entries hold error types, messages and stack traces, never
/// what people write in the app (see `AppLogger`).
class DiagnosticsLog {
  DiagnosticsLog._(this._file);

  static const maxEntries = 100;
  static const _separator = '\n--- ';

  final File _file;
  final List<String> _entries = [];
  Future<void> _writing = Future.value();

  /// Opens the log (reading what's there). Null if storage isn't available.
  static Future<DiagnosticsLog?> open() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final log = DiagnosticsLog._(File('${dir.path}/diagnostics.log'));
      if (log._file.existsSync()) {
        final text = await log._file.readAsString();
        log._entries.addAll(
          text.split(_separator).where((e) => e.trim().isNotEmpty),
        );
      }
      return log;
    } catch (_) {
      return null;
    }
  }

  /// Adds an entry, keeping the newest [maxEntries].
  void record(String level, String message, Object? error, StackTrace? stack) {
    final entry = [
      '${DateTime.now().toUtc().toIso8601String()} $level $message',
      if (error != null) '${error.runtimeType}: $error',
      if (stack != null) _trim(stack),
    ].join('\n');
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    final snapshot = _entries.join(_separator);
    _writing = _writing.then((_) async {
      try {
        await _file.writeAsString(snapshot, flush: true);
      } catch (_) {
        // Storage full: the entry stays in memory.
      }
    });
  }

  /// The first frames of a stack trace: enough to find the place.
  static String _trim(StackTrace stack) =>
      stack.toString().split('\n').take(12).join('\n');

  int get length => _entries.length;

  /// A report to share: app and device facts, then the entries.
  Future<File> report({required String header}) async {
    await _writing;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/daylog-diagnostics.txt');
    await file.writeAsString(
      '$header\n\n${_entries.reversed.join('\n\n')}\n',
      flush: true,
    );
    return file;
  }

  void clear() {
    _entries.clear();
    _writing = _writing.then((_) async {
      try {
        if (_file.existsSync()) await _file.delete();
      } catch (_) {
        // Already gone.
      }
    });
  }
}
