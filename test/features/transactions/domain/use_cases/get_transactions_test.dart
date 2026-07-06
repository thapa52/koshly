import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';
import 'package:koshly/features/transactions/domain/use_cases/get_transactions.dart';

import '../../../../helpers/fakes/fake_transaction_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeTransactionRepository repository;
  late GetTransactions getTransactions;

  // ─── Setup ───────────────────────────────────────────────────
  setUp(() {
    repository = FakeTransactionRepository();
    getTransactions = GetTransactions(repository);
    repository.seedCategories(TestData.allCategories);
  });

  tearDown(() {
    repository.reset();
  });

  // ─── Tests ───────────────────────────────────────────────────
  group('GetTransactions', () {
    group('all()', () {
      test('should return empty list when repository is empty', () async {
        // Act
        final result = await getTransactions.all();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all transactions', () async {
        // Arrange
        repository.seedTransactions(TestData.allTransactions);

        // Act
        final result = await getTransactions.all();

        // Assert
        expect(result.length, TestData.transactionCount);
      });

      test('should return transactions sorted by date newest first', () async {
        // Arrange
        repository.seedTransactions(TestData.allTransactions);

        // Act
        final result = await getTransactions.all();

        // Assert
        for (int i = 0; i < result.length - 1; i++) {
          expect(
            result[i].date.isAfter(result[i + 1].date) ||
                result[i].date.isAtSameMomentAs(result[i + 1].date),
            true,
            reason: 'Transactions should be sorted newest first',
          );
        }
      });
    });

    group('byType()', () {
      setUp(() {
        repository.seedTransactions(TestData.allTransactions);
      });

      test('should return only income transactions', () async {
        // Act
        final result = await getTransactions.byType(TransactionType.income);

        // Assert
        expect(result.length, TestData.incomeTransactions.length);
        expect(result.every((t) => t.type.isIncome), true);
      });

      test('should return only expense transactions', () async {
        // Act
        final result = await getTransactions.byType(TransactionType.expense);

        // Assert
        expect(result.length, TestData.expenseTransactions.length);
        expect(result.every((t) => t.type.isExpense), true);
      });

      test(
        'should return empty list when no transactions match type',
        () async {
          // Arrange
          final emptyRepository = FakeTransactionRepository();
          emptyRepository.seedTransactions([TestData.salaryTransaction]);
          final useCase = GetTransactions(emptyRepository);

          // Act
          final result = await useCase.byType(TransactionType.expense);

          // Assert
          expect(result, isEmpty);
        },
      );
    });

    group('byDateRange()', () {
      setUp(() {
        repository.seedTransactions(TestData.allTransactions);
      });

      test('should return transactions within date range', () async {
        // Arrange
        // June 1 to June 3 should include:
        // salaryTransaction (June 1)
        // busTransaction (June 2)
        // groceryTransaction (June 3)
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 3);

        // Act
        final result = await getTransactions.byDateRange(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(result.length, 3);
        expect(
          result.every(
            (t) =>
                t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                t.date.isBefore(endDate.add(const Duration(days: 1))),
          ),
          true,
        );
      });

      test(
        'should return empty list when no transactions in date range',
        () async {
          // Arrange
          final startDate = DateTime(2024, 1, 1);
          final endDate = DateTime(2024, 1, 31);

          // Act
          final result = await getTransactions.byDateRange(
            startDate: startDate,
            endDate: endDate,
          );

          // Assert
          expect(result, isEmpty);
        },
      );

      test('should return single transaction for exact date', () async {
        // Arrange
        final exactDate = DateTime(2025, 6, 1);

        // Act
        final result = await getTransactions.byDateRange(
          startDate: exactDate,
          endDate: exactDate,
        );

        // Assert
        expect(result.length, 1);
        expect(result.first.id, TestData.salaryTransaction.id);
      });
    });

    group('byCategory()', () {
      setUp(() {
        repository.seedTransactions(TestData.allTransactions);
      });

      test('should return transactions for a specific category', () async {
        // Act
        final result = await getTransactions.byCategory(
          TestData.foodCategory.id,
        );

        // Assert
        expect(result.length, 1);
        expect(result.first.id, TestData.groceryTransaction.id);
        expect(
          result.every((t) => t.category.id == TestData.foodCategory.id),
          true,
        );
      });

      test(
        'should return empty list when category has no transactions',
        () async {
          // Act
          final result = await getTransactions.byCategory(
            'non-existent-category',
          );

          // Assert
          expect(result, isEmpty);
        },
      );

      test('should return multiple transactions for same category', () async {
        // Arrange
        final extraFoodTransaction = TestData.groceryTransaction.copyWith(
          id: 'txn-food-2',
          title: 'Restaurant',
          date: DateTime(2025, 6, 6),
        );
        repository.seedTransactions([extraFoodTransaction]);

        // Act
        final result = await getTransactions.byCategory(
          TestData.foodCategory.id,
        );

        // Assert
        expect(result.length, 2);
        expect(
          result.every((t) => t.category.id == TestData.foodCategory.id),
          true,
        );
      });
    });
  });
}
