import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Settings screen with theme toggle and app info.
///
/// Sections:
/// - Appearance (theme mode)
/// - About (version, developer)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8.0),

          // ─── Appearance Section ─────────────────────────────
          _buildSectionTitle(context, 'Appearance'),
          const SizedBox(height: 8.0),
          _buildThemeSelector(context, ref, themeMode),
          const SizedBox(height: 8.0),
          _buildThemePreview(context, themeMode, onSurface),

          const Divider(height: 32.0),

          // ─── About Section ──────────────────────────────────
          _buildSectionTitle(context, 'About'),
          const SizedBox(height: 8.0),
          _buildAboutTile(
            context: context,
            icon: Icons.info_outline,
            title: 'App Name',
            subtitle: AppConstants.appName,
          ),
          _buildAboutTile(
            context: context,
            icon: Icons.tag,
            title: 'Version',
            subtitle: AppConstants.appVersion,
          ),
          _buildAboutTile(
            context: context,
            icon: Icons.code,
            title: 'Architecture',
            subtitle: 'Clean Architecture with Riverpod',
          ),
          _buildAboutTile(
            context: context,
            icon: Icons.storage,
            title: 'Storage',
            subtitle: 'Hive (Offline)',
          ),

          const Divider(height: 32.0),

          // ─── Developer Section ──────────────────────────────
          _buildSectionTitle(context, 'Developer'),
          const SizedBox(height: 8.0),
          _buildAboutTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Built by',
            subtitle: 'Pradeep Thapa',
          ),
          _buildAboutTile(
            context: context,
            icon: Icons.link,
            title: 'GitHub',
            subtitle: 'github.com/thapa52',
          ),

          const SizedBox(height: 32.0),

          // ─── Footer ─────────────────────────────────────────
          Center(
            child: Text(
              'Made with Flutter & Dart',
              style: AppTextStyles.labelSmall.copyWith(
                color: onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Center(
            child: Text(
              '© 2025 Pradeep Thapa',
              style: AppTextStyles.labelSmall.copyWith(
                color: onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  /// Builds a section title.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Builds the theme mode selector.
  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: AppTextStyles.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_brightness, size: 18.0),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode, size: 18.0),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode, size: 18.0),
                    label: Text('Dark'),
                  ),
                ],
                selected: {currentMode},
                onSelectionChanged: (selected) {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(selected.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a preview text showing the current theme name.
  Widget _buildThemePreview(
    BuildContext context,
    ThemeMode mode,
    Color onSurface,
  ) {
    final label = switch (mode) {
      ThemeMode.system => 'Following system settings',
      ThemeMode.light => 'Always light mode',
      ThemeMode.dark => 'Always dark mode',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Builds an about section tile.
  Widget _buildAboutTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 22.0,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
