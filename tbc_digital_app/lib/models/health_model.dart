class HealthModel {
  final List<HealthItem> week;
  final List<HealthItem> month;

  HealthModel({
    required this.week,
    required this.month,
  });

  factory HealthModel.fromJson(Map<String, dynamic> json) {
    return HealthModel(
      week: (json['week'] as List? ?? [])
          .map((e) => HealthItem.fromJson(e))
          .toList(),
      month: (json['month'] as List? ?? [])
          .map((e) => HealthItem.fromJson(e))
          .toList(),
    );
  }
}

class HealthItem {
  final String date;
  final double bmi;
  final double weight;
  final double height;

  HealthItem({
    required this.date,
    required this.bmi,
    required this.weight,
    required this.height,
  });

  factory HealthItem.fromJson(Map<String, dynamic> json) {
    return HealthItem(
      date: json['date'] ?? '',
      bmi: (json['bmi'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
    );
  }

  /// 🔥 TAMBAHKAN INI
  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "bmi": bmi,
      "weight": weight,
      "height": height,
    };
  }
}