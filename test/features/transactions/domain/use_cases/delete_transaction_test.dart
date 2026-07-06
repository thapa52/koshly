import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/transactions/domain/use_cases/delete_transaction.dart';
import '../../../../helpers/fakes/fake_transaction_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeTransactionRepository repository;
  late DeleteTransaction deleteTransaction;

  // ─── Setup ───────────────────────────────────────────────────
  setUp(() {
    repository = FakeTransactionRepository();
    deleteTransaction = DeleteTransaction(repository);
    repository.seedCategories(TestData.allCategories);
    repository.seedTransactions(TestData.allTransactions);
  });

  tearDown(() {
    repository.reset();
  });

  // ─── Tests ───────────────────────────────────────────────────
  group('DeleteTransaction', () {
    group('success cases', () {
      test('should delete a transaction by ID', () async {
        // Arrange
        final idToDelete = TestData.salaryTransaction.id;
        final initialCount = repository.transactions.length;

        // Act
        await deleteTransaction.call(idToDelete);

        // Assert
        expect(repository.transactions.length, initialCount - 1);
        expect(repository.transactions.any((t) => t.id == idToDelete), false);
      });

      test('should only delete the targeted transaction', () async {
        // Arrange
        final idToDelete = TestData.groceryTransaction.id;

        // Act
        await deleteTransaction.call(idToDelete);

        // Assert
        expect(
          repository.transactions.any(
            (t) => t.id == TestData.salaryTransaction.id,
          ),
          true,
        );
        expect(
          repository.transactions.any(
            (t) => t.id == TestData.busTransaction.id,
          ),
          true,
        );
        expect(repository.transactions.any((t) => t.id == idToDelete), false);
      });

      test('should reduce count by 1 after deletion', () async {
        // Arrange
        final initialCount = repository.transactions.length;

        // Act
        await deleteTransaction.call(TestData.salaryTransaction.id);

        // Assert
        expect(repository.transactions.length, initialCount - 1);
      });

      test('should not crash when deleting non-existent ID', () async {
        // Arrange
        final initialCount = repository.transactions.length;

        // Act
        await deleteTransaction.call('non-existent-id');

        // Assert
        expect(repository.transactions.length, initialCount);
      });

      test('should allow deleting all transactions one by one', () async {
        // Act
        for (final transaction in TestData.allTransactions) {
          await deleteTransaction.call(transaction.id);
        }

        // Assert
        expect(repository.transactions.length, 0);
      });
    });

    group('validation - id', () {
      test('should throw ArgumentError when ID is empty', () async {
        // Act & Assert
        expect(() => deleteTransaction.call(''), throwsA(isA<ArgumentError>()));
      });

      test('should throw ArgumentError when ID is whitespace only', () async {
        // Act & Assert
        expect(
          () => deleteTransaction.call('   '),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
