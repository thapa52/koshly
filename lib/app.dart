import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/transactions/presentation/screens/transaction_list_screen.dart';

/// Root widget of the Koshly app.
/// Responsible for theme and navigation configuration.
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
      home: const TransactionListScreen(),
    );
  }
}
