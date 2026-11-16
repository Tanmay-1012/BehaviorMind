class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final String dateOfBirth;
  final String bloodType;
  final int weight; // in kg
  final int height; // in cm
  final String profileImage;
  final Map<String, dynamic> healthGoals;
  final List<String> connectedDevices;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.dateOfBirth,
    required this.bloodType,
    required this.weight,
    required this.height,
    required this.profileImage,
    required this.healthGoals,
    required this.connectedDevices,
  });

  // Create a copy of this User with the given field values updated
  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? dateOfBirth,
    String? bloodType,
    int? weight,
    int? height,
    String? profileImage,
    Map<String, dynamic>? healthGoals,
    List<String>? connectedDevices,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      profileImage: profileImage ?? this.profileImage,
      healthGoals: healthGoals ?? this.healthGoals,
      connectedDevices: connectedDevices ?? this.connectedDevices,
    );
  }

  // Convert User instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'bloodType': bloodType,
      'weight': weight,
      'height': height,
      'profileImage': profileImage,
      'healthGoals': healthGoals,
      'connectedDevices': connectedDevices,
    };
  }

  // Create a User instance from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      dateOfBirth: map['dateOfBirth'] ?? '',
      bloodType: map['bloodType'] ?? '',
      weight: map['weight'] ?? 0,
      height: map['height'] ?? 0,
      profileImage: map['profileImage'] ?? '',
      healthGoals: Map<String, dynamic>.from(map['healthGoals'] ?? {}),
      connectedDevices: List<String>.from(map['connectedDevices'] ?? []),
    );
  }

  // Create a demo user for testing
  factory User.demo() {
    return User(
      id: 'demo-user-1',
      name: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      age: 32,
      dateOfBirth: 'June 15, 1991',
      bloodType: 'O+',
      weight: 75,
      height: 178,
      profileImage: 'assets/images/profile_default.png',
      healthGoals: {
        'steps': 10000,
        'sleep': 8,
        'water': 8,
        'meditation': 15,
        'calories': 2000,
      },
      connectedDevices: ['Fitbit Sense', 'Samsung Galaxy Watch'],
    );
  }
}