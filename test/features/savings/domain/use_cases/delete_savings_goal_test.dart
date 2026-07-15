import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/savings/domain/use_cases/delete_savings_goal.dart';
import '../../../../helpers/fakes/fake_savings_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeSavingsRepository repository;
  late DeleteSavingsGoal deleteSavingsGoal;

  setUp(() {
    repository = FakeSavingsRepository();
    deleteSavingsGoal = DeleteSavingsGoal(repository);
    repository.seedGoals(TestData.allGoals);
  });

  tearDown(() {
    repository.reset();
  });

  group('DeleteSavingsGoal', () {
    group('success cases', () {
      test('should delete a goal by ID', () async {
        // Arrange
        final idToDelete = TestData.emergencyFundGoal.id;
        final initialCount = repository.goals.length;

        // Act
        await deleteSavingsGoal.call(idToDelete);

        // Assert
        expect(repository.goals.length, initialCount - 1);
        expect(repository.goals.any((g) => g.id == idToDelete), false);
      });

      test('should only delete the targeted goal', () async {
        // Arrange
        final idToDelete = TestData.emergencyFundGoal.id;

        // Act
        await deleteSavingsGoal.call(idToDelete);

        // Assert
        expect(
          repository.goals.any((g) => g.id == TestData.vacationGoal.id),
          true,
        );
        expect(
          repository.goals.any((g) => g.id == TestData.laptopGoal.id),
          true,
        );
      });

      test('should reduce count by 1 after deletion', () async {
        // Arrange
        final initialCount = repository.goals.length;

        // Act
        await deleteSavingsGoal.call(TestData.emergencyFundGoal.id);

        // Assert
        expect(repository.goals.length, initialCount - 1);
      });

      test('should not crash when deleting non-existent ID', () async {
        // Arrange
        final initialCount = repository.goals.length;

        // Act
        await deleteSavingsGoal.call('non-existent-id');

        // Assert
        expect(repository.goals.length, initialCount);
      });

      test('should allow deleting all goals one by one', () async {
        // Act
        for (final goal in TestData.allGoals) {
          await deleteSavingsGoal.call(goal.id);
        }

        // Assert
        expect(repository.goals.length, 0);
      });

      test('should be able to delete a completed goal', () async {
        // Arrange
        final idToDelete = TestData.vacationGoal.id;

        // Act
        await deleteSavingsGoal.call(idToDelete);

        // Assert
        expect(repository.goals.any((g) => g.id == idToDelete), false);
      });
    });

    group('validation - id', () {
      test('should throw ArgumentError when ID is empty', () async {
        // Act & Assert
        expect(() => deleteSavingsGoal.call(''), throwsA(isA<ArgumentError>()));
      });

      test('should throw ArgumentError when ID is whitespace only', () async {
        // Act & Assert
        expect(
          () => deleteSavingsGoal.call('   '),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
