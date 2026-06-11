import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

/// Root widget of the Koshly app.
/// Responsible for theme and navigation configuration.
/// Kept separate from main.dart for cleanliness.
class KoshlyApp extends ConsumerWidget {
  const KoshlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Koshly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(body: Center(child: Text('Koshly is starting....'))),
    );
  }
}
