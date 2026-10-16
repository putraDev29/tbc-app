class PatientModel {
  final int id;
  final String nik;
  final String name;
  final int age;
  final String dateBorn;
  final String address;
  final String phone;
  final String photo;

  PatientModel({
    required this.id,
    required this.nik,
    required this.name,
    required this.age,
    required this.dateBorn,
    required this.address,
    required this.phone,
    required this.photo,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? 0,
      nik: json['nik'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      dateBorn: json['date_born'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}