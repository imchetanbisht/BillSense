class BillRecord {
  final double amount;
  final DateTime date;

  BillRecord({
    required this.amount,
    required this.date,
  });
}

class BillDataService {

  static final List<BillRecord> _records = [];

  static void addRecord(double amount) {
    _records.add(
      BillRecord(
        amount: amount,
        date: DateTime.now(),
      ),
    );
  }

  static List<BillRecord> get records => _records;

  static double get totalSpent =>
      _records.fold(0, (sum, e) => sum + e.amount);

  static double get totalSaved =>
      totalSpent * 0.15; // assume 15% saving potential

  static bool get hasData => _records.isNotEmpty;
}
