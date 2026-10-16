class AdherenceModel {
  final int patuh;
  final int terlambat;
  final int tidak;

  AdherenceModel({
    required this.patuh,
    required this.terlambat,
    required this.tidak,
  });

  factory AdherenceModel.fromJson(Map<String, dynamic> json) {
    return AdherenceModel(
      patuh: json['patuh'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      tidak: json['tidak'] ?? 0,
    );
  }
}