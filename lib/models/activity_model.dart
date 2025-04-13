class Activity {
  final String id;
  final String name;
  final int steps;
  final int caloriesBurned;
  final int durationMinutes;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.name,
    required this.steps,
    required this.caloriesBurned,
    required this.durationMinutes,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      steps: json['steps'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      durationMinutes: json['durationMinutes'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'steps': steps,
      'caloriesBurned': caloriesBurned,
      'durationMinutes': durationMinutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 