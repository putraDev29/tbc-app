<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\MedicationLog;
use App\Models\TreatmentProgress;
use App\Models\FcmToken;
use App\Models\Patient;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
// Firebase
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\AndroidConfig;

class MedicationController extends Controller
{
    public function store(Request $request, $patientId)
    {
        $request->validate([
            'status' => 'required|in:PATUH,TERLAMBAT,TIDAK',
            'image'  => 'nullable|image'
        ]);

        // ================= AMBIL PROGRESS =================
        $progress = TreatmentProgress::where('patient_id', $patientId)->first();

        if (!$progress) {
            return response()->json([
                "message" => "Data progress pasien tidak ditemukan"
            ], 404);
        }

        // ================= HITUNG DAY =================
        $day = $progress->current_day + 1;

        // ================= UPLOAD IMAGE =================
        $path = null;

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('bukti', 'public');
        }

        // ================= SAVE LOG =================
        $log = MedicationLog::updateOrCreate(
            [
                'patient_id' => $patientId,
                'date'       => Carbon::today(),
            ],
            [
                'status'          => 'MENUNGGU',
                'taken_at'        => Carbon::now(),
                'proof_image'     => $path,
                'status_validate' => 0,
                'validated'       => false,
                'day'             => $day,
            ]
        );

        // ================= UPDATE PROGRESS =================
        if ($log->wasRecentlyCreated) {
            $progress->update([
                'current_day' => $day
            ]);
        }

        // ================= FIREBASE NOTIFICATION =================
        $this->sendNotificationToPetugas(
            $patientId,
            $request->status
        );

        return response()->json([
            "message" => "Data obat berhasil disimpan",
            "data" => [
                "id"          => $log->id,
                "status"      => $log->status,
                "date"        => Carbon::parse($log->date)->format('Y-m-d'),
                "day"         => $log->day,
                "proof_image" => $log->proof_image
            ]
        ]);
    }

    // ================= FIREBASE DIRECT (NO SERVICE FILE) =================
    public function sendNotificationToPetugas($patientId, $status)
    {
        // ================= AMBIL NAMA PASIEN =================
        $patient = Patient::find($patientId);
        

        $patientName = $patient->name ?? 'Pasien';

        // ================= AMBIL TOKEN PETUGAS =================
        $tokens = FcmToken::whereHas('user', function ($q) {
            $q->where('role', 'petugas');
        })
            ->pluck('token')
            ->filter()
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return;
        }

        $factory = (new Factory)
            ->withServiceAccount(storage_path('firebase/firebase.json'));

        $messaging = $factory->createMessaging();

        // ================= PESAN =================
        $messageText = match ($status) {
            'PATUH'     => "$patientName minum obat tepat waktu hari ini",
            'TERLAMBAT' => "$patientName terlambat minum obat hari ini",
            'TIDAK'     => "$patientName tidak minum obat hari ini",
            default     => "$patientName mengirim bukti minum obat"
        };

        foreach ($tokens as $token) {

            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(Notification::create(
                    "Notifikasi Minum Obat Pasien",
                    $messageText
                ))
                ->withAndroidConfig(
                    AndroidConfig::fromArray([
                        'priority' => 'high',
                        'notification' => [
                            'sound' => 'notif_sound',
                            'channel_id' => 'channel_medicine_v1',
                        ],
                    ])
                )
                ->withData([
                    "type"       => "bukti_obat",
                    "patient_id" => (string) $patientId,
                    "patient_name" => $patientName,
                    "status"     => $status
                ]);

            try {
                $messaging->send($message);
            } catch (\Exception $e) {
                Log::error("FCM Error: " . $e->getMessage());
            }
        }
    }

    public function testNotif($userId, \App\Services\FcmService $fcm)
    {
        $fcm->sendToUser(
            $userId,
            "Test Notifikasi Obat",
            "Ini adalah tes notifikasi pengingat minum obat 💊",
            "obat"
        );

        return response()->json([
            'message' => "Test notif berhasil dikirim ke user ID $userId"
        ]);
    }
}
