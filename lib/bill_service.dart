import 'package:flutter/material.dart';
import 'bill_data.dart';

class BillService {
  static final ValueNotifier<List<BillData>> billsNotifier = ValueNotifier<List<BillData>>([
    BillData(
      vendorName: "Supermarket Mart",
      amount: 1450.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: "Grocery",
    ),
    BillData(
      vendorName: "Electricity Board",
      amount: 2300.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: "Utilities",
    ),
    BillData(
      vendorName: "City Pharmacy",
      amount: 680.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: "Medical",
    ),
    BillData(
      vendorName: "Urban Diner",
      amount: 1120.0,
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: "Dining",
    ),
  ]);

  static List<BillData> get bills => billsNotifier.value;

  static bool get hasData => billsNotifier.value.isNotEmpty;

  static void addBill(BillData bill) {
    final updated = List<BillData>.from(billsNotifier.value)..insert(0, bill);
    billsNotifier.value = updated;
  }

  static void deleteBill(BillData bill) {
    final updated = List<BillData>.from(billsNotifier.value)..removeWhere((b) => b.id == bill.id);
    billsNotifier.value = updated;
  }

  static double get totalSpending {
    return billsNotifier.value.fold(0.0, (sum, item) => sum + item.amount);
  }

  static double get averageSpending {
    if (billsNotifier.value.isEmpty) return 0.0;
    return totalSpending / billsNotifier.value.length;
  }

  static double get totalEstimatedSavings {
    return totalSpending * 0.22;
  }

  static double categoryTotal(String category) {
    return billsNotifier.value
        .where((b) => b.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, b) => sum + b.amount);
  }
}
