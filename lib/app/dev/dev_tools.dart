import 'package:flutter/foundation.dart';

/// Developer tools (token showcase, demo data) show in debug builds, or in
/// any build made with `--dart-define=DEV_TOOLS=true` (e.g. to load demo
/// data onto a phone running a release build). Plain release builds never
/// show them.
const devToolsEnabled = kDebugMode || bool.fromEnvironment('DEV_TOOLS');
