class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.level,
    this.photoPath,
    this.phoneNumber,
    this.countryCode,
  });

  final String id;
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final int level;
  final String? photoPath;
  final String? phoneNumber;
  final String? countryCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender,
        'level': level,
        'photoPath': photoPath,
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        age: json['age'] as int,
        height: (json['height'] as num).toDouble(),
        weight: (json['weight'] as num).toDouble(),
        gender: json['gender'] as String,
        level: json['level'] as int,
        photoPath: json['photoPath'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        countryCode: json['countryCode'] as String?,
      );
}
