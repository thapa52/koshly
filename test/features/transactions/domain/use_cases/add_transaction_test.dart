import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/transactions/domain/entities/transaction.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';
import 'package:koshly/features/transactions/domain/use_cases/add_transaction.dart';

import '../../../../helpers/fakes/fake_transaction_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeTransactionRepository repository;
  late AddTransaction addTransaction;

  // ─── Setup ───────────────────────────────────────────────────
  setUp(() {
    repository = FakeTransactionRepository();
    addTransaction = AddTransaction(repository);
    repository.seedCategories(TestData.allCategories);
  });

  tearDown(() {
    repository.reset();
  });

  // ─── Tests ───────────────────────────────────────────────────
  group('AddTransaction', () {
    group('success cases', () {
      test('should save a valid income transaction', () async {
        // Arrange
        final transaction = TestData.salaryTransaction;

        // Act
        final result = await addTransaction.call(transaction);

        // Assert
        expect(result.id, transaction.id);
        expect(result.title, transaction.title);
        expect(result.amount, transaction.amount);
        expect(result.type, TransactionType.income);
        expect(repository.transactions.length, 1);
      });

      test('should save a valid expense transaction', () async {
        // Arrange
        final transaction = TestData.groceryTransaction;

        // Act
        final result = await addTransaction.call(transaction);

        // Assert
        expect(result.id, transaction.id);
        expect(result.type, TransactionType.expense);
        expect(repository.transactions.length, 1);
      });

      test('should save a transaction without a note', () async {
        // Arrange
        final transaction = TestData.freelanceTransaction;

        // Act
        final result = await addTransaction.call(transaction);

        // Assert
        expect(result.note, isNull);
        expect(repository.transactions.length, 1);
      });

      test('should save multiple transactions', () async {
        // Act
        await addTransaction.call(TestData.salaryTransaction);
        await addTransaction.call(TestData.groceryTransaction);
        await addTransaction.call(TestData.busTransaction);

        // Assert
        expect(repository.transactions.length, 3);
      });
    });

    group('validation - title', () {
      test('should throw ArgumentError when title is empty', () async {
        // Arrange
        final transaction = Transaction(
          id: 'txn-test',
          title: '',
          amount: 100.0,
          type: TransactionType.expense,
          category: TestData.foodCategory,
          date: DateTime(2025, 6, 1),
          createdAt: DateTime(2025, 6, 1),
        );

        // Act & Assert
        expect(
          () => addTransaction.call(transaction),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'should throw ArgumentError when title is whitespace only',
        () async {
          // Arrange
          final transaction = Transaction(
            id: 'txn-test',
            title: '   ',
            amount: 100.0,
            type: TransactionType.expense,
            category: TestData.foodCategory,
            date: DateTime(2025, 6, 1),
            createdAt: DateTime(2025, 6, 1),
          );

          // Act & Assert
          expect(
            () => addTransaction.call(transaction),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });

    group('validation - amount', () {
      test('should throw ArgumentError when amount is zero', () async {
        // Arrange
        final transaction = Transaction(
          id: 'txn-test',
          title: 'Test',
          amount: 0.0,
          type: TransactionType.expense,
          category: TestData.foodCategory,
          date: DateTime(2025, 6, 1),
          createdAt: DateTime(2025, 6, 1),
        );

        // Act & Assert
        expect(
          () => addTransaction.call(transaction),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when amount is negative', () async {
        // Arrange
        final transaction = Transaction(
          id: 'txn-test',
          title: 'Test',
          amount: -50.0,
          type: TransactionType.expense,
          category: TestData.foodCategory,
          date: DateTime(2025, 6, 1),
          createdAt: DateTime(2025, 6, 1),
        );

        // Act & Assert
        expect(
          () => addTransaction.call(transaction),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('validation - date', () {
      test('should throw ArgumentError when date is in the future', () async {
        // Arrange
        final transaction = Transaction(
          id: 'txn-test',
          title: 'Test',
          amount: 100.0,
          type: TransactionType.expense,
          category: TestData.foodCategory,
          date: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => addTransaction.call(transaction),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept today as a valid date', () async {
        // Arrange
        final transaction = Transaction(
          id: 'txn-test',
          title: 'Test',
          amount: 100.0,
          type: TransactionType.expense,
          category: TestData.foodCategory,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act
        final result = await addTransaction.call(transaction);

        // Assert
        expect(result.id, 'txn-test');
        expect(repository.transactions.length, 1);
      });
    });
  });
}
