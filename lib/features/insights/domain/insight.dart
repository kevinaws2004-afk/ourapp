import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../measurements/domain/measurement.dart';

// The generic analytics model (§24–26, FR-AN-01): every chart is a series of
// (date, value) points from a source, bucketed and aggregated. Nothing here
// knows about specific activities.

extension type const InsightChartId(String value) {}

enum Aggregation { sum, average, max, min, count, latest }

enum Bucket { day, week, month }

enum ChartKind { line, bar }

/// How far back Insights looks.
enum InsightRange {
  week(7),
  month(30),
  quarter(90),
  year(365);

  const InsightRange(this.days);

  final int days;

  /// `[from, to]` ending on [today], inclusive.
  (LocalDate, LocalDate) window(LocalDate today) =>
      (today.addDays(-(days - 1)), today);

  /// The same length immediately before [window] (for comparisons).
  (LocalDate, LocalDate) previous(LocalDate today) =>
      (today.addDays(-(2 * days - 1)), today.addDays(-days));

  /// The bucket that fits this range for automatic charts (A20): days for
  /// a week, weeks for a month or three, months for a year.
  Bucket get bucket => switch (this) {
    week => Bucket.day,
    month || quarter => Bucket.week,
    year => Bucket.month,
  };

  /// [chosen] (a saved chart's grouping), made coarser when it would draw
  /// more than [maxBuckets] bars or points for this range (D3).
  Bucket fit(Bucket chosen, {int maxBuckets = 60}) {
    int count(Bucket b) => switch (b) {
      Bucket.day => days,
      Bucket.week => (days / 7).ceil(),
      Bucket.month => (days / 30).ceil(),
    };
    var bucket = chosen;
    while (bucket != Bucket.month && count(bucket) > maxBuckets) {
      bucket = Bucket.values[bucket.index + 1];
    }
    return bucket;
  }

  /// The first day any chart of this range needs: the previous period (for
  /// the comparison) or the start of the first bucket, whichever is earlier.
  LocalDate loadFrom(LocalDate today, Bucket bucket) {
    final (prevFrom, _) = previous(today);
    final first = bucketStart(window(today).$1, bucket);
    return first.compareTo(prevFrom) < 0 ? first : prevFrom;
  }
}

/// What "best" means for a value (ADR-043): the highest, the lowest, or
/// nothing (money, temperature).
enum BestIs { highest, lowest, none }

/// Keeps values whose item, parent item or record has this text value in
/// [fieldId] (e.g. Weight of sets where Exercise = "Chest Press").
class TextFilter {
  const TextFilter({required this.fieldId, required this.value});

  final ActivityFieldId fieldId;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is TextFilter && other.fieldId == fieldId && other.value == value;

  @override
  int get hashCode => Object.hash(fieldId, value);
}

/// Where a chart's values come from.
sealed class InsightSource {
  const InsightSource();
}

/// Recorded time of an activity (`activity_logs.duration_ms`).
final class ActivityDurationSource extends InsightSource {
  const ActivityDurationSource(this.typeId);

  final ActivityTypeId typeId;

  @override
  bool operator ==(Object other) =>
      other is ActivityDurationSource && other.typeId == typeId;

  @override
  int get hashCode => typeId.hashCode;
}

/// How often an activity was recorded (one point per record).
final class ActivityCountSource extends InsightSource {
  const ActivityCountSource(this.typeId);

  final ActivityTypeId typeId;

  @override
  bool operator ==(Object other) =>
      other is ActivityCountSource && other.typeId == typeId;

  @override
  int get hashCode => typeId.hashCode;
}

/// Values of any Number, Rating, Duration (ms), Yes/No (1 or 0) or Time of
/// day (minutes after midnight) field, top level or inside a Repeating
/// Group: one point per value, numbers in their canonical unit.
final class FieldValueSource extends InsightSource {
  const FieldValueSource(this.typeId, this.fieldId, {this.filter});

  final ActivityTypeId typeId;
  final ActivityFieldId fieldId;
  final TextFilter? filter;

  @override
  bool operator ==(Object other) =>
      other is FieldValueSource &&
      other.typeId == typeId &&
      other.fieldId == fieldId &&
      other.filter == filter;

  @override
  int get hashCode => Object.hash(typeId, fieldId, filter);
}

/// How two number sub-fields of a group item combine.
enum VolumeFormula {
  /// amount × count, e.g. volume = weight × reps per set (FR-AN-08).
  product,

  /// The estimated one-repetition maximum (Epley): amount × (1 + count /
  /// 30), or the amount itself for a single repetition.
  estimatedMax,
}

/// Two number sub-fields combined per group item ([formula]), in the first
/// field's canonical unit.
final class VolumeSource extends InsightSource {
  const VolumeSource(
    this.typeId, {
    required this.groupFieldId,
    required this.amountFieldId,
    required this.countFieldId,
    this.filter,
    this.formula = VolumeFormula.product,
  });

  final ActivityTypeId typeId;
  final ActivityFieldId groupFieldId;
  final ActivityFieldId amountFieldId;
  final ActivityFieldId countFieldId;
  final TextFilter? filter;
  final VolumeFormula formula;

