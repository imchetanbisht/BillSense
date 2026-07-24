class AmountExtractor {
  static double extractAmount(String text) {
    if (text.isEmpty) return 0.0;

    final lines = text.split('\n');
    double bestAmount = 0.0;
    double highestScore = -1.0;

    // RegEx patterns for currency values: e.g. 1,254.50, 450.00, ₹450, $12.99
    final RegExp priceRegExp = RegExp(r'(?:₹|\$|USD|INR|\b)\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)');

    final List<String> highPriorityKeywords = [
      "grand total",
      "total amount",
      "net payable",
      "amount due",
      "bal due",
      "balance due",
      "final total",
      "total due",
      "total:"
    ];

    final List<String> mediumPriorityKeywords = [
      "total",
      "subtotal",
      "amount",
      "net total",
      "paid"
    ];

    for (int i = 0; i < lines.length; i++) {
      final lineText = lines[i].toLowerCase().trim();
      if (lineText.isEmpty) continue;

      // Extract all price numbers in line
      final matches = priceRegExp.allMatches(lineText);
      for (final match in matches) {
        final rawVal = match.group(1)?.replaceAll(',', '') ?? '';
        final parsed = double.tryParse(rawVal);
        if (parsed == null || parsed <= 0.0) continue;

        double lineScore = 10.0;

        // Position bonus: lower half of receipt text receives a higher score
        double positionRatio = i / lines.length;
        lineScore += positionRatio * 35.0;

        // Check high priority keywords
        for (var kw in highPriorityKeywords) {
          if (lineText.contains(kw)) {
            lineScore += 120.0;
            break;
          }
        }

        // Check medium priority keywords if high priority wasn't matched
        if (lineScore < 100.0) {
          for (var kw in mediumPriorityKeywords) {
            if (lineText.contains(kw)) {
              lineScore += 50.0;
              break;
            }
          }
        }

        // Larger total amounts at the bottom get a slight magnitude boost
        lineScore += (parsed.clamp(0, 100000) / 10000.0) * 5.0;

        if (lineScore > highestScore) {
          highestScore = lineScore;
          bestAmount = parsed;
        }
      }
    }

    // Fallback: If no keyword line was found, pick max numeric value extracted
    if (bestAmount == 0.0) {
      final matches = priceRegExp.allMatches(text);
      for (final match in matches) {
        final rawVal = match.group(1)?.replaceAll(',', '') ?? '';
        final parsed = double.tryParse(rawVal) ?? 0.0;
        if (parsed > bestAmount) {
          bestAmount = parsed;
        }
      }
    }

    return bestAmount;
  }
}
