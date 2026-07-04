import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/hive_transaction_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Provides a single instance of [TransactionRepository].
///
/// The rest of the app depends on [TransactionRepository] (interface),
/// not on [HiveTransactionRepository] (implementation).
///
/// This means if we ever switch from Hive to SQLite,
/// we only change this one provider.
///
/// Usage in other providers:
/// ```dart
/// final repo = ref.watch(transactionRepositoryProvider);
/// ```
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final repository = HiveTransactionRepository();
  return repository;
});
