import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../providers/dashboard_providers.dart';

/// Displays a personalized greeting at the top of the dashboard.
///
/// Shows:
/// - Time-based greeting (Good Morning, Good Afternoon, etc.)
/// - Subtitle with motivational message
///
/// Usage:
/// ```dart
/// const GreetingHeader()
/// ```
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTextStyles.headlineLarge.copyWith(color: onSurface),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Here\'s your financial overview',
            style: AppTextStyles.bodyMedium.copyWith(
              color: onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
