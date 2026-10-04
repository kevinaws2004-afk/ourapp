import '../../../l10n/generated/app_localizations.dart';
import '../domain/measurement.dart';

String measurementTypeLabel(AppLocalizations l10n, MeasurementType type) =>
    switch (type) {
      MeasurementType.weight => l10n.measurementWeight,
      MeasurementType.height => l10n.measurementHeight,
      MeasurementType.bodyFat => l10n.measurementBodyFat,
      MeasurementType.chest => l10n.measurementChest,
      MeasurementType.waist => l10n.measurementWaist,
      MeasurementType.arms => l10n.measurementArms,
      MeasurementType.legs => l10n.measurementLegs,
    };
