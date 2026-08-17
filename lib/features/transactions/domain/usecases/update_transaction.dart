import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(TransactionEntity transaction) {
    _validateTransaction(transaction);

    return _repository.updateTransaction(transaction);
  }

  void _validateTransaction(TransactionEntity transaction) {
    if (transaction.id == null || transaction.id!.trim().isEmpty) {
      throw ArgumentError('Giao dịch chưa có ID hợp lệ');
    }

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
