import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/hive_savings_repository.dart';
import '../../domain/repositories/savings_repository.dart';

/// Provides a single instance of [SavingsRepository].
///
/// The rest of the app depends on [SavingsRepository] (interface),
/// not on [HiveSavingsRepository] (implementation).
///
/// Usage in other providers:
/// ```dart
/// final repo = ref.watch(savingsRepositoryProvider);
/// ```
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final repository = HiveSavingsRepository();
  return repository;
});
