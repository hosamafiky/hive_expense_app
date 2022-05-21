import 'package:hive/hive.dart';
import 'package:hive_expenses_tracker/models/transaction.dart';

class Boxes {
  static Box<Transaction> getTranscations() =>
      Hive.box<Transaction>('transactions');
}
