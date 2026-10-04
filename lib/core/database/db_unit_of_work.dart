import '../transactions/unit_of_work.dart';
import 'app_database.dart';
import 'storage_guard.dart';

/// [UnitOfWork] as one drift transaction. Repositories called inside it
/// join it (drift nests them as savepoints).
class DbUnitOfWork implements UnitOfWork {
  const DbUnitOfWork(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() body) =>
      guardStorage('unitOfWork', () => _db.transaction(body));
}
