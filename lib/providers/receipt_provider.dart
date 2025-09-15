import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/services/ocr_service.dart';
import 'package:safe/services/receipt_parser.dart';

class ReceiptProvider extends ChangeNotifier {
  List<ReceiptData> _receipts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Callback for when a receipt is added (for navigation)
  Function(ReceiptData)? _onReceiptAdded;

  List<ReceiptData> get receipts => List.unmodifiable(_receipts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Set callback for when receipts are added (for navigation)
  void setReceiptAddedCallback(Function(ReceiptData) callback) {
    _onReceiptAdded = callback;
  }

  /// Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadReceipts();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize receipt provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize for share intent flow (lightweight)
  Future<void> initializeForShareIntent() async {
    _setLoading(true);
    try {
      await _loadReceipts();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize receipt provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load receipts from storage
  Future<void> _loadReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final receiptsJson = prefs.getStringList('receipts') ?? [];

      _receipts = receiptsJson
          .map((json) => ReceiptData.fromJson(jsonDecode(json)))
          .toList();

      // Sort by processed date (newest first)
      _receipts.sort((a, b) => b.processedAt.compareTo(a.processedAt));

      notifyListeners();
    } catch (e) {
      _setError('Failed to load receipts: $e');
    }
  }

  /// Save receipts to storage
  Future<void> _saveReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final receiptsJson =
          _receipts.map((receipt) => jsonEncode(receipt.toJson())).toList();

      await prefs.setStringList('receipts', receiptsJson);
    } catch (e) {
      _setError('Failed to save receipts: $e');
    }
  }

  /// Add a new receipt
  Future<void> addReceipt(ReceiptData receipt) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if receipt already exists
      final existingIndex = _receipts.indexWhere((r) => r.id == receipt.id);
      if (existingIndex != -1) {
        _receipts[existingIndex] = receipt;
      } else {
        _receipts.insert(0, receipt); // Add to beginning
      }

      await _saveReceipts();
      notifyListeners();

      // Notify callback if set (for navigation)
      if (_onReceiptAdded != null) {
        _onReceiptAdded!(receipt);
      }
    } catch (e) {
      _setError('Failed to add receipt: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing receipt
  Future<void> updateReceipt(ReceiptData receipt) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _receipts.indexWhere((r) => r.id == receipt.id);
      if (index != -1) {
        _receipts[index] = receipt;
        await _saveReceipts();
        notifyListeners();
      } else {
        _setError('Receipt not found');
      }
    } catch (e) {
      _setError('Failed to update receipt: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove a receipt
  Future<void> removeReceipt(String receiptId) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _receipts.indexWhere((r) => r.id == receiptId);
      if (index != -1) {
        final receipt = _receipts[index];

        // Delete the image file
        await _deleteReceiptImage(receipt.imagePath);

        _receipts.removeAt(index);
        await _saveReceipts();
        notifyListeners();
      } else {
        _setError('Receipt not found');
      }
    } catch (e) {
      _setError('Failed to remove receipt: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Process image from share intent or picker
  Future<ReceiptData?> processImage(String imagePath,
      {String? sourceApp}) async {
    try {
      _setLoading(true);
      _clearError();

      print('🔍 [Receipt Provider] Processing image: $imagePath');

      // Import the necessary services
      final ocrService = OCRService();

      // Extract text using OCR
      final extractedText = await ocrService.extractTextFromImage(imagePath);

      if (extractedText.isEmpty) {
        print('❌ [Receipt Provider] No text extracted from image');
        _setError('لم يتم استخراج نص من الصورة');
        return null;
      }

      print('📝 [Receipt Provider] Extracted text: $extractedText');

      // Parse the receipt text using static method
      final receiptData = await ReceiptParser.parseReceiptText(
        extractedText,
        imagePath,
        sourceApp: sourceApp,
      );

      print('✅ [Receipt Provider] Successfully processed receipt');
      await addReceipt(receiptData);
      return receiptData;
    } catch (e) {
      print('❌ [Receipt Provider] Error processing image: $e');
      _setError('فشل في معالجة الصورة: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get receipt by ID
  ReceiptData? getReceiptById(String id) {
    try {
      return _receipts.firstWhere((receipt) => receipt.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get receipts by date range
  List<ReceiptData> getReceiptsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _receipts.where((receipt) {
      if (receipt.date == null) return false;
      return receipt.date!.isAfter(startDate) &&
          receipt.date!.isBefore(endDate);
    }).toList();
  }

  /// Get receipts with valid transaction data
  List<ReceiptData> getValidReceipts() {
    return _receipts.where((receipt) => receipt.isValidForTransaction).toList();
  }

  /// Get receipts that need processing
  List<ReceiptData> getUnprocessedReceipts() {
    return _receipts.where((receipt) => !receipt.isProcessed).toList();
  }

  /// Get total amount from all receipts
  double getTotalAmount() {
    return _receipts
        .where((receipt) => receipt.amount != null)
        .fold(0.0, (sum, receipt) => sum + receipt.amount!);
  }

  /// Get receipt statistics
  Map<String, dynamic> getReceiptStats() {
    final totalReceipts = _receipts.length;
    final processedReceipts = _receipts.where((r) => r.isProcessed).length;
    final validReceipts =
        _receipts.where((r) => r.isValidForTransaction).length;
    final totalAmount = getTotalAmount();
    final averageConfidence = _receipts.isNotEmpty
        ? _receipts.fold(0.0, (sum, r) => sum + r.confidenceScore) /
            _receipts.length
        : 0.0;

    return {
      'totalReceipts': totalReceipts,
      'processedReceipts': processedReceipts,
      'validReceipts': validReceipts,
      'totalAmount': totalAmount,
      'averageConfidence': averageConfidence,
    };
  }

  /// Clear all receipts
  Future<void> clearAllReceipts() async {
    try {
      _setLoading(true);
      _clearError();

      // Delete all image files
      for (final receipt in _receipts) {
        await _deleteReceiptImage(receipt.imagePath);
      }

      _receipts.clear();
      await _saveReceipts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear receipts: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Retry processing a receipt
  Future<void> retryProcessing(String receiptId) async {
    try {
      _setLoading(true);
      _clearError();

      final receipt = getReceiptById(receiptId);
      if (receipt != null) {
        // Retry processing is now handled by ShareIntentHandler
        // For now, just clear the error message
        final updatedReceipt = receipt.copyWith(
          errorMessage: null,
          isProcessed: true,
        );
        await updateReceipt(updatedReceipt);
      }
    } catch (e) {
      _setError('Failed to retry processing: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Delete receipt image file
  Future<bool> _deleteReceiptImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting receipt image: $e');
      return false;
    }
  }
}
