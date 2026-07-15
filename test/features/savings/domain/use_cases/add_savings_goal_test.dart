import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/savings/domain/entities/savings_goal.dart';
import 'package:koshly/features/savings/domain/use_cases/add_savings_goal.dart';
import '../../../../helpers/fakes/fake_savings_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeSavingsRepository repository;
  late AddSavingsGoal addSavingsGoal;

  setUp(() {
    repository = FakeSavingsRepository();
    addSavingsGoal = AddSavingsGoal(repository);
  });

  tearDown(() {
    repository.reset();
  });

  group('AddSavingsGoal', () {
    group('success cases', () {
      test('should save a valid savings goal', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal;

        // Act
        final result = await addSavingsGoal.call(goal);

        // Assert
        expect(result.id, goal.id);
        expect(result.title, goal.title);
        expect(result.targetAmount, goal.targetAmount);
        expect(repository.goals.length, 1);
      });

      test('should save a goal without a deadline', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal;

        // Act
        final result = await addSavingsGoal.call(goal);

        // Assert
        expect(result.hasDeadline, false);
        expect(result.deadline, isNull);
      });

      test('should save a goal with a deadline', () async {
        // Arrange
        final goal = TestData.laptopGoal;

        // Act
        final result = await addSavingsGoal.call(goal);

        // Assert
        expect(result.hasDeadline, true);
        expect(result.deadline, isNotNull);
      });

      test('should save a goal with zero current amount', () async {
        // Arrange
        final goal = TestData.laptopGoal;

        // Act
        final result = await addSavingsGoal.call(goal);

        // Assert
        expect(result.currentAmount, 0.0);
        expect(result.progressPercentage, 0.0);
      });

      test('should save a completed goal', () async {
        // Arrange
        final goal = TestData.vacationGoal;

        // Act
        final result = await addSavingsGoal.call(goal);

        // Assert
        expect(result.isCompleted, true);
        expect(result.progressPercentage, 100.0);
      });

      test('should save multiple goals', () async {
        // Act
        await addSavingsGoal.call(TestData.emergencyFundGoal);
        await addSavingsGoal.call(TestData.vacationGoal);
        await addSavingsGoal.call(TestData.laptopGoal);

        // Assert
        expect(repository.goals.length, 3);
      });
    });

    group('validation - title', () {
      test('should throw ArgumentError when title is empty', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal.copyWith(title: '');

        // Act & Assert
        expect(() => addSavingsGoal.call(goal), throwsA(isA<ArgumentError>()));
      });

      test(
        'should throw ArgumentError when title is whitespace only',
        () async {
          // Arrange
          final goal = TestData.emergencyFundGoal.copyWith(title: '   ');

          // Act & Assert
          expect(
            () => addSavingsGoal.call(goal),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });

    group('validation - target amount', () {
      test('should throw ArgumentError when target is zero', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal.copyWith(targetAmount: 0.0);

        // Act & Assert
        expect(() => addSavingsGoal.call(goal), throwsA(isA<ArgumentError>()));
      });

      test('should throw ArgumentError when target is negative', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal.copyWith(targetAmount: -1000.0);

        // Act & Assert
        expect(() => addSavingsGoal.call(goal), throwsA(isA<ArgumentError>()));
      });
    });

    group('validation - current amount', () {
      test('should throw ArgumentError when current is negative', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal.copyWith(currentAmount: -100.0);

        // Act & Assert
        expect(() => addSavingsGoal.call(goal), throwsA(isA<ArgumentError>()));
      });

      test('should throw ArgumentError when current exceeds target', () async {
        // Arrange
        final goal = TestData.emergencyFundGoal.copyWith(
          targetAmount: 1000.0,
          currentAmount: 1500.0,
        );

        // Act & Assert
        expect(() => addSavingsGoal.call(goal), throwsA(isA<ArgumentError>()));
      });
    });

    group('validation - deadline', () {
      test('should throw ArgumentError when deadline is in the past', () async {
        // Arrange
        final goal = SavingsGoal(
          id: 'goal-test',
          title: 'Test Goal',
          targetAmount: 1000.0,
          currentAmount: 0.0,
          iconCode: 0xe910,
          colorValue: 0xFF3498DB,
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(() => addSavingsGoal.call(goal), throwsA(isA<ArgumentError>()));
      });

      test('should accept a goal with future deadline', () async {
        // Arrange
        final goal = SavingsGoal(
          id: 'goal-test',
          title: 'Test Goal',
          targetAmount: 1000.0,
          currentAmount: 0.0,
          iconCode: 0xe910,
          colorValue: 0xFF3498DB,
          deadline: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        );

        // Act
        final result = await addSavingsGoal.call(goal);

        // Assert
        expect(result.hasDeadline, true);
        expect(repository.goals.length, 1);
      });
    });
  });
}
