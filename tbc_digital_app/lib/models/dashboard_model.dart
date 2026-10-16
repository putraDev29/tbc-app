import 'patient_model.dart';
import 'progress_model.dart';
import 'adherence_model.dart';
import 'point_model.dart';
import 'health_model.dart';

class DashboardModel {
  final PatientModel patient;
  final String todayStatus;
  final ProgressModel progress;
  final AdherenceModel adherence;
  final PointModel points;
  final HealthModel health;

  DashboardModel({
    required this.patient,
    required this.todayStatus,
    required this.progress,
    required this.adherence,
    required this.points,
    required this.health,
  });

  /// ================= FROM JSON =================
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      patient: PatientModel.fromJson(json['patient'] ?? {}),
      todayStatus: json['today_status'] ?? 'BELUM',
      progress: ProgressModel.fromJson(json['progress'] ?? {}),
      adherence: AdherenceModel.fromJson(json['adherence'] ?? {}),
      points: PointModel.fromJson(json['points'] ?? {}),
      health: HealthModel.fromJson(json['health'] ?? {}),
    );
  }

  /// ================= TO JSON (OPTIONAL) =================
  Map<String, dynamic> toJson() {
    return {
      "patient": {
        "id": patient.id,
        "nik": patient.nik,
        "name": patient.name,
        "age": patient.age,
        "date_born": patient.dateBorn,
        "address": patient.address,
        "phone": patient.phone,
        "photo": patient.photo,
      },
      "today_status": todayStatus,
      "progress": {
        "current_day": progress.currentDay,
        "total_days": progress.totalDays,
      },
      "adherence": {
        "patuh": adherence.patuh,
        "terlambat": adherence.terlambat,
        "tidak": adherence.tidak,
      },
      "points": {
        "total_point": points.totalPoint,
        "max_point": points.maxPoint,
        "percent": points.percent,
        "status": points.status,
      },
      "health": {
        "week": health.week.map((e) => e.toJson()).toList(),
        "month": health.month.map((e) => e.toJson()).toList(),
      }
    };
  }
}