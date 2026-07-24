class BillData {
  final String id;
  final String vendorName;
  final double amount;
  final String category;
  final DateTime date;
  final String imagePath;
  final String extractedText;

  BillData({
    String? id,
    required this.vendorName,
    required this.amount,
    required this.category,
    required this.date,
    this.imagePath = "",
    this.extractedText = "",
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class AIReportData {
  final String insightText;
  final String suggestionText;
  final double predictedSavings;
  final List<String> tips;

  AIReportData({
    required this.insightText,
    required this.suggestionText,
    required this.predictedSavings,
    required this.tips,
  });

  factory AIReportData.generateMock(BillData bill) {
    return AIReportData(
      insightText: "Your expense of ₹${bill.amount.toInt()} at ${bill.vendorName} is within normal threshold for ${bill.category}.",
      suggestionText: "Consider setting a monthly budget limit of ₹${(bill.amount * 0.85).toInt()} for ${bill.category} to maximize savings.",
      predictedSavings: bill.amount * 0.22,
      tips: [
        "Switch to monthly bulk purchases to save up to 15%.",
        "Use promotional discount codes during checkout.",
        "Opt for digital e-receipts for automatic expense tracking.",
      ],
    );
  }
}
