class DashboardManajemenData {
  final int year;
  final int month;
  final String desa;
  final int kasusAktif;
  final int sembuh;
  final int dropOut;

  DashboardManajemenData({
    required this.year,
    required this.month,
    required this.desa,
    required this.kasusAktif,
    required this.sembuh,
    required this.dropOut,
  });

  factory DashboardManajemenData.fromJson(Map<String, dynamic> json) {
    return DashboardManajemenData(
      year: int.tryParse(json['year'].toString()) ?? 0,
      month: int.tryParse(json['month'].toString()) ?? 0,
      desa: json['desa'] ?? "-",
      kasusAktif: int.tryParse(json['kasus_aktif'].toString()) ?? 0,
      sembuh: int.tryParse(json['sembuh'].toString()) ?? 0,
      dropOut: int.tryParse(json['drop_out'].toString()) ?? 0,
    );
  }
}