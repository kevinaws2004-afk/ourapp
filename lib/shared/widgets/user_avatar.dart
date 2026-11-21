import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/typography.dart';

/// You, as a circle: your initial on the theme's soft signature color, or a
/// person glyph before you've given a name.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.onTap,
    this.tooltip,
    this.picture,
    this.editBadge = false,
  });

  final String name;

  /// The picture chosen in Me (a character or a photo); without one, the
  /// name's first letter.
  final AvatarPicture? picture;

  /// A small pencil on it: tap to change.
  final bool editBadge;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = name.trim().isEmpty
        ? null
        : name.trim().characters.first.toUpperCase();
    final picture = this.picture;
    final ring = Border.all(color: c.surfaceBase, width: size > 60 ? 4 : 2);
    Widget avatar = switch (picture) {
      PhotoAvatar(:final path) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: ring),
        child: ClipOval(
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // The photo was removed from the phone: the letter instead.
            errorBuilder: (_, _, _) => UserAvatar(name: name, size: size - 8),
          ),
        ),
      ),
      CharacterAvatar(:final emoji) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CharacterAvatar.colorOf(emoji),
          border: ring,
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: TextStyle(fontSize: size * 0.52, height: 1)),
      ),
      null => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.brandPrimarySoft,
          border: ring,
        ),
        alignment: Alignment.center,
        child: initial == null
            ? Icon(AppIcons.me.filled, size: size * 0.48, color: c.brandPrimary)
            : Text(
                initial,
                style: AppTypography.titleLarge.copyWith(
                  fontSize: size * 0.42,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: c.onBrandPrimarySoft,
                ),
              ),
      ),
    };
    if (editBadge) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: c.brandPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: c.surfaceBase, width: 2),
              ),
              alignment: Alignment.center,
              child: Icon(
                AppIcons.edit,
                size: size * 0.15,
                color: c.onBrandPrimary,
              ),
            ),
          ),
        ],
      );
    }
    if (onTap != null) {
      avatar = Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(onTap: onTap, child: avatar),
      );
    }
    return avatar;
  }
}

/// What the avatar shows besides the first letter.
sealed class AvatarPicture {
  const AvatarPicture();

  /// From what's saved ({"character": "🦊"} or {"photo": path}).
  static AvatarPicture? fromJson(Object? json) => switch (json) {
    {'character': final String e} when e.isNotEmpty => CharacterAvatar(e),
    {'photo': final String p} when p.isNotEmpty => PhotoAvatar(p),
    _ => null,
  };

  Map<String, String> toJson();
}

/// A cartoon character, on its own soft color.
class CharacterAvatar extends AvatarPicture {
  const CharacterAvatar(this.emoji);

  final String emoji;

  /// The characters to choose from: animals, and plants like Pip.
  static const all = [
    '🦊',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐸',
    '🐰',
    '🐻',
    '🐱',
    '🐶',
    '🐵',
    '🐧',
    '🦉',
    '🐢',
    '🦄',
    '🐙',
    '🪴',
    '🌱',
    '🌸',
    '🌻',
    '🍄',
    '🌵',
    '🐝',
    '🦋',
  ];

  static const _colors = [
    Color(0xFFFFE3D3),
    Color(0xFFE8ECEF),
    Color(0xFFE3E8F5),
    Color(0xFFFFEBC8),
    Color(0xFFFFF0C2),
    Color(0xFFDDF5D8),
    Color(0xFFFDE2EC),
    Color(0xFFF1E3D3),
    Color(0xFFFFE9D6),
    Color(0xFFF3E6D8),
    Color(0xFFEFE2D6),
    Color(0xFFDDEBF7),
    Color(0xFFEDE3F5),
    Color(0xFFDDF2E6),
    Color(0xFFF5E1F7),
    Color(0xFFFFDDE6),
    Color(0xFFDDF2E1),
    Color(0xFFE2F5DA),
    Color(0xFFFDE3EE),
    Color(0xFFFFF4C9),
    Color(0xFFFBE0DC),
    Color(0xFFE2F2DF),
    Color(0xFFFFF0C9),
    Color(0xFFE6E4FA),
  ];

  /// Its background: the same soft color every time.
  static Color colorOf(String emoji) {
    final i = all.indexOf(emoji);
    return _colors[(i < 0 ? emoji.hashCode : i) % _colors.length];
  }

  @override
  Map<String, String> toJson() => {'character': emoji};
}

/// A photo from the phone, copied into the app's own storage.
class PhotoAvatar extends AvatarPicture {
  const PhotoAvatar(this.path);

  final String path;

  @override
  Map<String, String> toJson() => {'photo': path};
}
