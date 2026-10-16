class ProgressModel {
  final int currentDay;
  final int totalDays;
  final String startDate; // 🔥 TAMBAH
  final String endDate;   // 🔥 TAMBAH

  ProgressModel({
    required this.currentDay,
    required this.totalDays,
    required this.startDate,
    required this.endDate,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      currentDay: json['current_day'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      startDate: json['start_date'] ?? '', // 🔥 dari API
      endDate: json['end_date'] ?? '',     // 🔥 dari API
    );
  }
}