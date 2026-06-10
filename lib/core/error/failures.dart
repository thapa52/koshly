/// Base class for all failures in the app.
/// Instead of throwing exceptions, we return failures.
/// This makes error handling explicit and testable.
abstract class Failure {
  final String message;

  const Failure({required this.message});

  @override
  String toString() => message;
}

/// Failure related to local database operations (Hive)
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

/// Failure related to invalid data or user input
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Failure related to reading/writing files (PDF, CSV export)
class FileFailure extends Failure {
  const FileFailure({required super.message});
}

/// Failure for any unexpected/unknown errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occured. Please try again.',
  });
}
