import '../../domain/entities/transaction_entity.dart';

enum TransactionStatus {
  initial,
  loading,
  success,
  failure,
}

enum TransactionActionStatus {
  idle,
  loading,
  success,
  failure,
}

class TransactionState {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.actionStatus = TransactionActionStatus.idle,
    this.transactions = const [],
    this.errorMessage,
  });

  final TransactionStatus status;
  final TransactionActionStatus actionStatus;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  TransactionState copyWith({
    TransactionStatus? status,
    TransactionActionStatus? actionStatus,
    List<TransactionEntity>? transactions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      transactions: transactions ?? this.transactions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
