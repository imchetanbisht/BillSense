class BillModel {

  final double amount;
  final String category;
  final DateTime date;
  final String imagePath;

  BillModel({
    required this.amount,
    required this.category,
    required this.date,
    required this.imagePath,
  });
}

class BillService {

  /// 🔥 All scanned bills
  static final List<BillModel> _bills = [];

  /// Public getter
  static List<BillModel> get bills => _bills;

  /// ===============================
  /// 🔥 ADD OR UPDATE BILL (NO DUPLICATE)
  /// ===============================
  static void addOrUpdateBill({
    required double amount,
    required String category,
    required String imagePath,
  }) {

    int index =
    _bills.indexWhere((bill) => bill.imagePath == imagePath);

    if (index != -1) {

      /// UPDATE EXISTING
      _bills[index] = BillModel(
        amount: amount,
        category: category,
        date: DateTime.now(),
        imagePath: imagePath,
      );

    } else {

      /// ADD NEW
      _bills.add(
        BillModel(
          amount: amount,
          category: category,
          date: DateTime.now(),
          imagePath: imagePath,
        ),
      );
    }
  }

  /// ===============================
  /// 🔥 LAST SCANNED BILL
  /// ===============================
  static BillModel? get latestBill {

    if (_bills.isEmpty) return null;

    return _bills.last;
  }

  /// ===============================
  /// 🔥 TOTAL SPENDING
  /// ===============================
  static double get totalAmount {

    double total = 0;

    for (var bill in _bills) {
      total += bill.amount;
    }

    return total;
  }

  /// ===============================
  /// 🔥 CATEGORY TOTAL
  /// ===============================
  static Map<String, double> get categoryTotals {

    Map<String, double> map = {};

    for (var bill in _bills) {

      map[bill.category] =
          (map[bill.category] ?? 0) + bill.amount;
    }

    return map;
  }

  /// ===============================
  /// 🔥 HAS DATA
  /// ===============================
  static bool get hasData => _bills.isNotEmpty;

  /// ===============================
  /// 🔥 CLEAR ALL (optional reset)
  /// ===============================
  static void clear() {
    _bills.clear();
  }
}
