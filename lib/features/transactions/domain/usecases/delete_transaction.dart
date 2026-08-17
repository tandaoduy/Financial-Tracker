import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String id) {
    _validateId(id);

    return _repository.deleteTransaction(id);
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID không được để trống');
    }
  }
}
