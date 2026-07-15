import 'package:flutter_test/flutter_test.dart';
import 'package:koshly/features/savings/domain/use_cases/get_savings_goals.dart';
import '../../../../helpers/fakes/fake_savings_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeSavingsRepository repository;
  late GetSavingsGoals getSavingsGoals;

  setUp(() {
    repository = FakeSavingsRepository();
    getSavingsGoals = GetSavingsGoals(repository);
  });

  tearDown(() {
    repository.reset();
  });

  group('GetSavingsGoals', () {
    group('all()', () {
      test('should return empty list when repository is empty', () async {
        // Act
        final result = await getSavingsGoals.all();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all goals', () async {
        // Arrange
        repository.seedGoals(TestData.allGoals);

        // Act
        final result = await getSavingsGoals.all();

        // Assert
        expect(result.length, TestData.allGoals.length);
      });

      test(
        'should return goals sorted by creation date newest first',
        () async {
          // Arrange
          repository.seedGoals(TestData.allGoals);

          // Act
          final result = await getSavingsGoals.all();

          // Assert
          for (int i = 0; i < result.length - 1; i++) {
            expect(
              result[i].createdAt.isAfter(result[i + 1].createdAt) ||
                  result[i].createdAt.isAtSameMomentAs(result[i + 1].createdAt),
              true,
              reason: 'Goals should be sorted newest first',
            );
          }
        },
      );
    });

    group('active()', () {
      setUp(() {
        repository.seedGoals(TestData.allGoals);
      });

      test('should return only active goals', () async {
        // Act
        final result = await getSavingsGoals.active();

        // Assert
        expect(result.length, TestData.activeGoals.length);
        expect(result.every((g) => !g.isCompleted), true);
      });

      test('should not include completed goals', () async {
        // Act
        final result = await getSavingsGoals.active();

        // Assert
        expect(result.any((g) => g.id == TestData.vacationGoal.id), false);
      });
    });

    group('completed()', () {
      setUp(() {
        repository.seedGoals(TestData.allGoals);
      });

      test('should return only completed goals', () async {
        // Act
        final result = await getSavingsGoals.completed();

        // Assert
        expect(result.length, TestData.completedGoals.length);
        expect(result.every((g) => g.isCompleted), true);
      });

      test('should not include active goals', () async {
        // Act
        final result = await getSavingsGoals.completed();

        // Assert
        expect(result.any((g) => g.id == TestData.emergencyFundGoal.id), false);
      });
    });

    group('byId()', () {
      setUp(() {
        repository.seedGoals(TestData.allGoals);
      });

      test('should return a goal by ID', () async {
        // Act
        final result = await getSavingsGoals.byId(
          TestData.emergencyFundGoal.id,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.id, TestData.emergencyFundGoal.id);
        expect(result.title, TestData.emergencyFundGoal.title);
      });

      test('should return null for non-existent ID', () async {
        // Act
        final result = await getSavingsGoals.byId('non-existent-id');

        // Assert
        expect(result, isNull);
      });
    });
  });
}
