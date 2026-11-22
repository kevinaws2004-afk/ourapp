import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/my_words.dart';

/// Reads [words] full screen, one at a time: big and calm, with where each
/// is from. [onOpen]: shown as the app opens, so the last button starts the
/// day.
Future<void> showWordsReader(
  BuildContext context,
  List<MyWords> words, {
  int initial = 0,
  bool onOpen = false,
}) => Navigator.of(context, rootNavigator: true).push(
  PageRouteBuilder<void>(
    fullscreenDialog: true,
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) =>
        WordsReader(words: words, initial: initial, onOpen: onOpen),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
);

class WordsReader extends StatefulWidget {
  const WordsReader({
    super.key,
    required this.words,
    this.initial = 0,
    this.onOpen = false,
  });

  final List<MyWords> words;
  final int initial;
  final bool onOpen;

  @override
  State<WordsReader> createState() => _WordsReaderState();
}

class _WordsReaderState extends State<WordsReader> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _page = widget.initial;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool get _last => _page >= widget.words.length - 1;

  void _next() {
    unawaited(HapticFeedback.lightImpact());
    if (_last) {
      Navigator.of(context).pop();
    } else {
      unawaited(
        _pages.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final count = widget.words.length;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.brandPrimarySoft, c.surfaceCanvas],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppContentWidth.reading,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(margin, AppSpacing.sm, 4, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (widget.onOpen
                                    ? l10n.wordsReaderOpenTitle
                                    : l10n.wordsTodayTitle)
                                .toUpperCase(),
                            style: context.textStyles.labelMedium?.copyWith(
                              color: c.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          icon: Icon(AppIcons.close, color: c.textSecondary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: count,
                      onPageChanged: (p) => setState(() => _page = p),
                      itemBuilder: (_, i) =>
                          _WordsPage(words: widget.words[i], margin: margin),
                    ),
                  ),
                  if (count > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < count; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _page ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _page
                                    ? c.brandPrimary
                                    : c.borderStrong,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      margin,
                      0,
                      margin,
                      AppSpacing.lg,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(
                          !_last
                              ? l10n.wordsReaderNext
                              : widget.onOpen
                              ? l10n.wordsReaderStartDay
                              : l10n.wordsReaderDone,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One words, centered; long ones scroll.
class _WordsPage extends StatelessWidget {
  const _WordsPage({required this.words, required this.margin});

  final MyWords words;
  final double margin;

  /// Short lines big, paragraphs smaller.
  static double sizeOf(String text) => switch (text.length) {
    < 90 => 30,
    < 200 => 25,
    < 450 => 21,
    _ => 18,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = sizeOf(words.text.trim());
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: margin + AppSpacing.sm),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - t)),
                child: child,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Icon(AppIcons.quote, size: 44, color: c.brandPrimary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  words.text.trim(),
                  style: TextStyle(
                    fontSize: size,
                    height: 1.4,
                    fontWeight: size >= 25 ? FontWeight.w700 : FontWeight.w500,
                    color: c.textPrimary,
                    letterSpacing: size >= 25 ? -0.3 : 0,
                  ),
                ),
                if (words.from.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Container(width: 24, height: 2, color: c.brandPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          words.from.trim(),
                          style: context.textStyles.titleMedium?.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
