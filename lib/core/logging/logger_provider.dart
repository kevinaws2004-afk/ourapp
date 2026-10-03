import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

final loggerProvider = Provider<AppLogger>((ref) => const AppLogger());
