import '../../domain/entities/transaction_entity.dart';

sealed class TransactionEvent {
  const TransactionEvent();
}

class TransactionsStarted extends TransactionEvent {
  const TransactionsStarted();
}

class TransactionsChanged extends TransactionEvent {
  const TransactionsChanged(this.transactions);

  final List<TransactionEntity> transactions;
}

class TransactionsWatchFailed extends TransactionEvent {
  const TransactionsWatchFailed(this.message);

  final String message;
}

class TransactionAddRequested extends TransactionEvent {
  const TransactionAddRequested(this.transaction);

  final TransactionEntity transaction;
}

class TransactionUpdateRequested extends TransactionEvent {
  const TransactionUpdateRequested(this.transaction);

  final TransactionEntity transaction;
}

class TransactionDeleteRequested extends TransactionEvent {
  const TransactionDeleteRequested(this.id);

  final String id;
}