  @override
  bool operator ==(Object other) =>
      other is VolumeSource &&
      other.typeId == typeId &&
      other.groupFieldId == groupFieldId &&
      other.amountFieldId == amountFieldId &&
      other.countFieldId == countFieldId &&
      other.filter == filter &&
      other.formula == formula;

  @override
  int get hashCode => Object.hash(
    typeId,
    groupFieldId,
    amountFieldId,
    countFieldId,
    filter,
    formula,
  );
}

/// A body measurement (FR-BM-03), canonical unit.
final class MeasurementSource extends InsightSource {
  const MeasurementSource(this.type);

  final MeasurementType type;

  @override
  bool operator ==(Object other) =>
      other is MeasurementSource && other.type == type;

  @override
  int get hashCode => type.hashCode;
}

/// Planned length vs recorded time of plans, per plan date (FR-AN-09), for
/// one activity or all.
final class PlannedVsActualSource extends InsightSource {
  const PlannedVsActualSource([this.typeId]);

  final ActivityTypeId? typeId;

  @override
  bool operator ==(Object other) =>
      other is PlannedVsActualSource && other.typeId == typeId;

  @override
  int get hashCode => typeId.hashCode;
}

/// A saved chart (FR-AN-07).
class InsightChartConfig {
  const InsightChartConfig({
    required this.id,
    required this.title,
    required this.source,
    required this.aggregation,
    required this.bucket,
    required this.kind,
  });

  final InsightChartId id;
  final String title;
  final InsightSource source;
  final Aggregation aggregation;
  final Bucket bucket;
  final ChartKind kind;

  @override
  bool operator ==(Object other) =>
      other is InsightChartConfig &&
      other.id == id &&
      other.title == title &&
      other.source == source &&
      other.aggregation == aggregation &&
      other.bucket == bucket &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(id, title, source, aggregation, bucket, kind);

  /// Sensible defaults for a source: time and counts add up, body values
  /// show the latest, field values show the best (PR-style) per bucket.
  static Aggregation defaultAggregation(InsightSource source) =>
      switch (source) {
        ActivityDurationSource() ||
        ActivityCountSource() ||
        VolumeSource() ||
        PlannedVsActualSource() => Aggregation.sum,
        MeasurementSource() => Aggregation.latest,
        FieldValueSource() => Aggregation.max,
      };
}

class DataPoint {
  const DataPoint(this.date, this.value);

  final LocalDate date;
  final double value;

  @override
  bool operator ==(Object other) =>
      other is DataPoint && other.date == date && other.value == value;

  @override
  int get hashCode => Object.hash(date, value);

  @override
  String toString() => 'DataPoint($date, $value)';
}

class SeriesBucket {
  const SeriesBucket(this.start, this.value);

  final LocalDate start;

  /// Null when the bucket has no data (gaps stay gaps on line charts).
  final double? value;
}

/// A bucketed series plus the stats shown with it.
class InsightSeries {
  const InsightSeries({
    required this.buckets,
    required this.total,
    required this.count,
    this.average,
    this.best,
    this.latest,
  });

  final List<SeriesBucket> buckets;

  /// Sum of all points in the range.
  final double total;

  /// Number of points in the range.
  final int count;
  final double? average;

  /// Highest single point in the range, with its date.
  final DataPoint? best;
  final DataPoint? latest;

  bool get isEmpty => count == 0;
}

/// The first day of [date]'s bucket (weeks start on Monday).
LocalDate bucketStart(LocalDate date, Bucket bucket) => switch (bucket) {
  Bucket.day => date,
  Bucket.week => date.addDays(-(date.weekday - 1)),
  Bucket.month => LocalDate(date.year, date.month, 1),
};

LocalDate _nextBucket(LocalDate start, Bucket bucket) => switch (bucket) {
  Bucket.day => start.addDays(1),
  Bucket.week => start.addDays(7),
  Bucket.month =>
    start.month == 12
        ? LocalDate(start.year + 1, 1, 1)
        : LocalDate(start.year, start.month + 1, 1),
};

double? aggregate(List<DataPoint> points, Aggregation aggregation) {
  if (points.isEmpty) {
    return aggregation == Aggregation.sum || aggregation == Aggregation.count
        ? 0
        : null;
  }
  final values = points.map((p) => p.value);
  return switch (aggregation) {
    Aggregation.sum => values.fold<double>(0, (a, b) => a + b),
    Aggregation.count => points.length.toDouble(),
    Aggregation.average =>
      values.fold<double>(0, (a, b) => a + b) / points.length,
    Aggregation.max => values.reduce((a, b) => a > b ? a : b),
    Aggregation.min => values.reduce((a, b) => a < b ? a : b),
    Aggregation.latest =>
      points.reduce((a, b) => b.date.compareTo(a.date) >= 0 ? b : a).value,
  };
}

