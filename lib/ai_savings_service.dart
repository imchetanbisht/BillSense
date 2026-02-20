import 'dart:convert';
import 'package:http/http.dart' as http;

class AISavingsService {

  static const String apiKey = "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";

  static Future<Map<String, dynamic>> generateTips({
    required double amount,
    required String category,
  }) async {

    try {

      String prompt = """
You are an intelligent financial advisor AI.

Analyze this expense and provide realistic saving advice.

Expense:
Amount: ₹$amount
Category: $category

Instructions:
- Give 4 personalized tips
- Tips must depend on amount level
- Mention approximate saving numbers where possible
- Avoid generic advice
- Be practical and realistic

Also estimate:
- potential_saving_amount (number only)

Return JSON only:

{
 "tips": ["tip1", "tip2", "tip3", "tip4"],
 "saving": 250
}
""";

      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.9
        }),
      );

      final data = jsonDecode(response.body);

      String content =
      data["choices"][0]["message"]["content"];

      content = content.replaceAll("```json", "");
      content = content.replaceAll("```", "");

      final parsed = jsonDecode(content);

      return {
        "tips": List<String>.from(parsed["tips"]),
        "saving": (parsed["saving"] as num).toDouble()
      };

    } catch (e) {

      /// fallback realistic
      return {
        "tips": [
          "Consider choosing lower-priced alternatives next time.",
          "Avoid add-ons that increase total cost significantly.",
          "Planning purchases in advance can reduce impulse spending.",
          "You may save 15-25% with optimized choices."
        ],
        "saving": amount * 0.2
      };
    }
  }
}