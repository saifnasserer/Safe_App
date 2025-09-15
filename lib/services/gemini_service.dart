import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of Gemini API analysis attempt
enum GeminiResult {
  success,
  resourceExhausted,
  networkError,
  invalidResponse,
  apiError
}

/// Service for communicating with Google Gemini API
class GeminiService {
  static const String _apiKey = 'AIzaSyBnaL_5rMDQYPpTdMXOTOlvmdUJJ7MydcM';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Cache for API status to avoid repeated calls
  static bool? _apiKeyValidCache;
  static bool? _apiAvailableCache;
  static DateTime? _lastApiCheck;
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Analyze receipt text using Gemini API
  /// Returns a tuple of (result, analysis) where result indicates the outcome
  Future<(GeminiResult, GeminiReceiptAnalysis?)> analyzeReceiptText(
      String ocrText) async {
    try {
      // Optimized prompt for reduced token usage
      const systemPrompt = '''Extract receipt data as JSON:
{
  "totalAmount": number,
  "currency": "ج.م"|"USD"|"EUR",
  "transactionType": "expense"|"income", 
  "merchant": string,
  "date": "YYYY-MM-DD",
  "paymentMethod": string,
  "title": "Arabic title with merchant name",
  "confidence": 0.0-1.0
}

Rules: Extract main amount only, default to "expense", create Arabic title with merchant.''';

      final userPrompt = 'Receipt text: $ocrText';

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
          'maxOutputTokens': 200, // Reduced from 500 for cost optimization
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

        // Check for API errors in the response
        if (responseData['error'] != null) {
          final error = responseData['error'];
          final errorCode = error['code']?.toString() ?? '';
          final errorMessage = error['message']?.toString() ?? '';

          print('Gemini API Error in response: $errorCode - $errorMessage');

          // Check for resource exhausted error
          if (errorCode == '429' ||
              errorMessage.toLowerCase().contains('resource_exhausted') ||
              errorMessage.toLowerCase().contains('quota')) {
            return (GeminiResult.resourceExhausted, null);
          }

          // Check for service unavailable error (503)
          if (errorCode == '503' ||
              errorMessage.toLowerCase().contains('overloaded') ||
              errorMessage.toLowerCase().contains('unavailable') ||
              errorMessage.toLowerCase().contains('try again later')) {
            print('Gemini API Service Unavailable (503): $errorMessage');
            return (
              GeminiResult.resourceExhausted,
              null
            ); // Treat as resource exhausted for fallback
          }

          // Invalidate cache on API errors
          _invalidateCache();
          return (GeminiResult.apiError, null);
        }

        // Extract the generated content
        final candidates = responseData['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'];

          print('Gemini API response content: $content');

          // Parse the JSON response
          try {
            final analysis =
                GeminiReceiptAnalysis.fromJson(jsonDecode(content));
            print(
                'Gemini analysis parsed successfully: ${analysis.totalAmount}, confidence: ${analysis.confidence}');
            return (GeminiResult.success, analysis);
          } catch (parseError) {
            print('Error parsing Gemini analysis JSON: $parseError');
            print('Content was: $content');
            return (GeminiResult.invalidResponse, null);
          }
        } else {
          return (GeminiResult.invalidResponse, null);
        }
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        print('Gemini API Rate Limit Exceeded: ${response.body}');
        return (GeminiResult.resourceExhausted, null);
      } else if (response.statusCode == 503) {
        // Service unavailable
        print('Gemini API Service Unavailable (503): ${response.body}');
        return (
          GeminiResult.resourceExhausted,
          null
        ); // Treat as resource exhausted for fallback
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        // Invalidate cache on HTTP errors
        _invalidateCache();
        return (GeminiResult.apiError, null);
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      // Check if it's a network-related error
      if (e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('timeout')) {
        // Invalidate cache on network errors
        _invalidateCache();
        return (GeminiResult.networkError, null);
      }
      // Invalidate cache on other errors
      _invalidateCache();
      return (GeminiResult.apiError, null);
    }
  }

  /// Test API key validity with caching
  Future<bool> testApiKey() async {
    // Check cache first
    if (_apiKeyValidCache != null &&
        _lastApiCheck != null &&
        DateTime.now().difference(_lastApiCheck!) < _cacheValidity) {
      print('Using cached API key validity: $_apiKeyValidCache');
      return _apiKeyValidCache!;
    }

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

      bool isValid = false;
      if (response.statusCode == 401 || response.statusCode == 403) {
        print('API Key is invalid or has insufficient permissions');
        isValid = false;
      } else if (response.statusCode == 200) {
        print('API Key is valid');
        isValid = true;
      } else {
        print('API Key test failed with status: ${response.statusCode}');
        isValid = false;
      }

      // Cache the result
      _apiKeyValidCache = isValid;
      _lastApiCheck = DateTime.now();

      return isValid;
    } catch (e) {
      print('API Key test failed with exception: $e');
      _apiKeyValidCache = false;
      _lastApiCheck = DateTime.now();
      return false;
    }
  }

  /// Check if the service is available (network connectivity) with caching
  Future<bool> isAvailable() async {
    // Check cache first
    if (_apiAvailableCache != null &&
        _lastApiCheck != null &&
        DateTime.now().difference(_lastApiCheck!) < _cacheValidity) {
      print('Using cached API availability: $_apiAvailableCache');
      return _apiAvailableCache!;
    }

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

      bool isAvailable = response.statusCode == 200;

      // Cache the result
      _apiAvailableCache = isAvailable;
      _lastApiCheck = DateTime.now();

      return isAvailable;
    } catch (e) {
      print('Gemini API connectivity test failed: $e');
      _apiAvailableCache = false;
      _lastApiCheck = DateTime.now();
      return false;
    }
  }

  /// Clear API status cache (useful for testing or when API status changes)
  static void clearCache() {
    _apiKeyValidCache = null;
    _apiAvailableCache = null;
    _lastApiCheck = null;
    print('Gemini API cache cleared');
  }

  /// Invalidate cache on API errors (called internally)
  static void _invalidateCache() {
    _apiKeyValidCache = null;
    _apiAvailableCache = null;
    _lastApiCheck = null;
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
