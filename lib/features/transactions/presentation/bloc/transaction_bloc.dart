import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required WatchTransactions watchTransactions,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  })  : _watchTransactions = watchTransactions,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        super(const TransactionState()) {
    on<TransactionsStarted>(_onTransactionsStarted);
    on<TransactionsChanged>(_onTransactionsChanged);
    on<TransactionsWatchFailed>(_onTransactionsWatchFailed);
    on<TransactionAddRequested>(_onTransactionAddRequested);
    on<TransactionUpdateRequested>(_onTransactionUpdateRequested);
    on<TransactionDeleteRequested>(_onTransactionDeleteRequested);
  }

  final WatchTransactions _watchTransactions;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  StreamSubscription<List<TransactionEntity>>? _transactionsSubscription;

  Future<void> _onTransactionsStarted(
    TransactionsStarted event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionStatus.loading,
      clearError: true,
    ));

    await _transactionsSubscription?.cancel();
    _transactionsSubscription = _watchTransactions().listen(
      (transactions) => add(TransactionsChanged(transactions)),
      onError: (Object error) {
        add(TransactionsWatchFailed(error.toString()));
      },
    );
  }

  void _onTransactionsChanged(
    TransactionsChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(
      status: TransactionStatus.success,
      transactions: event.transactions,
      clearError: true,
    ));
  }

  void _onTransactionsWatchFailed(
    TransactionsWatchFailed event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(
      status: TransactionStatus.failure,
      errorMessage: event.message,
    ));
  }

  Future<void> _onTransactionAddRequested(
    TransactionAddRequested event,
    Emitter<TransactionState> emit,
  ) {
    return _runAction(
      () => _addTransaction(event.transaction),
      emit,
    );
  }

  Future<void> _onTransactionUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionState> emit,
  ) {
    return _runAction(
      () => _updateTransaction(event.transaction),
      emit,
    );
  }

  Future<void> _onTransactionDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) {
    return _runAction(
      () => _deleteTransaction(event.id),
      emit,
    );
  }

  Future<void> _runAction(
    Future<void> Function() action,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      actionStatus: TransactionActionStatus.loading,
      clearError: true,
    ));

    try {
      await action();
      emit(state.copyWith(actionStatus: TransactionActionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: TransactionActionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _transactionsSubscription?.cancel();
    return super.close();
  }
}
