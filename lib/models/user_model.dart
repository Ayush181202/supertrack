class User {
  final String id;
  final String name;
  final int calorieGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final double waterGoal;
  final int stepGoal;

  User({
    required this.id,
    required this.name,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
    required this.stepGoal,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      calorieGoal: json['calorieGoal'] as int,
      proteinGoal: json['proteinGoal'] as int,
      carbsGoal: json['carbsGoal'] as int,
      fatGoal: json['fatGoal'] as int,
      waterGoal: (json['waterGoal'] as num).toDouble(),
      stepGoal: json['stepGoal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'waterGoal': waterGoal,
      'stepGoal': stepGoal,
    };
  }
} 