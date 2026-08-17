import '../core/database/app_database.dart';
import '../features/transactions/data/datasources/local/transaction_local_data_source.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/domain/usecases/add_transaction.dart';
import '../features/transactions/domain/usecases/delete_transaction.dart';
import '../features/transactions/domain/usecases/update_transaction.dart';
import '../features/transactions/domain/usecases/watch_transactions.dart';
import '../features/transactions/presentation/bloc/transaction_bloc.dart';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.transactionRepository,
  });

  final AppDatabase database;
  final TransactionRepository transactionRepository;

  factory AppDependencies.create() {
    final database = AppDatabase();
    final localDataSource = DriftTransactionLocalDataSource(database);
    final transactionRepository = TransactionRepositoryImpl(localDataSource);

    return AppDependencies._(
      database: database,
      transactionRepository: transactionRepository,
    );
  }

  TransactionBloc createTransactionBloc() {
    return TransactionBloc(
      watchTransactions: WatchTransactions(transactionRepository),
      addTransaction: AddTransaction(transactionRepository),
      updateTransaction: UpdateTransaction(transactionRepository),
      deleteTransaction: DeleteTransaction(transactionRepository),
    );
  }

  Future<void> dispose() {
    return database.close();
  }
}
