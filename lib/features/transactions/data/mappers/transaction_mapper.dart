import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';

extension TransactionRowMapper on TransactionRow {
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.values.byName(type),
      category: category,
      note: note,
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TransactionEntityMapper on TransactionEntity {
  TransactionsCompanion toCompanion() {
    final transactionId = id;
    if (transactionId == null || transactionId.trim().isEmpty) {
      throw ArgumentError('Giao dịch chưa có ID hợp lệ');
    }

    return TransactionsCompanion(
      id: Value(transactionId),
      title: Value(title.trim()),
      amount: Value(amount),
      type: Value(type.name),
      category: Value(category.trim()),
      note: Value(note?.trim()),
      transactionDate: Value(transactionDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
