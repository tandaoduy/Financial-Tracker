import 'package:uuid/uuid.dart';

import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(TransactionEntity transaction) {
    _validateTransaction(transaction);

    final transactionWithId = transaction.copyWith(id: const Uuid().v4());

    return _repository.addTransaction(transactionWithId);
  }

  void _validateTransaction(TransactionEntity transaction) {
    if (transaction.title.trim().isEmpty) {
      throw ArgumentError('Tên giao dịch không được để trống');
    }

    if (transaction.amount <= 0) {
      throw ArgumentError('Số tiền phải lớn hơn 0');
    }

    if (transaction.category.trim().isEmpty) {
      throw ArgumentError('Danh mục không được để trống');
    }
  }
}
