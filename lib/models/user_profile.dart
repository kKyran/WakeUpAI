class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.level,
  });

  final String id;
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final int level; // 1-ден 5-ке дейін (қаншалықты дайындығы бар)

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender,
        'level': level,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        age: json['age'] as int,
        height: (json['height'] as num).toDouble(),
        weight: (json['weight'] as num).toDouble(),
        gender: json['gender'] as String,
        level: json['level'] as int,
      );
}
