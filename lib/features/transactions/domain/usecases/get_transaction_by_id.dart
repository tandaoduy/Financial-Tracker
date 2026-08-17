import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionById {
  const GetTransactionById(this._repository);

  final TransactionRepository _repository;

  Future<TransactionEntity?> call(String id) {
    _validateId(id);

    return _repository.getTransactionById(id);
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID không được để trống');
    }
  }
}
