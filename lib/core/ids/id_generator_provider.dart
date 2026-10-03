import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../time/clock_provider.dart';
import 'id_generator.dart';

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) => Uuid7IdGenerator(clock: ref.watch(clockProvider)),
);
