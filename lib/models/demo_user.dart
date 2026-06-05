class DemoUser {
  final String id;
  final String name;
  final String role; // 'patient' or 'doctor'

  DemoUser({required this.id, required this.name, required this.role});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role};
  }

  factory DemoUser.fromMap(Map<String, dynamic> map) {
    return DemoUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
    );
  }

  static DemoUser patient() =>
      DemoUser(id: 'patient_001', name: 'Nguyễn Thị Lan', role: 'patient');

  static DemoUser doctor() =>
      DemoUser(id: 'doctor_001', name: 'BS. Nguyễn Minh Anh', role: 'doctor');
}
