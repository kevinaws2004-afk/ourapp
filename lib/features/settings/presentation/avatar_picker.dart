import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/design/icons/phosphor_glyphs.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/user_avatar.dart';

const _avatarKey = 'avatar';

/// The picture chosen for the avatar (a character or a photo), or null.
final avatarPictureProvider = StreamProvider<AvatarPicture?>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(_avatarKey)
      .map(AvatarPicture.fromJson),
);

/// Choosing the avatar: a grid of characters, your own photo, or none.
Future<void> showAvatarPicker(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const _AvatarPicker(),
    );

class _AvatarPicker extends ConsumerWidget {
  const _AvatarPicker();

  Future<void> _save(WidgetRef ref, AvatarPicture? picture) async {
    final prefs = ref.read(jsonPreferencesProvider);
    // A photo replaced by something else: its copy goes too.
    final before = AvatarPicture.fromJson(await prefs.read(_avatarKey));
    if (before is PhotoAvatar &&
        (picture is! PhotoAvatar || picture.path != before.path)) {
      try {
        await File(before.path).delete();
      } on FileSystemException {
        // Already gone.
      }
    }
    await prefs.write(_avatarKey, picture?.toJson());
  }

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFiles(type: FileType.image);
    if (picked.isEmpty) return;
    final dir = await getApplicationSupportDirectory();
    // A new name each time, so the new photo shows at once.
    final copy = File(
      '${dir.path}/avatar_${ref.read(clockProvider).nowUtc().millisecondsSinceEpoch}.img',
    );
    await copy.writeAsBytes(await picked.first.xFile.readAsBytes());
    await _save(ref, PhotoAvatar(copy.path));
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final current = ref.watch(avatarPictureProvider).value;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.avatarTitle, style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.avatarHint,
              style: context.textStyles.bodySmall?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = AppSpacing.md;
                final columns = constraints.maxWidth > 420 ? 6 : 4;
                final size =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final emoji in CharacterAvatar.all)
                      Semantics(
                        button: true,
                        selected:
                            current is CharacterAvatar &&
                            current.emoji == emoji,
                        child: GestureDetector(
                          onTap: () async {
                            unawaited(HapticFeedback.selectionClick());
                            await _save(ref, CharacterAvatar(emoji));
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Container(
                            width: size,
                            height: size,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    current is CharacterAvatar &&
                                        current.emoji == emoji
                                    ? c.brandPrimary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: UserAvatar(
                              name: '',
                              size: size - 12,
                              picture: CharacterAvatar(emoji),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => unawaited(_pickPhoto(context, ref)),
              icon: const Icon(PhosphorGlyphs.camera),
              label: Text(l10n.avatarPhoto),
            ),
            if (current != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: c.textSecondary),
                onPressed: () async {
                  await _save(ref, null);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.avatarRemove),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
