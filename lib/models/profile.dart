class Profile {
  final String id;
  final String name;
  final int primaryColor;
  double walletBalance;
  double spentAmount;
  final bool isDefault;
  final DateTime created;

  Profile({
    required this.id,
    required this.name,
    required this.primaryColor,
    this.walletBalance = 0.0,
    this.spentAmount = 0.0,
    this.isDefault = false,
    DateTime? created,
  }) : created = created ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColor': primaryColor,
      'walletBalance': walletBalance,
      'spentAmount': spentAmount,
      'isDefault': isDefault,
      'created': created.toIso8601String(),
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      primaryColor: json['primaryColor'],
      walletBalance: json['walletBalance'],
      spentAmount: json['spentAmount'],
      isDefault: json['isDefault'],
      created: DateTime.parse(json['created']),
    );
  }

  Profile copyWith({
    String? id,
    String? name,
    int? primaryColor,
    double? walletBalance,
    double? spentAmount,
    bool? isDefault,
    DateTime? created,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      walletBalance: walletBalance ?? this.walletBalance,
      spentAmount: spentAmount ?? this.spentAmount,
      isDefault: isDefault ?? this.isDefault,
      created: created ?? this.created,
    );
  }
}
