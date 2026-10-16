<?php

namespace App\Http\Controllers;

use App\Models\MedicationLog;
use App\Models\Patient;
use App\Models\Village;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PetugasController extends Controller
{

    public function dashboardPetugas(Request $request)
    {
        $villageId = $request->village_id;

        // ================= QUERY =================
        $patients = Patient::with([
            'healthRecords:id,patient_id,bmi',
            'logs:id,patient_id,status'
        ])
            ->when($villageId, fn($q) => $q->where('village_id', $villageId))
            ->get();

        // ================= INIT =================
        $patuh = 0;
        $terlambat = 0;
        $tidak = 0;

        $giziBuruk = 0;
        $giziKurang = 0;
        $normal = 0;
        $giziLebih = 0;
        $obesitas = 0;

        $beratBadankurang = 0;
        $beratBadanNormal = 0;
        $beratBadanLebih = 0;
        $obesitas1 = 0;
        $obesitas2 = 0;

        $balita = 0;
        $remaja = 0;
        $dewasa = 0;

        foreach ($patients as $patient) {

            // ================= KEPATUHAN =================
            $latestLog = $patient->logs->sortByDesc('id')->first();

            if ($latestLog) {
                if ($latestLog->status === "PATUH") {
                    $patuh++;
                } elseif ($latestLog->status === "TERLAMBAT") {
                    $terlambat++;
                } else {
                    $tidak++;
                }
            }

            // ================= VALIDASI =================
            if (!$patient->date_born) continue;

            $age = Carbon::parse($patient->date_born)->age;

            // ================= UMUR =================
            if ($age <= 5) {
                $balita++;
            } elseif ($age <= 17) {
                $remaja++;
            } else {
                $dewasa++;
            }

            // ================= BMI =================
            $record = $patient->healthRecords()
                ->orderBy('id', 'desc')
                ->first();

            if (!$record || !$record->bmi) continue;

            $bmi = $record->bmi;

            // =========================
            // 👶 ANAK (5 - <18 TAHUN)
            // =========================
            if ($age >= 5 && $age < 18) {

                $z = $bmi / $age;

                if ($z >= -3 && $z < -2) {
                    $giziKurang++;
                } elseif ($z >= -2 && $z <= 1) {
                    $normal++;
                } elseif ($z > 1 && $z <= 2) {
                    $giziLebih++;
                } elseif ($z > 2) {
                    $obesitas++;
                } else {
                    $giziBuruk++;
                }
            }

            // =========================
            // 👨 DEWASA (≥ 18 TAHUN)
            // =========================
            else {

                if ($bmi < 18.5) {
                    $beratBadankurang++;
                } elseif ($bmi < 23) {
                    $beratBadanNormal++;
                } elseif ($bmi < 25) {
                    $beratBadanLebih++;
                } elseif ($bmi < 30) {
                    $obesitas1++;
                } else {
                    $obesitas2++;
                }
            }
        }

        return response()->json([
            "filter" => [
                "village_id" => $villageId ?? "all"
            ],

            "summary" => [
                "patuh" => $patuh,
                "terlambat" => $terlambat,
                "tidak" => $tidak,
            ],

            "gizi" => [
                "giziBuruk" => $giziBuruk,
                "giziKurang" => $giziKurang,
                "normal" => $normal,
                "giziLebih" => $giziLebih,
                "obesitas" => $obesitas,
                "beratBadankurang" => $beratBadankurang,
                "beratBadanNormal" => $beratBadanNormal,
                "beratBadanLebih" => $beratBadanLebih,
                "obesitas1" => $obesitas1,
                "obesitas2" => $obesitas2,
            ],

            "umur" => [
                "balita" => $balita,
                "remaja" => $remaja,
                "dewasa" => $dewasa,
            ],

            "total_pasien" => $patients->count(),
        ]);
    }

    public function village()
    {
        $villages = Village::select('id', 'name')
            ->whereIn('id', function ($q) {
                $q->selectRaw('MIN(id)')
                    ->from('villages')
                    ->groupBy('name');
            })
            ->orderBy('name', 'asc')
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'List villages',
            'data' => $villages
        ]);
    }

    public function listPasien(Request $request)
    {
        $query = Patient::query();

        // filter desa
        if ($request->village_id) {
            $query->where('village_id', $request->village_id);
        }

        $patients = $query->with([
            'logs',
            'healthRecords',
            'progress',
            'village'
        ])
            ->orderBy('id', 'desc')
            ->paginate($request->limit ?? 5); // 🔥 FIX INI

        return response()->json([
            "data" => collect($patients->items())->map(function ($p) {

                return [
                    "id" => $p->id,
                    "nik" => $p->nik,
                    "nama" => $p->name,
                    "umur" => $this->hitungUmur($p->date_born),
                    "desa" => $p->village?->name,
                    "alamat" => $p->address,
                    "tanggal_lahir" => $p->date_born,
                    "jenis_kelamin" => $p->gender,
                    "tb" => $p->height,
                    "bb" => $p->weight,

                    "mulai" => optional($p->progress?->start_date)?->format('Y-m-d'),
                    "akhir" => optional($p->progress?->end_date)?->format('Y-m-d'),

                    "status_pengobatan" => $p->status ?? "aktif",

                    "history" => $p->logs
                        ->sortByDesc('date')
                        ->map(function ($l) {
                            return [
                                "tanggal" => optional($l->date)?->format('Y-m-d'),
                                "status" => $l->status
                            ];
                        })
                        ->values(),

                    "health" => $p->healthRecords
                        ->sortByDesc('date')
                        ->map(function ($h) {
                            return [
                                "date" => optional($h->date)?->format('Y-m-d'),
                                "bmi" => (float) $h->bmi,
                                "weight" => (float) $h->weight,
                                "height" => (float) $h->height,
                                "status_gizi" => $h->status_gizi,
                            ];
                        })
                        ->values(),

                    "progress" => [
                        "current_day" => $p->progress->current_day ?? 0,
                        "total_days" => $p->progress->total_days ?? 0,
                    ],
                ];
            }),

            // 🔥 WAJIB UNTUK FLUTTER AUTO FETCH
            "meta" => [
                "current_page" => $patients->currentPage(),
                "last_page" => $patients->lastPage(),
                "per_page" => $patients->perPage(),
                "total" => $patients->total(),
            ]
        ]);
    }

    private function hitungUmur($tglLahir)
    {
        if (!$tglLahir) return 0;

        return \Carbon\Carbon::parse($tglLahir)->age;
    }

    public function pending()
    {
        $data = MedicationLog::with('patient')
            ->where('validated', 0) // 🔥 hanya yang belum divalidasi
            ->get();

        return response()->json($data);
    }

    public function approve($id)
    {
        DB::beginTransaction();

        try {
            $log = MedicationLog::findOrFail($id);

            $time = \Carbon\Carbon::parse($log->taken_at);

            $hour = (int) $time->format('H');
            $minute = (int) $time->format('i');

            $status = 'TERLAMBAT';


            if (
                ($hour >= 20 && $hour <= 22) ||
                ($hour == 23 && $minute < 30)
            ) {
                $status = 'PATUH';
            }
            
            if ($hour == 23 && $minute >= 30) {
                $status = 'TERLAMBAT';
            }

            $log->update([
                'status' => $status,
                'validated' => 1,
                'status_validate' => 1,
            ]);

            DB::commit();

            // 🔥 Kirim push notif ke pasien
            try {
                if ($log->patient && $log->patient->user) {
                    $fcm = app(\App\Services\FcmService::class);
                    $dateStr = \Carbon\Carbon::parse($log->date)->format('d M Y');
                    $fcm->sendToUser(
                        $log->patient->user->id,
                        "Bukti Minum Obat Disetujui ✅",
                        "Bukti minum obat Anda ($dateStr) telah divalidasi oleh petugas ($status).",
                        "obat",
                        [
                            "log_id" => (string) $log->id,
                            "status" => $status,
                        ]
                    );
                }
            } catch (\Exception $notifEx) {
                \Illuminate\Support\Facades\Log::error("Gagal kirim notif approve: " . $notifEx->getMessage());
            }

            return response()->json([
                "message" => "Disetujui",
                "status" => $status,
                "data" => $log
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                "message" => "Gagal approve",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    public function reject($id)
    {
        DB::beginTransaction();

        try {
            $log = MedicationLog::findOrFail($id);

            $log->update([
                'status' => 'DITOLAK',
                'validated' => 1,
                'status_validate' => 2, // ❌ reject
            ]);

            DB::commit();

            // 🔥 Kirim push notif ke pasien
            try {
                if ($log->patient && $log->patient->user) {
                    $fcm = app(\App\Services\FcmService::class);
                    $dateStr = \Carbon\Carbon::parse($log->date)->format('d M Y');
                    $fcm->sendToUser(
                        $log->patient->user->id,
                        "Bukti Minum Obat Ditolak ⚠️",
                        "Bukti minum obat Anda ($dateStr) ditolak petugas. Silakan periksa kembali dan unggah ulang.",
                        "obat",
                        [
                            "log_id" => (string) $log->id,
                            "status" => "DITOLAK",
                        ]
                    );
                }
            } catch (\Exception $notifEx) {
                \Illuminate\Support\Facades\Log::error("Gagal kirim notif reject: " . $notifEx->getMessage());
            }

            return response()->json([
                "message" => "Ditolak",
                "data" => $log
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                "message" => "Gagal reject",
                "error" => $e->getMessage()
            ], 500);
        }
    }
}
