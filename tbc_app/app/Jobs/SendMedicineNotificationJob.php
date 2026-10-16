<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\FcmService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendMedicineNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $user;

    public function __construct(User $user)
    {
        $this->user = $user;
    }

    public function handle(FcmService $fcm)
    {
        if (!$this->user || !$this->user->pasien) {
            return;
        }

        $today = now()->setTimezone('Asia/Jakarta')->toDateString();

        $hasLog = $this->user->pasien
            ->logs()
            ->whereDate('date', $today)
            ->exists();

        if ($hasLog) {
            return;
        }

        try {
            $fcm->sendToUser(
                $this->user->id,
                "Pengingat Minum Obat",
                "Waktunya minum obat hari ini! 💊",
                "obat"
            );
        } catch (\Exception $e) {
            \Log::error('FCM Reminder Job Error: ' . $e->getMessage());
        }
    }
}