/// Buckets [points] over `[from, to]` and computes the stats (pure). Every
/// bucket is whole (A2): the first one also holds the days of its week or
/// month before [from], so it isn't a misleading short bar; the stats cover
/// `[from, to]` only.
InsightSeries buildSeries(
  List<DataPoint> points, {
  required LocalDate from,
  required LocalDate to,
  required Bucket bucket,
  required Aggregation aggregation,
}) {
  final inRange = [
    for (final p in points)
      if (p.date.compareTo(from) >= 0 && p.date.compareTo(to) <= 0) p,
  ];
  final first = bucketStart(from, bucket);
  final byBucket = <LocalDate, List<DataPoint>>{};
  for (final p in points) {
    if (p.date.compareTo(first) < 0 || p.date.compareTo(to) > 0) continue;
    byBucket.putIfAbsent(bucketStart(p.date, bucket), () => []).add(p);
  }
  final buckets = <SeriesBucket>[];
  for (
    var start = first;
    start.compareTo(to) <= 0;
    start = _nextBucket(start, bucket)
  ) {
    final pts = byBucket[start] ?? const <DataPoint>[];
    buckets.add(
      SeriesBucket(
        start,
        pts.isEmpty &&
                aggregation != Aggregation.sum &&
                aggregation != Aggregation.count
            ? null
            : aggregate(pts, aggregation),
      ),
    );
  }
  final total = inRange.fold<double>(0, (a, p) => a + p.value);
  return InsightSeries(
    buckets: buckets,
    total: total,
    count: inRange.length,
    average: inRange.isEmpty ? null : total / inRange.length,
    best: bestOf(inRange, BestIs.highest),
    latest: inRange.isEmpty
        ? null
        : inRange.reduce((a, b) => b.date.compareTo(a.date) >= 0 ? b : a),
  );
}

/// The best single point of [points] by [bestIs] (the latest one on a tie),
/// or null when there's none or nothing counts as best.
DataPoint? bestOf(List<DataPoint> points, BestIs bestIs) {
  if (points.isEmpty || bestIs == BestIs.none) return null;
  return points.reduce(
    (a, b) => switch (bestIs) {
      BestIs.highest => b.value >= a.value ? b : a,
      BestIs.lowest => b.value <= a.value ? b : a,
      BestIs.none => a,
    },
  );
}

/// Consecutive weeks (Monday to Sunday) with at least one of [days]: the
/// run still going (this week, or last week while this one has nothing yet)
/// and the longest ever (H4).
({int current, int longest}) weekStreaks(
  Iterable<LocalDate> days,
  LocalDate today,
) {
  final weeks = {for (final d in days) bucketStart(d, Bucket.week)};
  if (weeks.isEmpty) return (current: 0, longest: 0);
  final sorted = weeks.toList()..sort();
  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    run = sorted[i - 1].addDays(7) == sorted[i] ? run + 1 : 1;
    if (run > longest) longest = run;
  }
  final thisWeek = bucketStart(today, Bucket.week);
  var week = weeks.contains(thisWeek) ? thisWeek : thisWeek.addDays(-7);
  var current = 0;
  while (weeks.contains(week)) {
    current++;
    week = week.addDays(-7);
  }
  return (current: current, longest: longest);
}

/// How often each of a choice field's options was picked over a period, most
/// picked first (B3). Ties keep the field's option order.
List<(String optionId, int count)> optionCounts(
  Iterable<List<String>> picks,
  List<String> optionOrder,
) {
  final counts = <String, int>{};
  for (final pick in picks) {
    for (final id in pick) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
  }
  int order(String id) {
    final i = optionOrder.indexOf(id);
    return i < 0 ? optionOrder.length : i;
  }

  return counts.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) {
    final byCount = b.$2.compareTo(a.$2);
    return byCount != 0 ? byCount : order(a.$1).compareTo(order(b.$1));
  });
}

/// When in the day something is usually done (H: per activity).
enum PartOfDay { morning, afternoon, evening, night }

/// The part of day of [minuteOfDay]: morning 5–12, afternoon 12–17,
/// evening 17–22, night 22–5.
PartOfDay partOfDay(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  if (hour >= 5 && hour < 12) return PartOfDay.morning;
  if (hour >= 12 && hour < 17) return PartOfDay.afternoon;
  if (hour >= 17 && hour < 22) return PartOfDay.evening;
  return PartOfDay.night;
}

/// The highest per-day total of [points] (e.g. the best day's volume, A21),
/// or null when there are none.
DataPoint? bestDayTotal(List<DataPoint> points) {
  final byDay = <LocalDate, double>{};
  for (final p in points) {
    byDay[p.date] = (byDay[p.date] ?? 0) + p.value;
  }
  DataPoint? best;
  for (final MapEntry(key: date, :value) in byDay.entries) {
    if (best == null || value > best.value) best = DataPoint(date, value);
  }
  return best;
}

/// The aggregated value of a whole period (for "this vs last period").
double? periodValue(
  List<DataPoint> points,
  LocalDate from,
  LocalDate to,
  Aggregation aggregation,
) => aggregate([
  for (final p in points)
    if (p.date.compareTo(from) >= 0 && p.date.compareTo(to) <= 0) p,
], aggregation);

/// Relative change from [previous] to [current], or null when undefined.
double? relativeChange(double? current, double? previous) =>
    current == null || previous == null || previous == 0
    ? null
    : (current - previous) / previous;
