import 'package:drift/drift.dart';

@DataClassName('TransactionRow')
@TableIndex(
  name: 'transactions_transaction_date',
  columns: {#transactionDate},
)
class Transactions extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  IntColumn get amount => integer()();

  TextColumn get type => text()();

  TextColumn get category => text()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get transactionDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
