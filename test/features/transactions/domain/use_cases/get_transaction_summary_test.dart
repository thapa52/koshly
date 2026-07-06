import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/transactions/domain/use_cases/get_transaction_summary.dart';

import '../../../../helpers/fakes/fake_transaction_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeTransactionRepository repository;
  late GetTransactionSummary getTransactionSummary;

  // ─── Setup ───────────────────────────────────────────────────
  setUp(() {
    repository = FakeTransactionRepository();
    getTransactionSummary = GetTransactionSummary(repository);
    repository.seedCategories(TestData.allCategories);
  });

  tearDown(() {
    repository.reset();
  });

  // ─── Tests ───────────────────────────────────────────────────
  group('GetTransactionSummary', () {
    group('empty repository', () {
      test('should return zero income when no transactions exist', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.totalIncome, 0.0);
      });

      test('should return zero expenses when no transactions exist', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.totalExpenses, 0.0);
      });

      test('should return zero balance when no transactions exist', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.balance, 0.0);
      });

      test('should return zero count when no transactions exist', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.transactionCount, 0);
        expect(result.hasTransactions, false);
      });
    });

    group('with transactions', () {
      setUp(() {
        repository.seedTransactions(TestData.allTransactions);
      });

      test('should calculate total income correctly', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.totalIncome, TestData.totalIncome);
      });

      test('should calculate total expenses correctly', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.totalExpenses, TestData.totalExpenses);
      });

      test('should calculate balance correctly', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.balance, TestData.balance);
      });

      test('should return correct transaction count', () async {
        // Act
        final result = await getTransactionSummary.call();

        // Assert
        expect(result.transactionCount, TestData.transactionCount);
        expect(result.hasTransactions, true);
      });

      test(
        'should return positive balance when income exceeds expenses',
        () async {
          // Act
          final result = await getTransactionSummary.call();

          // Assert
          expect(result.isPositiveBalance, true);
          expect(result.balance, greaterThan(0));
        },
      );

      test(
        'should return negative balance when expenses exceed income',
        () async {
          // Arrange
          repository.reset();
          repository.seedCategories(TestData.allCategories);
          repository.seedTransactions([
            TestData.groceryTransaction, // -85.50
            TestData.busTransaction, // -50.00
            TestData.shoppingTransaction, // -120.00
          ]);

          // Act
          final result = await getTransactionSummary.call();

          // Assert
          expect(result.isPositiveBalance, false);
          expect(result.balance, lessThan(0));
        },
      );
    });

    group('with date range', () {
      setUp(() {
        repository.seedTransactions(TestData.allTransactions);
      });

      test('should calculate summary for specific date range', () async {
        // Arrange
        // June 1 to June 2:
        // salary (income, June 1) + bus (expense, June 2)
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 2);

        // Act
        final result = await getTransactionSummary.call(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(result.totalIncome, 5000.00);
        expect(result.totalExpenses, 50.00);
        expect(result.balance, 4950.00);
        expect(result.transactionCount, 2);
        expect(result.startDate, startDate);
        expect(result.endDate, endDate);
      });

      test(
        'should return zero summary for date range with no transactions',
        () async {
          // Arrange
          final startDate = DateTime(2024, 1, 1);
          final endDate = DateTime(2024, 1, 31);

          // Act
          final result = await getTransactionSummary.call(
            startDate: startDate,
            endDate: endDate,
          );

          // Assert
          expect(result.totalIncome, 0.0);
          expect(result.totalExpenses, 0.0);
          expect(result.balance, 0.0);
          expect(result.transactionCount, 0);
        },
      );
    });

    group('validation', () {
      test(
        'should throw ArgumentError when only startDate is provided',
        () async {
          // Act & Assert
          expect(
            () => getTransactionSummary.call(startDate: DateTime(2025, 6, 1)),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'should throw ArgumentError when only endDate is provided',
        () async {
          // Act & Assert
          expect(
            () => getTransactionSummary.call(endDate: DateTime(2025, 6, 30)),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'should throw ArgumentError when startDate is after endDate',
        () async {
          // Act & Assert
          expect(
            () => getTransactionSummary.call(
              startDate: DateTime(2025, 6, 30),
              endDate: DateTime(2025, 6, 1),
            ),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('should accept same startDate and endDate', () async {
        // Arrange
        repository.seedTransactions([TestData.salaryTransaction]);
        final date = DateTime(2025, 6, 1);

        // Act
        final result = await getTransactionSummary.call(
          startDate: date,
          endDate: date,
        );

        // Assert
        expect(result.totalIncome, 5000.00);
        expect(result.transactionCount, 1);
      });
    });
  });
}
