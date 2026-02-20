import 'dart:convert';
import 'package:http/http.dart' as http;
import '../bill_data_service.dart';

class OpenAIService {

  static const String apiKey = "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";

  static Future<String> generateTips() async {

    if (!BillDataService.hasData) {
      return "No spending data available.";
    }

    double total =
    BillDataService.records.fold(0, (sum, e) => sum + e.amount);

    int count = BillDataService.records.length;

    String prompt = """
User scanned $count bills.
Total spending is ₹$total.

Give smart financial saving tips in short bullet points.
""";

    try {

      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 150,
        }),
      );

      final data = jsonDecode(response.body);

      return data["choices"][0]["message"]["content"];

    } catch (e) {
      return "AI tips unavailable.";
    }
  }
}
