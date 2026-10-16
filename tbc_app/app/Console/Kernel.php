<?php

namespace App\Console;

use App\Models\MedicationLog;
use App\Models\Patient;
use App\Models\TreatmentProgress;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        // ================= 1. JADWAL 16:00 WIB: CATAT STATUS TIDAK PATUH =================
        // Pasien yang belum mencatat obat hingga pukul 16:00 ditandai status 'TIDAK'
        $schedule->call(function () {
            $now = now()->setTimezone('Asia/Jakarta');
            $today = $now->toDateString();
            Log::info('Scheduler 16:00 RUN: Cek kepatuhan obat untuk tanggal ' . $today);

            $patients = Patient::with('progress')->get();

            foreach ($patients as $patient) {
                $hasLog = MedicationLog::where('patient_id', $patient->id)
                    ->whereDate('date', $today)
                    ->exists();

                if (!$hasLog) {
                    $day = $patient->progress ? ($patient->progress->current_day + 1) : 1;

                    MedicationLog::create([
                        'patient_id'      => $patient->id,
                        'date'            => $today,
                        'status'          => 'TIDAK',
                        'taken_at'        => null,
                        'status_validate' => 0,
                        'validated'       => false,
                        'day'             => $day,
                    ]);

                    if ($patient->progress) {
                        $patient->progress->update([
                            'current_day' => $day
                        ]);
                    }
                }
            }
        })->dailyAt('16:00')->timezone('Asia/Jakarta');

        // ================= 2. JADWAL 20:00 WIB: FAILSAFE EVALUASI HARI =================
        // Memastikan tidak ada pasien yang terlewat evaluasi hari ini
        $schedule->call(function () {
            $now = now()->setTimezone('Asia/Jakarta');
            $today = $now->toDateString();
            Log::info('Scheduler 20:00 RUN: Failsafe cek log tanggal ' . $today);

            $patients = Patient::with('progress')->get();

            foreach ($patients as $patient) {
                $hasLog = MedicationLog::where('patient_id', $patient->id)
                    ->whereDate('date', $today)
                    ->exists();

                if (!$hasLog) {
                    $day = $patient->progress ? ($patient->progress->current_day + 1) : 1;

                    MedicationLog::create([
                        'patient_id'      => $patient->id,
                        'date'            => $today,
                        'status'          => 'TIDAK',
                        'taken_at'        => null,
                        'status_validate' => 0,
                        'validated'       => false,
                        'day'             => $day,
                    ]);

                    if ($patient->progress) {
                        $patient->progress->update([
                            'current_day' => $day
                        ]);
                    }
                }
            }
        })->dailyAt('20:00')->timezone('Asia/Jakarta');

        // ================= 3. COMMAND REMINDER NOTIFIKASI =================
        // Kirim pengingat ke pasien yang belum minum obat pada jam-jam strategis
        $schedule->command('medicine:reminder')->dailyAt('08:00')->timezone('Asia/Jakarta');
        $schedule->command('medicine:reminder')->dailyAt('12:00')->timezone('Asia/Jakarta');
        $schedule->command('medicine:reminder')->dailyAt('15:00')->timezone('Asia/Jakarta');
    }

    /**
     * Register the commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        $this->load(__DIR__ . '/Commands');

        require base_path('routes/console.php');
    }
}
