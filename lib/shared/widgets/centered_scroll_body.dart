import 'package:flutter/material.dart';

import '../../core/design/tokens/spacing.dart';
import '../../core/design/window_size_class.dart';

/// A single column of content centered on screen, constrained to the reading
/// width, that scrolls instead of overflowing on small windows or large text
/// scales (responsive_design.md §6).
class CenteredScrollBody extends StatelessWidget {
  const CenteredScrollBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final margin = WindowSizeClass.of(context).screenMargin;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppContentWidth.reading,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: margin,
                    vertical: AppSpacing.xxxl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
