import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';
import 'package:koshly/features/transactions/domain/use_cases/update_transaction.dart';
import '../../../../helpers/fakes/fake_transaction_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeTransactionRepository repository;
  late UpdateTransaction updateTransaction;

  // ─── Setup ───────────────────────────────────────────────────
  setUp(() {
    repository = FakeTransactionRepository();
    updateTransaction = UpdateTransaction(repository);
    repository.seedCategories(TestData.allCategories);
    repository.seedTransactions([TestData.salaryTransaction]);
  });

  tearDown(() {
    repository.reset();
  });

  // ─── Tests ───────────────────────────────────────────────────
  group('UpdateTransaction', () {
    group('success cases', () {
      test('should update the title of an existing transaction', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(
          title: 'Updated Salary',
        );

        // Act
        final result = await updateTransaction.call(updated);

        // Assert
        expect(result.title, 'Updated Salary');
        expect(repository.transactions.length, 1);
        expect(repository.transactions.first.title, 'Updated Salary');
      });

      test('should update the amount of an existing transaction', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(amount: 6000.00);

        // Act
        final result = await updateTransaction.call(updated);

        // Assert
        expect(result.amount, 6000.00);
        expect(repository.transactions.first.amount, 6000.00);
      });

      test('should update the category of an existing transaction', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(
          category: TestData.freelanceCategory,
        );

        // Act
        final result = await updateTransaction.call(updated);

        // Assert
        expect(result.category.id, TestData.freelanceCategory.id);
        expect(result.category.name, 'Freelance');
      });

      test('should update the type from income to expense', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(
          type: TransactionType.expense,
          category: TestData.foodCategory,
        );

        // Act
        final result = await updateTransaction.call(updated);

        // Assert
        expect(result.type, TransactionType.expense);
        expect(result.type.isExpense, true);
      });

      test('should update the note of an existing transaction', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(
          note: 'Updated note',
        );

        // Act
        final result = await updateTransaction.call(updated);

        // Assert
        expect(result.note, 'Updated note');
      });

      test('should not change the total count after update', () async {
        // Arrange
        repository.seedTransactions([
          TestData.groceryTransaction,
          TestData.busTransaction,
        ]);
        // Now we have 3 transactions total (1 from setUp + 2 seeded)

        final updated = TestData.salaryTransaction.copyWith(
          title: 'Updated Title',
        );

        // Act
        await updateTransaction.call(updated);

        // Assert
        expect(repository.transactions.length, 3);
      });
    });

    group('validation - title', () {
      test('should throw ArgumentError when title is empty', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(title: '');

        // Act & Assert
        expect(
          () => updateTransaction.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'should throw ArgumentError when title is whitespace only',
        () async {
          // Arrange
          final updated = TestData.salaryTransaction.copyWith(title: '   ');

          // Act & Assert
          expect(
            () => updateTransaction.call(updated),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });

    group('validation - amount', () {
      test('should throw ArgumentError when amount is zero', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(amount: 0.0);

        // Act & Assert
        expect(
          () => updateTransaction.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when amount is negative', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(amount: -100.0);

        // Act & Assert
        expect(
          () => updateTransaction.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('validation - date', () {
      test('should throw ArgumentError when date is in the future', () async {
        // Arrange
        final updated = TestData.salaryTransaction.copyWith(
          date: DateTime.now().add(const Duration(days: 1)),
        );

        // Act & Assert
        expect(
          () => updateTransaction.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
