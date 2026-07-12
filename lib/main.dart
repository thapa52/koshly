import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/theme_provider.dart';
import 'features/savings/data/repositories/hive_savings_repository.dart';
import 'features/savings/presentation/providers/savings_repository_provider.dart';
import 'features/transactions/data/repositories/hive_transaction_repository.dart';
import 'features/transactions/presentation/providers/repository_provider.dart';

/// Entry point of the Koshly app.
/// Handles all initialization before the app starts.
Future<void> main() async {
  // Must be called before async plugin initialization.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables.
  await dotenv.load(fileName: '.env');

  // Initialize Hive.
  await Hive.initFlutter();

  // Initialize repositories
  final transactionRepository = HiveTransactionRepository();
  await transactionRepository.init();

  final savingsRepository = HiveSavingsRepository();
  await savingsRepository.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWith(
          (ref) => transactionRepository,
        ),
        savingsRepositoryProvider.overrideWith((ref) => savingsRepository),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const KoshlyApp(),
    ),
  );
}
