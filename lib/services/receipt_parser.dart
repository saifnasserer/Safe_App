import 'dart:math' as math;
import 'package:safe/models/receipt_data.dart';
import 'package:safe/services/gemini_service.dart';

/// Helper class to represent amount candidates with context and priority
class AmountCandidate {
  final double amount;
  final String context;
  final int priority;
  final int line;

  AmountCandidate({
    required this.amount,
    required this.context,
    required this.priority,
    required this.line,
  });
}

class ReceiptParser {
  static final GeminiService _geminiService = GeminiService();

  // Enhanced regex patterns for better amount detection
  static final Map<String, RegExp> _patterns = {
    // Enhanced amount patterns with thousands separators support
    'amount_with_currency': RegExp(
        r'(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)\s*(?:جنيه|جنيه مصري|ج\.م|EGP|د\.ع|دينار|SAR|ريال|USD|\$|€|ل\.ل|ليرة)',
        caseSensitive: false),

    // Amount after currency indicators
    'amount_after_currency': RegExp(
        r'(?:جنيه|جنيه مصري|ج\.م|EGP|د\.ع|دينار|SAR|ريال|USD|\$|€|ل\.ل|ليرة)\s*:?\s*(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)',
        caseSensitive: false),

    // Total/Sum patterns (high priority)
    'total_patterns': RegExp(
        r'(?:total|المجموع|الإجمالي|مبلغ|amount|price|سعر|المبلغ|الاجمالي|المجموع الكلي|تم تحويل)[\s:]*(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)',
        caseSensitive: false),

    // Subtotal patterns (medium priority)
    'subtotal_patterns': RegExp(
        r'(?:subtotal|المجموع الفرعي|المجموع الجزئي)[\s:]*(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)',
        caseSensitive: false),

    // Tax patterns (lower priority)
    'tax_patterns': RegExp(
        r'(?:tax|ضريبة|الضريبة|vat|vat tax)[\s:]*(\d+(?:\.\d{2})?)',
        caseSensitive: false),

    // Date patterns
    'date_arabic': RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})'),
    'date_english': RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})'),

    // Enhanced currency patterns
    'currency': RegExp(
        r'(جنيه|جنيه مصري|ج\.م|EGP|د\.ع|دينار|SAR|ريال|USD|\$|€|ل\.ل|ليرة)',
        caseSensitive: false),

    // Merchant patterns
    'merchant_arabic': RegExp(r'^([\u0600-\u06FF\s]+)', multiLine: true),
    'merchant_english': RegExp(r'^([A-Za-z\s]+)', multiLine: true),
  };

  /// Parse receipt text using Gemini API with fallback to regex
  /// OPTIMIZED: Only makes 1 API call instead of 3
  static Future<ReceiptData> parseReceiptText(String text, String imagePath,
      {String? sourceApp}) async {
    try {
      // OPTIMIZATION: Skip separate API key and availability checks
      // Go directly to analysis - the analyzeReceiptText method handles all error cases
      print('Attempting Gemini API analysis...');

      final (result, geminiAnalysis) =
          await _geminiService.analyzeReceiptText(text);

      if (result == GeminiResult.success &&
          geminiAnalysis != null &&
          geminiAnalysis.confidence >= 0.5) {
        print(
            'Using Gemini analysis with confidence: ${geminiAnalysis.confidence}');
        return _createReceiptFromGeminiAnalysis(
            geminiAnalysis, text, imagePath, sourceApp);
      } else {
        // Log the specific failure reason and fallback
        switch (result) {
          case GeminiResult.resourceExhausted:
            print(
                'Gemini API resource exhausted (quota exceeded), using regex fallback');
            break;
          case GeminiResult.networkError:
            print('Gemini API network error, using regex fallback');
            break;
          case GeminiResult.invalidResponse:
            print('Gemini API invalid response, using regex fallback');
            break;
          case GeminiResult.apiError:
            print('Gemini API error, using regex fallback');
            break;
          case GeminiResult.success:
            if (geminiAnalysis != null) {
              print(
                  'Gemini analysis low confidence: ${geminiAnalysis.confidence}, using regex fallback');
            } else {
              print('Gemini analysis returned null, using regex fallback');
            }
            break;
        }
      }
    } catch (e) {
      print('Gemini API failed, falling back to regex: $e');
    }

    // Fallback to regex-based parsing
    return _parseReceiptTextWithRegex(text, imagePath, sourceApp: sourceApp);
  }

  /// Parse receipt text using traditional regex patterns (fallback)
  static ReceiptData _parseReceiptTextWithRegex(String text, String imagePath,
      {String? sourceApp}) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Extract amount
    final amount = _extractAmount(text);

    // Extract date
    final date = _extractDate(text);

    // Extract currency
    final currency = _extractCurrency(text);

    // Extract merchant name
    final merchant = _extractMerchant(lines);

    // Generate title with source app information (for display purposes only)
    final title = _generateTitle(merchant, amount, sourceApp);

    // Calculate confidence score
    final confidenceScore = _calculateConfidence(text, amount, date, merchant);

    return ReceiptData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      extractedText: text,
      title: title,
      amount: amount,
      date: date,
      currency: currency,
      merchant: merchant,
      confidenceScore: confidenceScore,
      processedAt: DateTime.now(),
      isProcessed: true,
      sourceApp: null, // Never mark regex fallback as AI processed
    );
  }

  /// Create ReceiptData from Gemini API analysis
  static ReceiptData _createReceiptFromGeminiAnalysis(
    GeminiReceiptAnalysis analysis,
    String originalText,
    String imagePath,
    String? sourceApp,
  ) {
    // Use Gemini's generated title or fallback to generated title (without source app)
    String title = analysis.title ??
        _generateTitle(analysis.merchant, analysis.totalAmount, null);

    return ReceiptData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      extractedText: originalText,
      title: title,
      amount: analysis.totalAmount,
      date: analysis.date != null
          ? DateTime.tryParse(analysis.date!)
          : DateTime.now(),
      currency: analysis.currency,
      merchant: analysis.merchant,
      confidenceScore: analysis.confidence,
      processedAt: DateTime.now(),
      isProcessed: true,
      sourceApp:
          'gemini-ai', // Mark as AI processed - only set when Gemini actually succeeds
    );
  }

  /// Extract amount from text with smart logic
  static double? _extractAmount(String text) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final List<AmountCandidate> candidates = [];

    // 1. High Priority: Look for amounts with currency indicators
    final amountWithCurrency =
        _patterns['amount_with_currency']!.allMatches(text);
    for (final match in amountWithCurrency) {
      if (match.group(1) != null) {
        final amount = _parseAmountWithSeparators(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          candidates.add(AmountCandidate(
            amount: amount,
            context: match.group(0) ?? '',
            priority: 10,
            line: _getLineNumber(lines, match.start),
          ));
        }
      }
    }

    // 2. High Priority: Look for amounts after currency indicators
    final amountAfterCurrency =
        _patterns['amount_after_currency']!.allMatches(text);
    for (final match in amountAfterCurrency) {
      if (match.group(1) != null) {
        final amount = _parseAmountWithSeparators(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          candidates.add(AmountCandidate(
            amount: amount,
            context: match.group(0) ?? '',
            priority: 9,
            line: _getLineNumber(lines, match.start),
          ));
        }
      }
    }

    // 3. High Priority: Total/Sum patterns
    final totalMatches = _patterns['total_patterns']!.allMatches(text);
    for (final match in totalMatches) {
      if (match.group(1) != null) {
        final amount = _parseAmountWithSeparators(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          candidates.add(AmountCandidate(
            amount: amount,
            context: match.group(0) ?? '',
            priority: 8,
            line: _getLineNumber(lines, match.start),
          ));
        }
      }
    }

    // 4. Medium Priority: Subtotal patterns
    final subtotalMatches = _patterns['subtotal_patterns']!.allMatches(text);
    for (final match in subtotalMatches) {
      if (match.group(1) != null) {
        final amount = _parseAmountWithSeparators(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          candidates.add(AmountCandidate(
            amount: amount,
            context: match.group(0) ?? '',
            priority: 5,
            line: _getLineNumber(lines, match.start),
          ));
        }
      }
    }

    // 5. Lower Priority: All numbers (fallback) - with thousands separators
    final numberPattern = RegExp(r'\b(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)\b');
    final numberMatches = numberPattern.allMatches(text);
    for (final match in numberMatches) {
      final amount = _parseAmountWithSeparators(match.group(1) ?? '');
      if (amount != null && amount > 0 && amount >= 1 && amount <= 50000) {
        // Check if this number is near a currency indicator
        final context = _getContextAroundPosition(text, match.start, 20);
        final hasCurrencyNearby = _patterns['currency']!.hasMatch(context);

        candidates.add(AmountCandidate(
          amount: amount,
          context: match.group(0) ?? '',
          priority: hasCurrencyNearby ? 3 : 1,
          line: _getLineNumber(lines, match.start),
        ));
      }
    }

    // Sort candidates by priority (highest first), then by amount (largest first)
    candidates.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return b.amount.compareTo(a.amount);
    });

    // Return the best candidate
    if (candidates.isNotEmpty) {
      print(
          'Amount candidates: ${candidates.map((c) => '${c.amount} (priority: ${c.priority}, context: ${c.context})').join(', ')}');

      // Sort candidates by priority (highest first), then by amount (smallest reasonable amount first)
      candidates.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority); // Higher priority first
        }
        // If same priority, prefer smaller amounts (but not too small)
        return a.amount.compareTo(b.amount);
      });

      // Filter out unreasonably large amounts (likely parsing errors)
      final reasonableCandidates =
          candidates.where((c) => c.amount <= 100000).toList();

      if (reasonableCandidates.isNotEmpty) {
        return reasonableCandidates.first.amount;
      } else {
        // If all amounts are too large, return the smallest one
        return candidates.first.amount;
      }
    }

    return null;
  }

  /// Parse amount string with thousands separators support
  static double? _parseAmountWithSeparators(String amountStr) {
    if (amountStr.isEmpty) return null;

    // Remove common thousands separators (commas, spaces)
    String cleaned = amountStr.replaceAll(RegExp(r'[, ]'), '');

    // Try to parse the cleaned string
    return double.tryParse(cleaned);
  }

  /// Helper class for amount candidates
  static int _getLineNumber(List<String> lines, int position) {
    int currentPos = 0;
    for (int i = 0; i < lines.length; i++) {
      currentPos += lines[i].length + 1; // +1 for newline
      if (currentPos > position) {
        return i;
      }
    }
    return lines.length - 1;
  }

  /// Get context around a position in text
  static String _getContextAroundPosition(
      String text, int position, int radius) {
    final start = math.max(0, position - radius);
    final end = math.min(text.length, position + radius);
    return text.substring(start, end);
  }

  /// Extract date from text
  static DateTime? _extractDate(String text) {
    for (final pattern in _patterns.values) {
      if (pattern.pattern.contains('date')) {
        final match = pattern.firstMatch(text);
        if (match != null && match.group(1) != null) {
          final dateStr = match.group(1) ?? '';
          final date = _parseDate(dateStr);
          if (date != null) {
            return date;
          }
        }
      }
    }

    return null;
  }

  /// Parse date string to DateTime
  static DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(RegExp(r'[/-]'));
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        // Handle 2-digit years
        if (year < 100) {
          year += 2000;
        }

        return DateTime(year, month, day);
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return null;
  }

  /// Extract currency from text
  static String? _extractCurrency(String text) {
    final matches = _patterns['currency']!.allMatches(text);
    String? detectedCurrency;

    for (final match in matches) {
      if (match.group(1) != null) {
        final currency = (match.group(1) ?? '').trim();

        // Map to standard currency codes
        switch (currency.toLowerCase()) {
          case 'جنيه':
          case 'جنيه مصري':
          case 'ج.م':
          case 'egp':
            detectedCurrency = 'ج.م';
            break;
          case 'د.ع':
          case 'دينار':
            detectedCurrency = 'د.ع';
            break;
          case 'sar':
          case 'ريال':
            detectedCurrency = 'SAR';
            break;
          case 'usd':
          case '\$':
            detectedCurrency = 'USD';
            break;
          case '€':
            detectedCurrency = 'EUR';
            break;
          case 'ل.ل':
          case 'ليرة':
            detectedCurrency = 'ل.ل';
            break;
        }

        // If we found a currency, return it immediately
        if (detectedCurrency != null) {
          return detectedCurrency;
        }
      }
    }

    return 'ج.م'; // Default to Egyptian Pound
  }

  /// Extract merchant name from text lines
  static String? _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return null;

    // Look for the first line that looks like a merchant name
    for (final line in lines.take(5)) {
      // Check first 5 lines
      final trimmed = line.trim();

      // Skip lines that are clearly not merchant names
      if (trimmed.length < 3 ||
          trimmed.contains(RegExp(r'\d')) ||
          trimmed.toLowerCase().contains('total') ||
          trimmed.toLowerCase().contains('المجموع') ||
          trimmed.toLowerCase().contains('date') ||
          trimmed.toLowerCase().contains('تاريخ')) {
        continue;
      }

      // Check if line contains Arabic or English text
      if (RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed) ||
          RegExp(r'[A-Za-z]').hasMatch(trimmed)) {
        return trimmed;
      }
    }

    return null;
  }

  /// Generate title from merchant, amount, and source app
  static String _generateTitle(
      String? merchant, double? amount, String? sourceApp) {
    String baseTitle;

    if (merchant != null && merchant.isNotEmpty) {
      baseTitle = merchant;
    } else if (amount != null) {
      baseTitle = 'مصروف ${amount.toStringAsFixed(0)} ج.م';
    } else {
      baseTitle = 'مصروف جديد';
    }

    // Add source app information if available
    if (sourceApp != null && sourceApp.isNotEmpty) {
      // Map common app names to Arabic/English equivalents
      final appName = _mapAppName(sourceApp);
      return '$appName: $baseTitle';
    }

    return baseTitle;
  }

  /// Map common app names to user-friendly display names
  static String _mapAppName(String appName) {
    final appMappings = {
      'com.instagram.android': 'Instagram',
      'com.whatsapp': 'WhatsApp',
      'com.facebook.orca': 'Messenger',
      'com.facebook.katana': 'Facebook',
      'com.twitter.android': 'Twitter',
      'com.snapchat.android': 'Snapchat',
      'com.google.android.apps.photos': 'Google Photos',
      'com.android.gallery3d': 'Gallery',
      'com.samsung.android.gallery': 'Samsung Gallery',
      'com.miui.gallery': 'MI Gallery',
      'com.oneplus.gallery': 'OnePlus Gallery',
      'com.huawei.photos': 'Huawei Gallery',
      'com.sec.android.gallery3d': 'Samsung Gallery',
      'com.android.camera2': 'Camera',
      'com.google.android.apps.camera': 'Google Camera',
      'com.samsung.camera': 'Samsung Camera',
      'com.huawei.camera': 'Huawei Camera',
      'com.xiaomi.camera': 'MI Camera',
      'com.oneplus.camera': 'OnePlus Camera',
      'com.oppo.camera': 'Oppo Camera',
      'com.vivo.camera': 'Vivo Camera',
      'com.realme.camera': 'Realme Camera',
      'com.android.chrome': 'Chrome',
      'com.mozilla.firefox': 'Firefox',
      'com.opera.browser': 'Opera',
      'com.microsoft.emmx': 'Edge',
      'com.samsung.android.app.sbrowser': 'Samsung Browser',
      'com.huawei.browser': 'Huawei Browser',
      'com.mi.global.browser': 'MI Browser',
      'com.oneplus.browser': 'OnePlus Browser',
      'com.oppo.browser': 'Oppo Browser',
      'com.vivo.browser': 'Vivo Browser',
      'com.realme.browser': 'Realme Browser',
      'com.google.android.apps.docs': 'Google Docs',
      'com.google.android.apps.sheets': 'Google Sheets',
      'com.google.android.apps.slides': 'Google Slides',
      'com.microsoft.office.excel': 'Excel',
      'com.microsoft.office.word': 'Word',
      'com.microsoft.office.powerpoint': 'PowerPoint',
      'com.adobe.reader': 'Adobe Reader',
      'com.adobe.acrobat': 'Adobe Acrobat',
      'com.google.android.apps.drive': 'Google Drive',
      'com.dropbox.android': 'Dropbox',
      'com.microsoft.skydrive': 'OneDrive',
      'com.box.android': 'Box',
      'com.google.android.apps.maps': 'Google Maps',
      'com.waze': 'Waze',
      'com.ubercab': 'Uber',
      'com.lyft': 'Lyft',
      'com.taxi.driver': 'Taxi',
      'com.amazon.mShop.android.shopping': 'Amazon',
      'com.ebay.mobile': 'eBay',
      'com.alibaba.aliexpresshd': 'AliExpress',
      'com.shopify.mobile': 'Shopify',
      'com.magento.magento': 'Magento',
      'com.woocommerce.android': 'WooCommerce',
      'com.shopify.pos': 'Shopify POS',
      'com.squareup.pos': 'Square POS',
      'com.clover.pos': 'Clover POS',
      'com.lightspeed.pos': 'Lightspeed POS',
      'com.toast.pos': 'Toast POS',
      'com.revel.pos': 'Revel POS',
      'com.touchbistro.pos': 'TouchBistro POS',
      'com.shopkeep.pos': 'ShopKeep POS',
      'com.vend.pos': 'Vend POS',
      'com.loyverse.pos': 'Loyverse POS',
    };

    // Return mapped name or clean up the package name
    if (appMappings.containsKey(appName)) {
      return appMappings[appName] ?? appName;
    }

    // Clean up package name if no mapping found
    String cleanName = appName;
    if (cleanName.contains('.')) {
      cleanName = cleanName.split('.').last;
    }

    // Capitalize first letter
    if (cleanName.isNotEmpty) {
      cleanName = cleanName[0].toUpperCase() + cleanName.substring(1);
    }

    return cleanName;
  }

  /// Calculate confidence score based on extracted data
  static double _calculateConfidence(
      String text, double? amount, DateTime? date, String? merchant) {
    double confidence = 0.0;

    // Base confidence from text length
    if (text.length > 50) confidence += 0.2;
    if (text.length > 100) confidence += 0.1;

    // Amount confidence
    if (amount != null && amount > 0) {
      confidence += 0.4;

      // Bonus for reasonable amounts
      if (amount >= 1 && amount <= 10000) {
        confidence += 0.1;
      }
    }

    // Date confidence
    if (date != null) {
      confidence += 0.2;

      // Bonus for recent dates
      final now = DateTime.now();
      final daysDiff = now.difference(date).inDays.abs();
      if (daysDiff <= 30) {
        confidence += 0.1;
      }
    }

    // Merchant confidence
    if (merchant != null && merchant.isNotEmpty) {
      confidence += 0.1;
    }

    return math.min(confidence, 1.0);
  }

  /// Validate if text looks like a receipt
  static bool isValidReceipt(String text) {
    print('Validating receipt text: $text');

    if (text.length < 10) {
      print('Text too short: ${text.length}');
      return false;
    }

    // Check for receipt indicators (more comprehensive with Arabic support)
    final receiptIndicators = [
      'receipt',
      'إيصال',
      'فاتورة',
      'bill',
      'invoice',
      'inv',
      'total',
      'المجموع',
      'الإجمالي',
      'المبلغ',
      'الاجمالي',
      'subtotal',
      'المجموع الفرعي',
      'المجموع الجزئي',
      'tax',
      'ضريبة',
      'الضريبة',
      'vat',
      'date',
      'تاريخ',
      'time',
      'وقت',
      'cashier',
      'كاشير',
      'cash',
      'نقدي',
      'store',
      'متجر',
      'shop',
      'محل',
      'مطعم',
      'restaurant',
      'شراء',
      'بيع',
      'transaction',
      'معاملة',
      'سعر',
      'price',
      'كمية',
      'quantity',
      'منتج',
      'product',
      'خدمة',
      'service'
    ];

    final hasReceiptIndicator = receiptIndicators.any(
        (indicator) => text.toLowerCase().contains(indicator.toLowerCase()));
    print('Has receipt indicator: $hasReceiptIndicator');

    // Check for numbers (amounts) - at least one reasonable number
    final numberPattern = RegExp(r'\b(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)\b');
    final numbers = numberPattern
        .allMatches(text)
        .map((match) => _parseAmountWithSeparators(match.group(1) ?? ''))
        .where((num) => num != null && num >= 0.1 && num <= 100000)
        .toList();

    final hasReasonableNumbers = numbers.isNotEmpty;
    print('Has reasonable numbers: $hasReasonableNumbers (found: $numbers)');

    // Check for currency indicators
    final hasCurrency = _patterns['currency']!.hasMatch(text);
    print('Has currency: $hasCurrency');

    // More flexible validation for Arabic text
    // If text contains Arabic characters, be more lenient
    final hasArabicText = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    print('Has Arabic text: $hasArabicText');

    // More flexible validation - if we have reasonable numbers, it's likely a receipt
    if (hasReasonableNumbers) {
      print('Validation passed: Found reasonable numbers');
      return true;
    }

    if (hasArabicText) {
      // For Arabic text, just need receipt indicators
      final result = hasReceiptIndicator;
      print('Arabic validation result: $result');
      return result;
    } else {
      // For non-Arabic text, use original logic
      final conditions = [hasReceiptIndicator, hasCurrency];
      final trueConditions = conditions.where((c) => c).length;
      final result =
          trueConditions >= 1; // More lenient - just need one condition
      print(
          'Non-Arabic validation result: $result (conditions met: $trueConditions/2)');
      return result;
    }
  }

  /// Clean and normalize text
  static String cleanText(String text) {
    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove special characters that might interfere with parsing
    text = text.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF.,:/-]'), '');

    return text;
  }
}
