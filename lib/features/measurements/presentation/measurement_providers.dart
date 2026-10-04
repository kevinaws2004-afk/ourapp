import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../data/db_measurement_repository.dart';
import '../domain/measurement.dart';
import '../domain/measurement_repository.dart';
import '../domain/measurement_use_cases.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => DbMeasurementRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final latestMeasurementsProvider =
    StreamProvider.autoDispose<Map<MeasurementType, Measurement>>(
      (ref) => ref.watch(measurementRepositoryProvider).watchLatest(),
    );

final measurementsForTypeProvider = StreamProvider.autoDispose
    .family<List<Measurement>, MeasurementType>(
      (ref, type) =>
          ref.watch(measurementRepositoryProvider).watchForType(type),
    );

final recordMeasurementProvider = Provider(
  (ref) => RecordMeasurement(
    ref.watch(measurementRepositoryProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final updateMeasurementProvider = Provider(
  (ref) => UpdateMeasurement(
    ref.watch(measurementRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final deleteMeasurementProvider = Provider(
  (ref) => DeleteMeasurement(ref.watch(measurementRepositoryProvider)),
);

final restoreMeasurementProvider = Provider(
  (ref) => RestoreMeasurement(ref.watch(measurementRepositoryProvider)),
);
