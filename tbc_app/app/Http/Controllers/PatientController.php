<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\FcmToken;
use App\Models\HealthRecord;
use App\Models\Patient;
use App\Models\User;
use App\Models\Village;
use App\Services\FcmService;
use Carbon\Carbon;
use FcmService as GlobalFcmService;
use FcmToken as GlobalFcmToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class PatientController extends Controller
{

    public function dashboard($patientId)
    {
        $patient = Patient::with(['progress'])->findOrFail($patientId);

        // ================= TODAY STATUS =================
        $todayLog = $patient->logs()
            ->latest()
            ->first();

        $todayStatus = $todayLog ? $todayLog->status : 'BELUM';

        // ================= ADHERENCE =================
        $patuh = $patient->logs()->where('status', 'PATUH')->count();
        $terlambat = $patient->logs()->where('status', 'TERLAMBAT')->count();
        $tidak = $patient->logs()->where('status', 'TIDAK')->count();

        // ================= POINT SYSTEM =================
        $totalPoint = ($patuh * 10) + ($terlambat * 5);

        $currentDay = $patient->progress->current_day ?? 0;
        $maxPoint =  $patient->progress->total_days * 10;

        $percent = $currentDay > 0 ? $totalPoint / $currentDay : 0;
        if ($currentDay <= 1 && $todayStatus == 'BELUM' || $todayStatus == 'MENUNGGU') {
            $status = ""; // atau "BELUM ADA DATA"
        } else {

            $status = $percent >= 0.8 ? "PATUH" : ($percent >= 0.5 ? "TERLAMBAT" : "TIDAK PATUH");
        }

        // ================= HEALTH DATA =================
        $week = $patient->healthRecords()
            ->latest('date', 'asc')
            ->take(7)
            ->get()
            ->map(function ($h) {
                return [
                    "date" => $h->date->format('Y-m-d'),
                    "bmi" => (float) $h->bmi,
                    "weight" => (float) $h->weight,
                    "height" => (float) $h->height,
                ];
            })->values();

        $month = $patient->healthRecords()
            ->latest('date')
            ->take(30)
            ->get()
            ->map(function ($h) {
                return [
                    "date" => $h->date->format('Y-m-d'),
                    "bmi" => (float) $h->bmi,
                    "weight" => (float) $h->weight,
                    "height" => (float) $h->height,
                ];
            })->values();

        // ================= RESPONSE =================
        return response()->json([
            "patient" => [
                "id" => $patient->id,
                "nik" => $patient->nik,
                "name" => $patient->name,
                "age" => $patient->age,
                "date_born" => $patient->date_born?->format('Y-m-d'),
                "address" => $patient->address,
                "phone" => $patient->phone,
                "photo" => $patient->photo_url
            ],

            "today_status" => $todayStatus,

            "progress" => [
                "current_day" => $currentDay,
                "total_days" => $patient->progress->total_days ?? 168,
                "start_date" => optional($patient->progress)->start_date?->format('Y-m-d'),
                "end_date"   => optional($patient->progress)->end_date?->format('Y-m-d'),
            ],

            "adherence" => [
                "patuh" => $patuh,
                "terlambat" => $terlambat,
                "tidak" => $tidak,
            ],

            "points" => [
                "total_point" => $totalPoint,
                "max_point" => $maxPoint,
                "percent" => round($percent, 2),
                "status" => $status
            ],

            "health" => [
                "week" => $week,
                "month" => $month
            ]
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nik' => 'required',
            'name' => 'required',
            'date_born' => 'required|date',
            'village' => 'required|string',

            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric',

            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
        ]);

        DB::beginTransaction();

        try {

            // =========================
            // 1. VILLAGE
            // =========================
            $nameVillage = strtolower(trim($request->village));

            $village = Village::where('name', $nameVillage)->first();

            if (!$village) {
                $village = Village::create([
                    'name' => $nameVillage
                ]);
            }

            /// 🔥 AMBIL ID
            $villageId = $village->id;
            // =========================
            // 2. PATIENT
            // =========================
            $patient = Patient::create([
                'nik' => $request->nik,
                'name' => $request->name,
                'date_born' => $request->date_born,
                'village_id' => $villageId,
                'address' => trim($request->address),
                'phone' => '09789868',
                'photo_url' => '',
                'status' => $request->status ?? 'aktif',
            ]);

            // =========================
            // 3. USER (AUTO CREATE)
            // =========================
            User::create([
                'username' => $request->nik,
                'password' => Hash::make('123456'),
                'role' => 'pasien',
                'ref_id' => $patient->id,
            ]);

            // =========================
            // 4. HEALTH RECORD + BMI
            // =========================
            if ($request->height && $request->weight) {

                $heightM = $request->height / 100;
                $bmi = $request->weight / ($heightM * $heightM);

                // 🔥 hitung umur
                $age = Carbon::parse($request->date_born)->age;

                $statusGiziAuto = null;

                // =========================
                // 👶 USIA 5–18 TAHUN
                // =========================
                if ($age >= 5 && $age < 18) {

                    $z = $bmi / $age;

                    if ($z >= -3 && $z < -2) {
                        $statusGiziAuto = "Gizi Kurang";
                    } elseif ($z >= -2 && $z <= 1) {
                        $statusGiziAuto = "Normal";
                    } elseif ($z > 1 && $z <= 2) {
                        $statusGiziAuto = "Gizi Lebih";
                    } elseif ($z > 2) {
                        $statusGiziAuto = "Obesitas";
                    } else {
                        $statusGiziAuto = "Gizi Buruk";
                    }


                    HealthRecord::create([
                        'patient_id' => $patient->id,
                        'date' => now(),
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => round($z, 2),
                        'status_gizi' => $statusGiziAuto,
                    ]);


                    // =========================
                    // 👨 DEWASA (≥ 18 TAHUN)
                    // SESUAI GAMBAR (WHO ASIA)
                    // =========================
                } elseif ($age >= 18) {

                    if ($bmi < 18.5) {
                        $statusGiziAuto = "Berat badan kurang";
                    } elseif ($bmi < 23) {
                        $statusGiziAuto = "Normal";
                    } elseif ($bmi < 25) {
                        $statusGiziAuto = "Overweight";
                    } elseif ($bmi < 30) {
                        $statusGiziAuto = "Obesitas I";
                    } else {
                        $statusGiziAuto = "Obesitas II";
                    }

                    HealthRecord::create([
                        'patient_id' => $patient->id,
                        'date' => now(),
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => round($bmi, 2),
                        'status_gizi' => $statusGiziAuto,
                    ]);
                } else {
                    HealthRecord::create([
                        'patient_id' => $patient->id,
                        'date' => now(),
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => $request->bmi,
                        'status_gizi' => $request->status_gizi,
                    ]);
                }
            }

            // =========================
            // 5. TREATMENT PROGRESS
            // =========================
            if ($request->start_date && $request->end_date) {

                $start = Carbon::parse($request->start_date);
                $end = Carbon::parse($request->end_date);

                $patient->progress()->create([
                    'start_date' => $start,
                    'end_date' => $end,
                    'current_day' => 0,
                    'total_days' => $start->diffInDays($end),
                ]);
            }

            DB::commit();

            return response()->json([
                "message" => "Pasien berhasil ditambahkan",
                "data" => $patient->load(['healthRecords', 'progress', 'village'])
            ], 201);
        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                "message" => "Gagal menyimpan pasien",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    public function registerPatient(Request $request)
    {
        $request->validate([
            'nik' => 'required',
            'name' => 'required',
            'date_born' => 'required|date',
            'village' => 'required|string',

            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric',

            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
        ]);

        DB::beginTransaction();

        try {

            // =========================
            // 1. VILLAGE
            // =========================
            $nameVillage = strtolower(trim($request->village));

            $village = Village::where('name', $nameVillage)->first();

            if (!$village) {
                $village = Village::create([
                    'name' => $nameVillage
                ]);
            }

            /// 🔥 AMBIL ID
            $villageId = $village->id;
            // =========================
            // 2. PATIENT
            // =========================
            $patient = Patient::create([
                'nik' => $request->nik,
                'name' => $request->name,
                'date_born' => $request->date_born,
                'village_id' => $villageId,
                'address' => trim($request->address),
                'phone' => $request->phone,
                'photo_url' => '',
                'status' => $request->status ?? 'aktif',
            ]);

            // =========================
            // 3. USER (AUTO CREATE)
            // =========================
            User::create([
                'username' => $request->nik,
                'password' => Hash::make($request->password),
                'role' => 'pasien',
                'ref_id' => $patient->id,
            ]);

            // =========================
            // 4. HEALTH RECORD + BMI
            // =========================
            if ($request->height && $request->weight) {

                $heightM = $request->height / 100;
                $bmi = $request->weight / ($heightM * $heightM);

                // 🔥 hitung umur
                $age = Carbon::parse($request->date_born)->age;

                $statusGiziAuto = null;

                // =========================
                // 👶 USIA 5–18 TAHUN
                // =========================
                if ($age >= 5 && $age < 18) {

                    $z = $bmi / $age;

                    if ($z >= -3 && $z < -2) {
                        $statusGiziAuto = "Gizi Kurang";
                    } elseif ($z >= -2 && $z <= 1) {
                        $statusGiziAuto = "Normal";
                    } elseif ($z > 1 && $z <= 2) {
                        $statusGiziAuto = "Gizi Lebih";
                    } elseif ($z > 2) {
                        $statusGiziAuto = "Obesitas";
                    } else {
                        $statusGiziAuto = "Gizi Buruk";
                    }


                    HealthRecord::create([
                        'patient_id' => $patient->id,
                        'date' => now(),
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => round($z, 2),
                        'status_gizi' => $statusGiziAuto,
                    ]);


                    // =========================
                    // 👨 DEWASA (≥ 18 TAHUN)
                    // SESUAI GAMBAR (WHO ASIA)
                    // =========================
                } elseif ($age >= 18) {

                    if ($bmi < 18.5) {
                        $statusGiziAuto = "Berat badan kurang";
                    } elseif ($bmi < 23) {
                        $statusGiziAuto = "Normal";
                    } elseif ($bmi < 25) {
                        $statusGiziAuto = "Overweight";
                    } elseif ($bmi < 30) {
                        $statusGiziAuto = "Obesitas I";
                    } else {
                        $statusGiziAuto = "Obesitas II";
                    }

                    HealthRecord::create([
                        'patient_id' => $patient->id,
                        'date' => now(),
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => round($bmi, 2),
                        'status_gizi' => $statusGiziAuto,
                    ]);
                } else {
                    HealthRecord::create([
                        'patient_id' => $patient->id,
                        'date' => now(),
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => $request->bmi,
                        'status_gizi' => $request->status_gizi,
                    ]);
                }
            }

            // =========================
            // 5. TREATMENT PROGRESS
            // =========================
            if ($request->start_date && $request->end_date) {

                $start = Carbon::parse($request->start_date);
                $end = Carbon::parse($request->end_date);

                $patient->progress()->create([
                    'start_date' => $start,
                    'end_date' => $end,
                    'current_day' => 0,
                    'total_days' => $start->diffInDays($end),
                ]);
            }

            DB::commit();

            return response()->json([
                "message" => "Pasien berhasil ditambahkan",
                "data" => $patient->load(['healthRecords', 'progress', 'village'])
            ], 201);
        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                "message" => "Gagal menyimpan pasien",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    function getBMIZScoreReference($age)
    {
        // 🔥 contoh referensi (simplified)
        // real-nya bisa dari WHO
        $data = [
            5 => ['median' => 15.5, 'sd' => 1.2],
            6 => ['median' => 15.8, 'sd' => 1.3],
            7 => ['median' => 16.0, 'sd' => 1.4],
            8 => ['median' => 16.5, 'sd' => 1.5],
            9 => ['median' => 17.0, 'sd' => 1.6],
            10 => ['median' => 17.5, 'sd' => 1.7],
            11 => ['median' => 18.0, 'sd' => 1.8],
            12 => ['median' => 18.5, 'sd' => 1.9],
            13 => ['median' => 19.0, 'sd' => 2.0],
            14 => ['median' => 19.5, 'sd' => 2.1],
            15 => ['median' => 20.0, 'sd' => 2.2],
            16 => ['median' => 20.5, 'sd' => 2.3],
            17 => ['median' => 21.0, 'sd' => 2.4],
            18 => ['median' => 21.5, 'sd' => 2.5],
        ];

        return $data[$age] ?? null;
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nik' => 'required',
            'name' => 'required',
            'date_born' => 'required|date',

            'village' => 'required|string',

            'height' => 'nullable|numeric',
            'weight' => 'nullable|numeric',
            'status_gizi' => 'nullable|string',

            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
        ]);

        DB::beginTransaction();

        try {

            $patient = Patient::findOrFail($id);

            // =========================
            // 1. VILLAGE
            // =========================
            $village = Village::firstOrCreate([
                'name' => trim($request->village)
            ]);

            // =========================
            // 2. UPDATE PATIENT
            // =========================
            $patient->update([
                'nik' => $request->nik,
                'name' => $request->name,
                'date_born' => $request->date_born,
                'village_id' => $village->id,
                'status' => $request->status ?? 'aktif',
            ]);

            // =========================
            // 3. HEALTH RECORD (CREATE BARU)
            // =========================
            if ($request->height && $request->weight) {

                $heightM = $request->height / 100;
                $bmi = $request->weight / ($heightM * $heightM);

                // 🔥 hitung umur
                $age = Carbon::parse($request->date_born)->age;

                $statusGiziAuto = null;

                // =========================
                // 👶 USIA 5–18 TAHUN
                // =========================
                if ($age >= 5 && $age <= 18) {


                    $z = $bmi / $age;

                    if ($z >= -3 && $z < -2) {
                        $statusGiziAuto = "Gizi Kurang";
                    } elseif ($z >= -2 && $z <= 1) {
                        $statusGiziAuto = "Normal";
                    } elseif ($z > 1 && $z <= 2) {
                        $statusGiziAuto = "Gizi Lebih";
                    } elseif ($z > 2) {
                        $statusGiziAuto = "Obesitas";
                    } else {
                        $statusGiziAuto = "Gizi Buruk"; // optional (< -3)
                    }

                    HealthRecord::updateOrCreate(
                        [
                            'patient_id' => $patient->id,
                            'date' => now()->toDateString(), // 🔥 kunci unik per hari
                        ],
                        [
                            'height' => $request->height,
                            'weight' => $request->weight,
                            'bmi' => round($bmi, 2),
                            'status_gizi' => $age < 5
                                ? $request->status_gizi
                                : $z,
                        ]
                    );
                }


                // =========================
                // 👨 DEWASA (≥ 18 TAHUN)
                // SESUAI GAMBAR (WHO ASIA)
                // =========================
                else {

                    if ($bmi < 18.5) {
                        $statusGiziAuto = "Berat badan kurang";
                    } elseif ($bmi < 23) {
                        $statusGiziAuto = "Normal";
                    } elseif ($bmi < 25) {
                        $statusGiziAuto = "Overweight";
                    } elseif ($bmi < 30) {
                        $statusGiziAuto = "Obesitas I";
                    } else {
                        $statusGiziAuto = "Obesitas II";
                    }
                }

                // 🔥 CREATE BARU (BUKAN UPDATE)
                HealthRecord::updateOrCreate(
                    [
                        'patient_id' => $patient->id,
                        'date' => now()->toDateString(), // 🔥 kunci unik per hari
                    ],
                    [
                        'height' => $request->height,
                        'weight' => $request->weight,
                        'bmi' => round($bmi, 2),
                        'status_gizi' => $age < 5
                            ? $request->status_gizi
                            : $statusGiziAuto,
                    ]
                );
            }

            // =========================
            // 4. UPDATE / CREATE PROGRESS
            // =========================
            if ($request->start_date && $request->end_date) {

                $start = Carbon::parse($request->start_date);
                $end = Carbon::parse($request->end_date);

                $progress = $patient->progress()->first();

                if ($progress) {
                    // update
                    $progress->update([
                        'start_date' => $start,
                        'end_date' => $end,
                        'total_days' => $start->diffInDays($end),
                    ]);
                } else {
                    // create baru
                    $patient->progress()->create([
                        'start_date' => $start,
                        'end_date' => $end,
                        'current_day' => 0,
                        'total_days' => $start->diffInDays($end),
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                "message" => "Pasien berhasil diupdate",
                "data" => $patient->load(['healthRecords', 'progress', 'village'])
            ], 200);
        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                "message" => "Gagal update pasien",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    public function saveToken(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'fcm_token' => 'required|string',
            'device' => 'nullable|string',
        ]);

        FcmToken::updateOrCreate(
            [
                'token' => $request->fcm_token,
            ],
            [
                'user_id' => $request->user_id,
                'device' => '',
                'device'  => $request->device ?? 'android',
            ]
        );

        return response()->json([
            'message' => 'Token saved successfully'
        ]);
    }

    public function testNotif(Request $request)
    {
        $userId = $request->query('user_id');
        if (!$userId) {
            $firstToken = FcmToken::latest()->first();
            $userId = $firstToken ? $firstToken->user_id : 1;
        }

        $fcm = app(\App\Services\FcmService::class);
        $fcm->sendToUser(
            $userId,
            "Test Notifikasi FCM",
            "Ini adalah tes notifikasi FCM dari PatientController 🔔",
            "obat"
        );

        return response()->json([
            'message' => "Test notifikasi FCM berhasil dikirim ke user ID $userId"
        ]);
    }

    public function getPatientsByStatus($status)
    {
        $patients = DB::table('medication_logs')
            ->join(
                'patients',
                'patients.id',
                '=',
                'medication_logs.patient_id'
            )
            ->select(
                'patients.id',
                'patients.name',
                'patients.phone',
                'patients.address',
                'patients.village_id',
                'medication_logs.status',
                'medication_logs.date',
            )
            ->where(
                'medication_logs.status',
                strtoupper($status)
            )
            ->orderByDesc('medication_logs.date')
            ->get();

        return response()->json($patients);
    }
}
