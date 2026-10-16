<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Patient;
use App\Jobs\SendMedicineNotificationJob;

class SendMedicineReminder extends Command
{
    protected $signature = 'medicine:reminder';
    protected $description = 'Kirim notif ke pasien yang belum ada log hari ini';

    public function handle()
    {
        $today = now()->setTimezone('Asia/Jakarta')->toDateString();

        Patient::whereDoesntHave('logs', function ($q) use ($today) {
                $q->whereDate('date', $today);
            })
            ->with('user')
            ->chunk(100, function ($patients) {

                foreach ($patients as $patient) {

                    if (!$patient->user) continue;

                    dispatch(new SendMedicineNotificationJob($patient->user));
                }

            });

        $this->info('Notifikasi berhasil di-dispatch ke queue');
    }
}