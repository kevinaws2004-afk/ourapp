/// Runs several repository writes atomically (e.g. finishing a focus
/// session creates its record and marks it finished, ADR-031). Domain code
/// depends on this interface; the data layer implements it with a database
/// transaction. Nested calls join the outer transaction.
abstract interface class UnitOfWork {
  Future<T> run<T>(Future<T> Function() body);
}
