import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
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

  // Initialize the transaction repository before the UI starts.
  final transactionRepository = HiveTransactionRepository();
  await transactionRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWith(
          (ref) => transactionRepository,
        ),
      ],
      child: const KoshlyApp(),
    ),
  );
}
