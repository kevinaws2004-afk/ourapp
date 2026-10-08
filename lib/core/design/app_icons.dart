import 'package:flutter/widgets.dart';

import 'icons/phosphor_glyphs.dart';

/// Semantic UI icons (ADR-024: Phosphor, bundled official font). Feature code
/// uses these names, never glyphs directly. Activity icons resolve through
/// `ActivityIconRegistry`.
abstract final class AppIcons {
  static const today = AppIconPair(PhosphorGlyphs.sun, PhosphorFillGlyphs.sun);
  static const plan = AppIconPair(
    PhosphorGlyphs.calendarDots,
    PhosphorFillGlyphs.calendarDots,
  );
  static const insights = AppIconPair(
    PhosphorGlyphs.chartLineUp,
    PhosphorFillGlyphs.chartLineUp,
  );
  static const me = AppIconPair(PhosphorGlyphs.user, PhosphorFillGlyphs.user);

  static const add = PhosphorGlyphs.plus;
  static const delete = PhosphorGlyphs.trash;
  static const edit = PhosphorGlyphs.pencilSimple;
  static const check = PhosphorGlyphs.check;
  static const close = PhosphorGlyphs.x;
  static const chevron = PhosphorGlyphs.caretRight;
  static const previous = PhosphorGlyphs.caretLeft;
  static const record = PhosphorGlyphs.plus;
  static const activities = PhosphorGlyphs.squaresFour;
  static const expand = PhosphorGlyphs.caretDown;
  static const more = PhosphorGlyphs.dotsThreeVertical;
  static const undo = PhosphorGlyphs.arrowCounterClockwise;
  static const dragHandle = PhosphorGlyphs.dotsSixVertical;
  static const locked = PhosphorGlyphs.lockSimple;
  static const error = PhosphorGlyphs.warningCircle;
  static const time = PhosphorGlyphs.clock;
  static const date = PhosphorGlyphs.calendarBlank;
  static const archive = PhosphorGlyphs.archive;
  static const info = PhosphorGlyphs.info;
  static const timer = PhosphorGlyphs.timer;
  static const browse = PhosphorGlyphs.listChecks;
  static const developer = PhosphorGlyphs.palette;
  static const ratingEmpty = PhosphorGlyphs.star;
  static const ratingFull = PhosphorFillGlyphs.star;

  // Plans (Phase 4).
  static const taskOpen = PhosphorGlyphs.circle;
  static const taskDone = PhosphorFillGlyphs.checkCircle;
  static const start = PhosphorGlyphs.play;
  static const pause = PhosphorGlyphs.pause;
  static const measurements = PhosphorGlyphs.ruler;
  static const challenge = PhosphorGlyphs.target;
  static const skip = PhosphorGlyphs.skipForward;
  static const moveToTomorrow = PhosphorGlyphs.arrowBendUpRight;
  static const repeat = PhosphorGlyphs.repeat;
  static const duplicate = PhosphorGlyphs.calendarPlus;
  static const planNext = PhosphorGlyphs.calendarPlus;

  // Field type icons (builder field-type picker).
  static const fieldText = PhosphorGlyphs.textAa;
  static const fieldNumber = PhosphorGlyphs.hash;
  static const fieldBoolean = PhosphorGlyphs.toggleLeft;
  static const fieldSingleSelect = PhosphorGlyphs.radioButton;
  static const fieldMultiSelect = PhosphorGlyphs.listChecks;
  static const fieldDate = PhosphorGlyphs.calendarBlank;
  static const fieldTime = PhosphorGlyphs.clock;
  static const fieldDuration = PhosphorGlyphs.hourglassMedium;
  static const fieldRating = PhosphorGlyphs.star;
  static const fieldRepeatingGroup = PhosphorGlyphs.rows;
}

/// An icon's unselected (regular) and selected (fill) forms.
@immutable
class AppIconPair {
  const AppIconPair(this.outline, this.filled);

  final IconData outline;
  final IconData filled;
}
