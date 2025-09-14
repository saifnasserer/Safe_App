import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of Gemini API analysis with error information
class GeminiAnalysisResult {
  final GeminiReceiptAnalysis? analysis;
  final bool isSuccess;
  final String? errorType;
  final String? errorMessage;

  GeminiAnalysisResult({
    this.analysis,
    required this.isSuccess,
    this.errorType,
    this.errorMessage,
  });

  /// Check if this is a quota/resource exhausted error
  bool get isResourceExhausted => errorType == 'RESOURCE_EXHAUSTED';
  
  /// Check if this is a network/connectivity error
  bool get isNetworkError => errorType == 'NETWORK_ERROR';
  
  /// Check if this is an API key error
  bool get isApiKeyError => errorType == 'API_KEY_ERROR';
}

/// Service for communicating with Google Gemini API
class GeminiService {
  static const String _apiKey = 'AIzaSyBnaL_5rMDQYPpTdMXOTOlvmdUJJ7MydcM';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Cache for storing recent analysis results to avoid duplicate API calls
  static final Map<String, GeminiAnalysisResult> _analysisCache = {};
  static const int _maxCacheSize = 50;
  static const Duration _cacheExpiry = Duration(hours: 1);

  /// Clear expired cache entries
  static void _clearExpiredCache() {
    final now = DateTime.now();
    _analysisCache.removeWhere((key, value) {
      // Simple cache expiry based on key timestamp
      final keyParts = key.split('_');
      if (keyParts.length > 1) {
        final timestamp = int.tryParse(keyParts.last);
        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return now.difference(cacheTime) > _cacheExpiry;
        }
      }
      return true;
    });
  }

  /// Generate cache key for text analysis
  static String _generateCacheKey(String text) {
    // Create a hash of the text for caching
    final textHash = text.hashCode;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'analysis_${textHash}_$timestamp';
  }

  /// Analyze receipt text using Gemini API with enhanced error handling
  Future<GeminiAnalysisResult> analyzeReceiptText(String ocrText) async {
    try {
      // Optimized, concise prompt to reduce token usage
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

      final userPrompt = 'Receipt text:\n$ocrText';

      // Optimized request body with reduced token usage
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
          'maxOutputTokens': 300, // Reduced from 500
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

      print('Making request to Gemini API...');

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check for API errors in the response
        if (responseData.containsKey('error')) {
          final error = responseData['error'];
          final errorCode = error['code']?.toString();
          final errorMessage = error['message']?.toString() ?? 'Unknown error';
          
          print('Gemini API Error: $errorCode - $errorMessage');
          
          // Handle specific error types
          if (errorCode == 'RESOURCE_EXHAUSTED' || 
              errorMessage.toLowerCase().contains('quota') ||
              errorMessage.toLowerCase().contains('resource')) {
            return GeminiAnalysisResult(
              isSuccess: false,
              errorType: 'RESOURCE_EXHAUSTED',
              errorMessage: errorMessage,
            );
          } else if (errorCode == 'PERMISSION_DENIED' || 
                     errorCode == 'UNAUTHENTICATED') {
            return GeminiAnalysisResult(
              isSuccess: false,
              errorType: 'API_KEY_ERROR',
              errorMessage: errorMessage,
            );
          } else {
            return GeminiAnalysisResult(
              isSuccess: false,
              errorType: 'API_ERROR',
              errorMessage: errorMessage,
            );
          }
        }

        // Extract the generated content
        final candidates = responseData['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final candidate = candidates[0];
          
          // Check if the response was blocked by safety filters
          if (candidate['finishReason'] == 'SAFETY') {
            return GeminiAnalysisResult(
              isSuccess: false,
              errorType: 'SAFETY_FILTER',
              errorMessage: 'Response blocked by safety filters',
            );
          }
          
          final content = candidate['content']['parts'][0]['text'];
          print('Gemini API response content: $content');

          try {
            // Parse the JSON response
            final analysis = GeminiReceiptAnalysis.fromJson(jsonDecode(content));
            return GeminiAnalysisResult(
              analysis: analysis,
              isSuccess: true,
            );
          } catch (parseError) {
            print('Failed to parse Gemini response: $parseError');
            return GeminiAnalysisResult(
              isSuccess: false,
              errorType: 'PARSE_ERROR',
              errorMessage: 'Failed to parse AI response',
            );
          }
        } else {
          return GeminiAnalysisResult(
            isSuccess: false,
            errorType: 'NO_CANDIDATES',
            errorMessage: 'No response candidates from Gemini',
          );
        }
      } else {
        // Handle HTTP error codes
        final errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        print('Gemini API HTTP Error: $errorMessage');
        
        String errorType = 'HTTP_ERROR';
        if (response.statusCode == 429) {
          errorType = 'RESOURCE_EXHAUSTED';
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          errorType = 'API_KEY_ERROR';
        }
        
        return GeminiAnalysisResult(
          isSuccess: false,
          errorType: errorType,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      
      // Determine error type based on exception
      String errorType = 'UNKNOWN_ERROR';
      String errorMessage = e.toString();
      
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        errorType = 'NETWORK_ERROR';
      }
      
      return GeminiAnalysisResult(
        isSuccess: false,
        errorType: errorType,
        errorMessage: errorMessage,
      );
    }
  }

  /// Analyze receipt text with caching support
  Future<GeminiAnalysisResult> analyzeReceiptTextWithCache(String ocrText) async {
    // Clear expired cache entries
    _clearExpiredCache();
    
    // Check cache first (simple text-based cache)
    final textHash = ocrText.hashCode.toString();
    final cachedResult = _analysisCache.values.firstWhere(
      (result) => result.analysis != null && 
                  result.analysis.toString().contains(textHash),
      orElse: () => GeminiAnalysisResult(isSuccess: false),
    );
    
    if (cachedResult.isSuccess) {
      print('Using cached Gemini analysis result');
      return cachedResult;
    }

    // If not in cache, make API call
    final result = await analyzeReceiptText(ocrText);
    
    // Cache successful results
    if (result.isSuccess && _analysisCache.length < _maxCacheSize) {
      final cacheKey = _generateCacheKey(ocrText);
      _analysisCache[cacheKey] = result;
    }
    
    return result;
  }

  /// Cache for API key validation to avoid repeated test calls
  static bool? _apiKeyValidated;
  static DateTime? _lastValidationTime;
  static const Duration _validationCacheDuration = Duration(hours: 1);

  /// Quick API key validation without making API calls
  bool _isApiKeyFormatValid() {
    // Basic format validation without API call
    return _apiKey.isNotEmpty && _apiKey.length > 20 && _apiKey.startsWith('AIza');
  }

  /// Test API key validity (with caching to avoid repeated calls)
  Future<bool> testApiKey() async {
    // Check if we have a recent validation result
    if (_apiKeyValidated != null && 
        _lastValidationTime != null && 
        DateTime.now().difference(_lastValidationTime!) < _validationCacheDuration) {
      print('Using cached API key validation result: $_apiKeyValidated');
      return _apiKeyValidated!;
    }

    // Quick format check first
    if (!_isApiKeyFormatValid()) {
      print('API Key format is invalid');
      _apiKeyValidated = false;
      _lastValidationTime = DateTime.now();
      return false;
    }

    try {
      print('Testing Gemini API key validity...');
      print('API Key format: ${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 5)}');
      print('API Key length: ${_apiKey.length}');

      // Test with a minimal request
      final testRequest = {
        'contents': [
          {
            'parts': [
              {'text': 'Hi'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0,
          'maxOutputTokens': 1, // Minimal tokens
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
          .timeout(const Duration(seconds: 5)); // Shorter timeout

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
      _apiKeyValidated = isValid;
      _lastValidationTime = DateTime.now();
      
      return isValid;
    } catch (e) {
      print('API Key test failed with exception: $e');
      _apiKeyValidated = false;
      _lastValidationTime = DateTime.now();
      return false;
    }
  }

  /// Check if the service is available (network connectivity) - OPTIMIZED
  Future<bool> isAvailable() async {
    // If API key is already validated, we can assume it's available
    if (_apiKeyValidated == true && 
        _lastValidationTime != null && 
        DateTime.now().difference(_lastValidationTime!) < _validationCacheDuration) {
      print('Using cached availability result: true');
      return true;
    }

    // If API key validation failed recently, don't make another call
    if (_apiKeyValidated == false && 
        _lastValidationTime != null && 
        DateTime.now().difference(_lastValidationTime!) < _validationCacheDuration) {
      print('Using cached availability result: false');
      return false;
    }

    // Only make a test call if we don't have recent validation
    return await testApiKey();
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