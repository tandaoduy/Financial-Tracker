import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_data_source.dart';
import '../mappers/transaction_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._localDataSource);

  final TransactionLocalDataSource _localDataSource;

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return _localDataSource.watchTransactions().map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final row = await _localDataSource.getTransactionById(id);
    return row?.toEntity();
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) {
    return _localDataSource.addTransaction(transaction.toCompanion());
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) {
    return _localDataSource.updateTransaction(transaction.toCompanion());
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _localDataSource.deleteTransaction(id);
  }
}
