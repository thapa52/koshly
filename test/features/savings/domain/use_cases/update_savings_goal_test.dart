import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/savings/domain/use_cases/update_savings_goal.dart';
import '../../../../helpers/fakes/fake_savings_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeSavingsRepository repository;
  late UpdateSavingsGoal updateSavingsGoal;

  setUp(() {
    repository = FakeSavingsRepository();
    updateSavingsGoal = UpdateSavingsGoal(repository);
    repository.seedGoals([TestData.emergencyFundGoal]);
  });

  tearDown(() {
    repository.reset();
  });

  group('UpdateSavingsGoal', () {
    group('success cases', () {
      test('should update the title of an existing goal', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(
          title: 'Updated Emergency Fund',
        );

        // Act
        final result = await updateSavingsGoal.call(updated);

        // Assert
        expect(result.title, 'Updated Emergency Fund');
        expect(repository.goals.length, 1);
        expect(repository.goals.first.title, 'Updated Emergency Fund');
      });

      test('should update the target amount', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(
          targetAmount: 15000.0,
        );

        // Act
        final result = await updateSavingsGoal.call(updated);

        // Assert
        expect(result.targetAmount, 15000.0);
        expect(repository.goals.first.targetAmount, 15000.0);
      });

      test('should update the current amount', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(
          currentAmount: 5000.0,
        );

        // Act
        final result = await updateSavingsGoal.call(updated);

        // Assert
        expect(result.currentAmount, 5000.0);
      });

      test('should not change total count after update', () async {
        // Arrange
        repository.seedGoals([TestData.vacationGoal, TestData.laptopGoal]);
        final updated = TestData.emergencyFundGoal.copyWith(
          title: 'Updated Title',
        );

        // Act
        await updateSavingsGoal.call(updated);

        // Assert
        expect(repository.goals.length, 3);
      });

      test('should update progress percentage correctly', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(
          targetAmount: 10000.0,
          currentAmount: 5000.0,
        );

        // Act
        final result = await updateSavingsGoal.call(updated);

        // Assert
        expect(result.progressPercentage, 50.0);
        expect(result.progressFraction, 0.5);
      });
    });

    group('validation - title', () {
      test('should throw ArgumentError when title is empty', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(title: '');

        // Act & Assert
        expect(
          () => updateSavingsGoal.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when title is whitespace', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(title: '   ');

        // Act & Assert
        expect(
          () => updateSavingsGoal.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('validation - amounts', () {
      test('should throw ArgumentError when target is zero', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(targetAmount: 0.0);

        // Act & Assert
        expect(
          () => updateSavingsGoal.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when current is negative', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(
          currentAmount: -100.0,
        );

        // Act & Assert
        expect(
          () => updateSavingsGoal.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when current exceeds target', () async {
        // Arrange
        final updated = TestData.emergencyFundGoal.copyWith(
          targetAmount: 1000.0,
          currentAmount: 2000.0,
        );

        // Act & Assert
        expect(
          () => updateSavingsGoal.call(updated),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
