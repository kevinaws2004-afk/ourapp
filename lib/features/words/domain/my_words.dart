import '../../../core/time/local_date.dart';

/// Words the person wants to read again: a line from a book, a quote, a
/// proverb, or a paragraph of their own (what they want to become).
class MyWords {
  const MyWords({
    required this.id,
    required this.text,
    this.from = '',
    this.everyDay = false,
  });

  final String id;
  final String text;

  /// Where it's from (a book, an author), or empty.
  final String from;

  /// Shown every day; otherwise it takes turns with the others.
  final bool everyDay;

  MyWords copyWith({String? text, String? from, bool? everyDay}) => MyWords(
    id: id,
    text: text ?? this.text,
    from: from ?? this.from,
    everyDay: everyDay ?? this.everyDay,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    't': text,
    if (from.isNotEmpty) 'f': from,
    if (everyDay) 'd': true,
  };

  /// Null when unreadable.
  static MyWords? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final text = json['t'];
    if (id is! String || text is! String || text.trim().isEmpty) return null;
    return MyWords(
      id: id,
      text: text,
      from: json['f'] is String ? json['f'] as String : '',
      everyDay: json['d'] == true,
    );
  }
}

/// [day]'s words: every "every day" one, then one of the rest, taking
/// turns day by day so each comes back in order.
List<MyWords> wordsForDay(List<MyWords> all, LocalDate day) {
  final rest = [
    for (final w in all)
      if (!w.everyDay) w,
  ];
  return [
    for (final w in all)
      if (w.everyDay) w,
    if (rest.isNotEmpty) rest[_epoch.daysUntil(day) % rest.length],
  ];
}

final _epoch = LocalDate(1970, 1, 1);
