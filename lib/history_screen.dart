import 'dart:ui';
import 'package:flutter/material.dart';
import 'bill_data.dart';
import 'bill_service.dart';
import 'report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";
  String? _selectedCategory;

  final List<String> _categories = [
    "All", "Grocery", "Utilities", "Dining", "Medical", "Shopping"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Scan History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<BillData>>(
        valueListenable: BillService.billsNotifier,
        builder: (context, bills, child) {
          final filtered = bills.where((b) {
            final matchesQuery = b.vendorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                b.category.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedCategory == null ||
                _selectedCategory == "All" ||
                b.category.toLowerCase() == _selectedCategory!.toLowerCase();
            return matchesQuery && matchesCategory;
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search_rounded, color: Colors.white54),
                      hintText: "Search merchant or category...",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Category Filter Chips
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = (_selectedCategory == null && cat == "All") || _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6366F1),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        side: BorderSide(color: isSelected ? const Color(0xFF6366F1) : Colors.white12),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : "All";
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // List of Scanned Bills
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.receipt_long_rounded, size: 64, color: Colors.white24),
                            SizedBox(height: 14),
                            Text("No Scanned Bills Found", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text("Scan a receipt to start building your history", style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final bill = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ReportScreen(bill: bill)),
                                      );
                                    },
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.receipt_rounded, color: Color(0xFF6366F1), size: 22),
                                    ),
                                    title: Text(
                                      bill.vendorName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      "${bill.category} • ${_formatDate(bill.date)}",
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "₹${bill.amount.toInt()}",
                                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 17),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                          onPressed: () {
                                            _confirmDelete(context, bill);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _confirmDelete(BuildContext context, BillData bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Bill", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete the bill for ${bill.vendorName} (₹${bill.amount.toInt()})?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              BillService.deleteBill(bill);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}