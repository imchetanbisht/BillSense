import 'package:flutter/material.dart';
import '../bill_service.dart';
import '../bill_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  @override
  Widget build(BuildContext context) {

    final bills = BillService.bills;

    /// EMPTY STATE
    if (bills.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("History"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Icon(
                Icons.receipt_long,
                color: Colors.white24,
                size: 70,
              ),

              SizedBox(height: 12),

              Text(
                "No Bills Scanned Yet",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// GROUP BY DATE
    Map<String, List<BillModel>> grouped = {};

    for (var bill in bills) {

      String dateKey =
          "${bill.date.day}/${bill.date.month}/${bill.date.year}";

      grouped.putIfAbsent(dateKey, () => []).add(bill);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// DATE HEADER
              Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...entry.value.map((bill) {

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF020617),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      /// ICON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt,
                          color: Colors.indigo,
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              bill.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _formatTime(bill.date),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// AMOUNT
                      Text(
                        "₹${bill.amount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// DELETE BUTTON
                      InkWell(
                        onTap: () => _deleteBill(bill),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// DELETE SINGLE BILL
  void _deleteBill(BillModel bill) {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          backgroundColor: const Color(0xFF020617),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Bill",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Do you want to delete this bill?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {

                BillService.bills.remove(bill);

                Navigator.pop(context);

                setState(() {});
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  /// FORMAT TIME
  static String _formatTime(DateTime date) {

    int hour = date.hour;
    int minute = date.minute;

    String period = hour >= 12 ? "PM" : "AM";

    hour = hour % 12;
    if (hour == 0) hour = 12;

    return "$hour:${minute.toString().padLeft(2, '0')} $period";
  }
}