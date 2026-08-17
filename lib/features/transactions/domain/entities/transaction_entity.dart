enum TransactionType {
  income, // thu
  expense, //chi
}

class TransactionEntity {
  final String? id;
  final String title;
  final int amount;
  final TransactionType type;
  final String category;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  
  const TransactionEntity({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  

  TransactionEntity copyWith({
    String? id,
    String? title,
    int? amount,
    TransactionType? type,
    String? category,
    String? note,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
