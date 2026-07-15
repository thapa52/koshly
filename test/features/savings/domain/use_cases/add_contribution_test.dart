import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/savings/domain/use_cases/add_contribution.dart';
import '../../../../helpers/fakes/fake_savings_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeSavingsRepository repository;
  late AddContribution addContribution;

  setUp(() {
    repository = FakeSavingsRepository();
    addContribution = AddContribution(repository);
    repository.seedGoals([TestData.emergencyFundGoal]);
  });

  tearDown(() {
    repository.reset();
  });

  group('AddContribution', () {
    group('success cases', () {
      test('should increase current amount by contribution', () async {
        // Arrange
        final initialAmount = TestData.emergencyFundGoal.currentAmount;
        const contribution = 500.0;

        // Act
        final result = await addContribution.call(
          goalId: TestData.emergencyFundGoal.id,
          amount: contribution,
        );

        // Assert
        expect(result.currentAmount, initialAmount + contribution);
      });

      test('should update progress percentage after contribution', () async {
        // Arrange
        // emergencyFundGoal: target=10000, current=3500
        // After adding 1000: current=4500, progress=45%
        const contribution = 1000.0;

        // Act
        final result = await addContribution.call(
          goalId: TestData.emergencyFundGoal.id,
          amount: contribution,
        );

        // Assert
        expect(result.progressPercentage, 45.0);
      });

      test('should complete a goal when contribution reaches target', () async {
        // Arrange
        // emergencyFundGoal: target=10000, current=3500
        // Adding 6500 should complete it
        const contribution = 6500.0;

        // Act
        final result = await addContribution.call(
          goalId: TestData.emergencyFundGoal.id,
          amount: contribution,
        );

        // Assert
        expect(result.isCompleted, true);
        expect(result.currentAmount, 10000.0);
        expect(result.progressPercentage, 100.0);
      });

      test('should allow contribution that exceeds target', () async {
        // Arrange
        // Adding more than needed should still work
        const contribution = 8000.0;

        // Act
        final result = await addContribution.call(
          goalId: TestData.emergencyFundGoal.id,
          amount: contribution,
        );

        // Assert
        expect(result.isCompleted, true);
        expect(result.progressPercentage, 100.0);
        expect(result.remainingAmount, 0.0);
      });

      test('should accept small decimal contributions', () async {
        // Arrange
        const contribution = 0.01;

        // Act
        final result = await addContribution.call(
          goalId: TestData.emergencyFundGoal.id,
          amount: contribution,
        );

        // Assert
        expect(
          result.currentAmount,
          TestData.emergencyFundGoal.currentAmount + contribution,
        );
      });

      test('should not affect other goals', () async {
        // Arrange
        repository.seedGoals([TestData.vacationGoal, TestData.laptopGoal]);

        // Act
        await addContribution.call(
          goalId: TestData.emergencyFundGoal.id,
          amount: 500.0,
        );

        // Assert
        final vacationGoal = repository.goals.firstWhere(
          (g) => g.id == TestData.vacationGoal.id,
        );
        expect(vacationGoal.currentAmount, TestData.vacationGoal.currentAmount);
      });
    });

    group('validation - goalId', () {
      test('should throw ArgumentError when goalId is empty', () async {
        // Act & Assert
        expect(
          () => addContribution.call(goalId: '', amount: 100.0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when goalId is whitespace', () async {
        // Act & Assert
        expect(
          () => addContribution.call(goalId: '   ', amount: 100.0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('validation - amount', () {
      test('should throw ArgumentError when amount is zero', () async {
        // Act & Assert
        expect(
          () => addContribution.call(
            goalId: TestData.emergencyFundGoal.id,
            amount: 0.0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when amount is negative', () async {
        // Act & Assert
        expect(
          () => addContribution.call(
            goalId: TestData.emergencyFundGoal.id,
            amount: -100.0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
