import 'dart:convert';
import 'package:http/http.dart' as http;

class AIReportService {

  /// ⚠️ IMPORTANT
  /// Never hardcode API key in production
  static const String apiKey = "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";

  static Future<Map<String,dynamic>> generateReport({
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

Provide:

1. Short financial insight
2. Smart saving suggestion
3. Predicted saving amount in 2 months

Return STRICT JSON only:

{
"insight": "...",
"suggestion": "...",
"saving": 1234
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
        throw Exception("AI request failed: ${response.body}");
      }

      final data = jsonDecode(response.body);

      String content =
      data["output"][0]["content"][0]["text"];

      /// 🔥 CLEAN JSON
      content = content.replaceAll("```json", "");
      content = content.replaceAll("```", "");
      content = content.trim();

      final parsed = jsonDecode(content);

      return parsed;

    } catch (e) {

      /// 🔥 FALLBACK SAFE DATA
      return {
        "insight":
        "Your spending pattern shows moderate expenses. Monitoring your spending regularly can improve savings.",
        "suggestion":
        "Reducing unnecessary purchases by 10-15% and setting weekly limits may increase savings.",
        "saving": amount * 0.2
      };
    }
  }
}
