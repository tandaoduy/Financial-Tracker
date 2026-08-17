import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions();//theo dõi list giao dichjvaf thêm dl khi có sự thay đổi

  Future<TransactionEntity?> getTransactionById(String id); //lấy dl theo id

  Future<void> addTransaction(TransactionEntity transaction);

  Future<void> updateTransaction(TransactionEntity transaction);

  Future<void> deleteTransaction(String id);
}
