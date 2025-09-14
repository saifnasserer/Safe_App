class ReceiptData {
  final String id;
  final String imagePath;
  final String extractedText;
  final String? title;
  final double? amount;
  final DateTime? date;
  final String? currency;
  final String? merchant;
  final double confidenceScore;
  final DateTime processedAt;
  final bool isProcessed;
  final String? errorMessage;
  final String? sourceApp;

  ReceiptData({
    required this.id,
    required this.imagePath,
    required this.extractedText,
    this.title,
    this.amount,
    this.date,
    this.currency,
    this.merchant,
    this.confidenceScore = 0.0,
    required this.processedAt,
    this.isProcessed = false,
    this.errorMessage,
    this.sourceApp,
  });

  // Convert ReceiptData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'extractedText': extractedText,
      'title': title,
      'amount': amount,
      'date': date?.toIso8601String(),
      'currency': currency,
      'merchant': merchant,
      'confidenceScore': confidenceScore,
      'processedAt': processedAt.toIso8601String(),
      'isProcessed': isProcessed,
      'errorMessage': errorMessage,
      'sourceApp': sourceApp,
    };
  }

  // Create ReceiptData from JSON
  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    return ReceiptData(
      id: json['id'],
      imagePath: json['imagePath'],
      extractedText: json['extractedText'],
      title: json['title'],
      amount: json['amount']?.toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      currency: json['currency'],
      merchant: json['merchant'],
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
      processedAt: DateTime.parse(json['processedAt']),
      isProcessed: json['isProcessed'] ?? false,
      errorMessage: json['errorMessage'],
      sourceApp: json['sourceApp'],
    );
  }

  // Create a copy with updated fields
  ReceiptData copyWith({
    String? id,
    String? imagePath,
    String? extractedText,
    String? title,
    double? amount,
    DateTime? date,
    String? currency,
    String? merchant,
    double? confidenceScore,
    DateTime? processedAt,
    bool? isProcessed,
    String? errorMessage,
    String? sourceApp,
  }) {
    return ReceiptData(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      merchant: merchant ?? this.merchant,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      processedAt: processedAt ?? this.processedAt,
      isProcessed: isProcessed ?? this.isProcessed,
      errorMessage: errorMessage ?? this.errorMessage,
      sourceApp: sourceApp ?? this.sourceApp,
    );
  }

  // Check if receipt data is valid for creating a transaction
  bool get isValidForTransaction {
    return amount != null &&
        amount! > 0 &&
        title != null &&
        title!.isNotEmpty &&
        isProcessed;
  }

  // Get formatted amount string
  String get formattedAmount {
    if (amount == null) return '0.00';
    return '${amount!.toStringAsFixed(2)} ${currency ?? 'ج.م'}';
  }

  // Get formatted date string
  String get formattedDate {
    if (date == null) return 'غير محدد';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  @override
  String toString() {
    return 'ReceiptData(id: $id, title: $title, amount: $amount, merchant: $merchant, isProcessed: $isProcessed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReceiptData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
