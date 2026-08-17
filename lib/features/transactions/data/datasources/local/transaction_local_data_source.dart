import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';

abstract class TransactionLocalDataSource {
  Stream<List<TransactionRow>> watchTransactions();

  Future<TransactionRow?> getTransactionById(String id);

  Future<void> addTransaction(TransactionsCompanion transaction);

  Future<void> updateTransaction(TransactionsCompanion transaction);

  Future<void> deleteTransaction(String id);
}

class DriftTransactionLocalDataSource implements TransactionLocalDataSource {
  const DriftTransactionLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TransactionRow>> watchTransactions() {
    final query = _database.select(_database.transactions)
      ..orderBy([
        (transaction) => OrderingTerm.desc(transaction.transactionDate),
      ]);

    return query.watch();
  }

  @override
  Future<TransactionRow?> getTransactionById(String id) {
    final query = _database.select(_database.transactions)
      ..where((transaction) => transaction.id.equals(id));

    return query.getSingleOrNull();
  }

  @override
  Future<void> addTransaction(TransactionsCompanion transaction) async {
    await _database.into(_database.transactions).insert(transaction);
  }

  @override
  Future<void> updateTransaction(TransactionsCompanion transaction) async {
    await (_database.update(_database.transactions)
          ..where((row) => row.id.equals(transaction.id.value)))
        .write(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (_database.delete(_database.transactions)
          ..where((transaction) => transaction.id.equals(id)))
        .go();
  }
}
