import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bill_data.dart';

class AIReportService {
  static const String apiKey = "sk-proj-demo";

  static AIReportData generateReport(BillData bill) {
    return AIReportData.generateMock(bill);
  }

  static Future<Map<String, dynamic>> generateReportAsync({
    required double amount,
    required String category,
    required String extractedText,
  }) async {
    try {
      final prompt = """
You are a financial AI assistant.

Bill OCR Text:
$extractedText

Amount: ₹$amount
Category: $category

Return STRICT JSON only:
{
  "insight": "Your expense pattern shows normal usage.",
  "suggestion": "Reducing unnecessary purchases can boost savings.",
  "saving": 250
}
""";

      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/responses"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4.1-mini",
          "input": prompt,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("AI request failed");
      }

      final data = jsonDecode(response.body);
      String content = data["output"][0]["content"][0]["text"];
      content = content.replaceAll("```json", "").replaceAll("```", "").trim();

      return jsonDecode(content);
    } catch (e) {
      return {
        "insight": "Your spending pattern shows moderate expenses for $category.",
        "suggestion": "Setting weekly spending limits can help increase savings.",
        "saving": amount * 0.22,
      };
    }
  }
}
