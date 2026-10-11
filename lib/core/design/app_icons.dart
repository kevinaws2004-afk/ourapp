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
  static const challenges = AppIconPair(
    PhosphorGlyphs.target,
    PhosphorFillGlyphs.target,
  );
  static const me = AppIconPair(PhosphorGlyphs.user, PhosphorFillGlyphs.user);

  static const add = PhosphorGlyphs.plus;
  static const minus = PhosphorGlyphs.minus;
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
  static const developer = PhosphorGlyphs.wrench;
  static const appearance = PhosphorGlyphs.palette;
  static const streak = PhosphorFillGlyphs.fire;
  static const ratingEmpty = PhosphorGlyphs.star;
  static const ratingFull = PhosphorFillGlyphs.star;

  // Plans (Phase 4).
  static const taskOpen = PhosphorGlyphs.circle;
  static const taskDone = PhosphorFillGlyphs.checkCircle;
  static const start = PhosphorGlyphs.play;
  static const pause = PhosphorGlyphs.pause;
  static const measurements = PhosphorGlyphs.ruler;
  static const skip = PhosphorGlyphs.skipForward;
  static const moveToTomorrow = PhosphorGlyphs.arrowBendUpRight;
  static const repeat = PhosphorGlyphs.repeat;
  static const duplicate = PhosphorGlyphs.calendarPlus;
  static const planNext = PhosphorGlyphs.calendarPlus;

  // Product shell, Me and Progress.
  static const quickAdd = PhosphorGlyphs.plus;
  static const darkMode = PhosphorGlyphs.moon;
  static const lightMode = PhosphorGlyphs.sun;
  static const systemMode = PhosphorGlyphs.circleHalf;
  static const export = PhosphorGlyphs.export;
  static const exportFile = PhosphorGlyphs.fileArrowDown;
  static const privacy = PhosphorGlyphs.shieldCheck;
  static const energy = PhosphorFillGlyphs.lightning;
  static const trophy = PhosphorFillGlyphs.trophy;
  static const goal = PhosphorGlyphs.flag;
  static const bars = PhosphorGlyphs.chartBar;
  static const settings = PhosphorGlyphs.gearSix;
  static const arrowRight = PhosphorGlyphs.arrowRight;
  static const trendUp = PhosphorGlyphs.trendUp;
  static const trendDown = PhosphorGlyphs.trendDown;
  static const dayDone = PhosphorGlyphs.calendarCheck;
  static const wave = PhosphorGlyphs.handWaving;
  static const note = PhosphorGlyphs.notePencil;
  static const verified = PhosphorFillGlyphs.sealCheck;
  static const help = PhosphorGlyphs.question;
  static const device = PhosphorGlyphs.deviceMobile;
  static const lock = PhosphorGlyphs.lockKey;
  static const addCircle = PhosphorGlyphs.plusCircle;
  static const quote = PhosphorGlyphs.quotes;
  static const medal = PhosphorGlyphs.medal;
  static const sparkle = PhosphorFillGlyphs.sparkle;
  static const heart = PhosphorFillGlyphs.heart;

  static const bell = PhosphorGlyphs.bell;
  static const bellOn = PhosphorFillGlyphs.bell;

  /// Daylog's mark (the app icon's glyph).
  static const logo = PhosphorFillGlyphs.calendarCheck;

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
