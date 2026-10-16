class PointModel {
  final int totalPoint;
  final int maxPoint;
  final double percent;
  final String status;

  PointModel({
    required this.totalPoint,
    required this.maxPoint,
    required this.percent,
    required this.status,
  });

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
      totalPoint: json['total_point'] ?? 0,
      maxPoint: json['max_point'] ?? 0,
      percent: (json['percent'] ?? 0).toDouble(),
      status: json['status'] ?? 'TIDAK',
    );
  }
}