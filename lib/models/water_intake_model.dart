class WaterIntake {
  final String id;
  final double amount;
  final DateTime timestamp;

  WaterIntake({
    required this.id,
    required this.amount,
    required this.timestamp,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 