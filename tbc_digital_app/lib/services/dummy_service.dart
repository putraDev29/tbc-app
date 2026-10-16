// services/dummy_service.dart
class DummyService {
  static Map patient = {
    "nama": "Budi Santoso",
    "umur": 32,
    "alamat": "Surabaya",
    "status": "Aktif",
    "kepatuhan": 85,
    "tb": 165,
    "bb": 55,
  };

  // dummy_service.dart
  static List<double> weeklyAdherence = [80, 90, 70, 85, 95, 88, 92];

  static List edukasi = [
    {"title": "Minum obat tepat waktu", "image": "assets/images/img1.jpeg"},
    {"title": "Makanan sehat untuk TBC", "image": "assets/images/img2.jpeg"},
    {"title": "Hindari rokok", "image": "assets/images/img3.jpeg"},
  ];

  static List jadwal = [
    {
      "minggu": "Minggu 1",
      "tanggal": "01 Jan 2026",
      "keterangan": "Kontrol awal",
    },
    {
      "minggu": "Minggu 1",
      "tanggal": "03 Jan 2026",
      "keterangan": "Evaluasi obat",
    },
    {
      "minggu": "Minggu 2",
      "tanggal": "08 Jan 2026",
      "keterangan": "Cek lanjutan",
    },
    {"minggu": "Minggu 2", "tanggal": "10 Jan 2026", "keterangan": "Follow up"},
  ];
}
