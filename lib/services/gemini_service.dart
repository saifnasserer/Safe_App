import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for communicating with Google Gemini API
class GeminiService {
  static const String _apiKey = 'AIzaSyB_t-vY4UvvOhgy8_dLd8Yg8PB95oyiuD4';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Analyze receipt text using Gemini API
  Future<GeminiReceiptAnalysis?> analyzeReceiptText(String ocrText) async {
    try {
      // Prepare the prompt
      const systemPrompt =
          '''You are an expert receipt analyzer. Analyze the following text extracted from a receipt and return the information in JSON format.

Extract the following information:
- totalAmount: The main transaction amount (as a number, not string)
- currency: The currency code (e.g., "EGP", "USD", "ج.م")
- transactionType: "income" or "expense" based on context
- merchant: The store/company name
- date: The transaction date in YYYY-MM-DD format
- paymentMethod: How the payment was made (cash, card, etc.)
- title: A concise, descriptive title for the transaction in Arabic. For expenses use "دفع إلى" (payment to) or "شراء من" (purchase from), for income use "استلام من" (received from). Include merchant name if available (e.g., "دفع إلى AhmedBinstaPay", "شراء قهوة من ستار بكس", "تسوق من السوبر ماركت", "استلام راتب من الشركة")
- confidence: Your confidence in the analysis (0.0 to 1.0)

Rules:
1. For totalAmount, extract only the main transaction amount, not subtotals or taxes
2. If multiple amounts exist, choose the largest reasonable amount
3. For transactionType, look for keywords like "paid", "purchase", "withdrawal" (expense) or "received", "deposit", "salary" (income)
4. If unclear, default to "expense"
5. For title, create a short, descriptive title in Arabic based on transaction type:
   - For expenses: use "دفع إلى [MerchantName]" (payment to) or "شراء من [MerchantName]" (purchase from)
   - For income: use "استلام من [MerchantName]" (received from)
   - If merchant name is not clear or available, create a descriptive title without it
6. For confidence, consider text clarity and completeness
7. Return only valid JSON, no additional text
8. Ensure totalAmount is a number, not a string''';

      final userPrompt = 'Analyze this receipt text:\n\n$ocrText';

      // Prepare the request body for Gemini API
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\n$userPrompt'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 1,
          'topP': 0.8,
          'maxOutputTokens': 500,
          'responseMimeType': 'application/json',
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      // Make the API request
      print('Making request to Gemini API...');
      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract the generated content
        final candidates = responseData['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'];

          print('Gemini API response content: $content');

          // Parse the JSON response
          final analysis = GeminiReceiptAnalysis.fromJson(jsonDecode(content));
          return analysis;
        }
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return null;
    }
    return null; // Fallback return
  }

  /// Test API key validity
  Future<bool> testApiKey() async {
    try {
      print('Testing Gemini API key validity...');
      print(
          'API Key format: ${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 5)}');
      print('API Key length: ${_apiKey.length}');

      // Test with a simple request
      final testRequest = {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Hello, this is a test message. Just say "Hello World" and nothing else.'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0,
          'maxOutputTokens': 10,
        }
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(testRequest),
          )
          .timeout(const Duration(seconds: 10));

      print('API Key test response: ${response.statusCode}');
      print('API Key test body: ${response.body}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        print('API Key is invalid or has insufficient permissions');
        return false;
      } else if (response.statusCode == 200) {
        print('API Key is valid');
        return true;
      } else {
        print('API Key test failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('API Key test failed with exception: $e');
      return false;
    }
  }

  /// Check if the service is available (network connectivity)
  Future<bool> isAvailable() async {
    try {
      print('Testing Gemini API connectivity...');

      // Simple test request
      final testRequest = {
        'contents': [
          {
            'parts': [
              {'text': 'Test'}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 5,
        }
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(testRequest),
          )
          .timeout(const Duration(seconds: 10));

      print('Connectivity test response: ${response.statusCode}');
      print('Connectivity test body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Gemini API connectivity test failed: $e');
      return false;
    }
  }
}

/// Model for Gemini API response
class GeminiReceiptAnalysis {
  final double totalAmount;
  final String currency;
  final String transactionType;
  final String? merchant;
  final String? date;
  final String? paymentMethod;
  final String? title;
  final double confidence;

  GeminiReceiptAnalysis({
    required this.totalAmount,
    required this.currency,
    required this.transactionType,
    this.merchant,
    this.date,
    this.paymentMethod,
    this.title,
    required this.confidence,
  });

  factory GeminiReceiptAnalysis.fromJson(Map<String, dynamic> json) {
    // Handle totalAmount as either string or number
    double totalAmount = 0.0;
    if (json['totalAmount'] != null) {
      if (json['totalAmount'] is String) {
        totalAmount = double.tryParse(json['totalAmount']) ?? 0.0;
      } else if (json['totalAmount'] is num) {
        totalAmount = json['totalAmount'].toDouble();
      }
    }

    // Handle confidence as either string or number
    double confidence = 0.5;
    if (json['confidence'] != null) {
      if (json['confidence'] is String) {
        confidence = double.tryParse(json['confidence']) ?? 0.5;
      } else if (json['confidence'] is num) {
        confidence = json['confidence'].toDouble();
      }
    }

    return GeminiReceiptAnalysis(
      totalAmount: totalAmount,
      currency: json['currency'] ?? 'ج.م',
      transactionType: json['transactionType'] ?? 'expense',
      merchant: json['merchant'],
      date: json['date'],
      paymentMethod: json['paymentMethod'],
      title: json['title'],
      confidence: confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'currency': currency,
      'transactionType': transactionType,
      'merchant': merchant,
      'date': date,
      'paymentMethod': paymentMethod,
      'title': title,
      'confidence': confidence,
    };
  }

  /// Convert to ReceiptData format
  Map<String, dynamic> toReceiptDataFormat() {
    return {
      'amount': totalAmount,
      'currency': currency,
      'merchant': merchant,
      'date': date != null ? DateTime.tryParse(date!) : null,
      'transactionType': transactionType,
      'paymentMethod': paymentMethod,
      'title': title,
      'confidence': confidence,
    };
  }

  @override
  String toString() {
    return 'GeminiReceiptAnalysis(amount: $totalAmount $currency, type: $transactionType, merchant: $merchant, confidence: $confidence)';
  }
}
