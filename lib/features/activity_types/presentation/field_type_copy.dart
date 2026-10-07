import 'package:flutter/widgets.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/field_config.dart';
import '../domain/field_type.dart';

/// Localized names, descriptions and icons for field types and dimensions.
extension FieldTypeCopy on FieldType {
  String label(AppLocalizations l10n) => switch (this) {
    FieldType.text => l10n.fieldTypeText,
    FieldType.number => l10n.fieldTypeNumber,
    FieldType.boolean => l10n.fieldTypeBoolean,
    FieldType.singleSelect => l10n.fieldTypeSingleSelect,
    FieldType.multiSelect => l10n.fieldTypeMultiSelect,
    FieldType.date => l10n.fieldTypeDate,
    FieldType.time => l10n.fieldTypeTime,
    FieldType.duration => l10n.fieldTypeDuration,
    FieldType.rating => l10n.fieldTypeRating,
    FieldType.repeatingGroup => l10n.fieldTypeRepeatingGroup,
  };

  String description(AppLocalizations l10n) => switch (this) {
    FieldType.text => l10n.fieldTypeTextDescription,
    FieldType.number => l10n.fieldTypeNumberDescription,
    FieldType.boolean => l10n.fieldTypeBooleanDescription,
    FieldType.singleSelect => l10n.fieldTypeSingleSelectDescription,
    FieldType.multiSelect => l10n.fieldTypeMultiSelectDescription,
    FieldType.date => l10n.fieldTypeDateDescription,
    FieldType.time => l10n.fieldTypeTimeDescription,
    FieldType.duration => l10n.fieldTypeDurationDescription,
    FieldType.rating => l10n.fieldTypeRatingDescription,
    FieldType.repeatingGroup => l10n.fieldTypeRepeatingGroupDescription,
  };

  IconData get icon => switch (this) {
    FieldType.text => AppIcons.fieldText,
    FieldType.number => AppIcons.fieldNumber,
    FieldType.boolean => AppIcons.fieldBoolean,
    FieldType.singleSelect => AppIcons.fieldSingleSelect,
    FieldType.multiSelect => AppIcons.fieldMultiSelect,
    FieldType.date => AppIcons.fieldDate,
    FieldType.time => AppIcons.fieldTime,
    FieldType.duration => AppIcons.fieldDuration,
    FieldType.rating => AppIcons.fieldRating,
    FieldType.repeatingGroup => AppIcons.fieldRepeatingGroup,
  };
}

extension DimensionCopy on Dimension {
  String label(AppLocalizations l10n) => switch (this) {
    Dimension.mass => l10n.dimensionMass,
    Dimension.distance => l10n.dimensionDistance,
    Dimension.volume => l10n.dimensionVolume,
    Dimension.temperature => l10n.dimensionTemperature,
    Dimension.energy => l10n.dimensionEnergy,
    Dimension.percentage => l10n.dimensionPercentage,
    Dimension.duration => l10n.durationLabel,
  };
}

/// "Add it up" / "Average it" / "Latest value" (ADR-043).
String numberSummaryLabel(AppLocalizations l10n, NumberSummary summary) =>
    switch (summary) {
      NumberSummary.total => l10n.numberSummaryTotal,
      NumberSummary.average => l10n.numberSummaryAverage,
      NumberSummary.latest => l10n.numberSummaryLatest,
    };

/// "Higher" / "Lower" / "Neither" (ADR-043).
String betterDirectionLabel(AppLocalizations l10n, BetterDirection better) =>
    switch (better) {
      BetterDirection.higher => l10n.betterHigher,
      BetterDirection.lower => l10n.betterLower,
      BetterDirection.neither => l10n.betterNeither,
    };
