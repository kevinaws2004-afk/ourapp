import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type_definition.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/domain/field_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';

/// The preference holding the activity that stands for body weight: a
/// "Reach a number" goal on it also follows the weights in Body
/// measurements (`DbChallengeRepository.watchAmounts`).
const bodyWeightActivityKey = 'bodyWeightActivity';

/// The body-weight activity, made the first time a weight goal is set up.
Future<ActivityTypeId> ensureBodyWeightActivity(
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final prefs = ref.read(jsonPreferencesProvider);
  if (await prefs.read(bodyWeightActivityKey) case final String id) {
    final type = await ref
        .read(activityTypeRepositoryProvider)
        .getType(ActivityTypeId(id));
    if (type != null && !type.isDeleted) return type.id;
  }
  final id = await ref.read(addBuiltInActivityProvider)(
    ActivityTypeDefinition(
      name: l10n.bodyWeightActivity,
      iconId: 'heart',
      colorKey: 'teal',
      fields: [
        FieldDefinition(
          name: l10n.bodyWeightField,
          type: FieldType.number,
          dimension: Dimension.mass,
          measurable: true,
          config: const NumberFieldConfig(
            decimals: 1,
            min: 0,
            defaultUnitCode: 'kg',
            summary: NumberSummary.latest,
            better: BetterDirection.neither,
          ),
        ),
      ],
    ),
  );
  await prefs.write(bodyWeightActivityKey, id.value);
  return id;
}

/// Whether [id] is the body-weight activity.
final isBodyWeightActivityProvider = StreamProvider.autoDispose
    .family<bool, ActivityTypeId>(
      (ref, id) => ref
          .watch(jsonPreferencesProvider)
          .watch(bodyWeightActivityKey)
          .map((v) => v == id.value),
    );
