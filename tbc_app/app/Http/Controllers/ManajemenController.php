<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Patient;
use App\Models\TreatmentProgress;
use App\Models\MedicationLog;

class ManajemenController extends Controller
{
    public function index(Request $request)
    {
        $year  = $request->year ?? now()->year;
        $month = $request->month ?? 0;
        $desa  = $request->desa ?? 'Semua Desa';

        /// ================= BASE QUERY =================
        $patients = Patient::with('village')
            ->when($desa != 'Semua Desa', function ($q) use ($desa) {
                $q->whereHas('village', function ($v) use ($desa) {
                    $v->where('name', $desa);
                });
            })
            ->get();

        /// ================= FILTER TANGGAL =================
        if ($month != 0) {
            $patients = $patients->filter(function ($p) use ($year, $month) {
                return date('Y', strtotime($p->created_at)) == $year &&
                    date('n', strtotime($p->created_at)) == $month;
            });
        } else {
            $patients = $patients->filter(function ($p) use ($year) {
                return date('Y', strtotime($p->created_at)) == $year;
            });
        }

        return response()->json([
            'summary' => $this->summary($patients),
            'wilayah' => $this->wilayah($patients),
            'chart'   => $this->chart($patients, $month)
        ]);
    }

    /// ================= STATUS HELPER =================
    private function getStatus($patientId)
    {
        $tp = TreatmentProgress::where('patient_id', $patientId)->first();

        if (!$tp) return 'aktif';

        /// SEMBUH
        if ($tp->total_days == $tp->current_days) {
            return 'sembuh';
        }

        /// DROP OUT (cek log tidak minum)
        $tidak = MedicationLog::where('patient_id', $patientId)
            ->where('status', 'TIDAK')
            ->count();

        if ($tidak > 3) { // threshold bisa diubah
            return 'drop';
        }

        return 'aktif';
    }

    /// ================= SUMMARY =================
    private function summary($patients)
    {
        $aktif = $sembuh = $drop = 0;

        foreach ($patients as $p) {
            $status = $this->getStatus($p->id);

            if ($status == 'aktif') $aktif++;
            if ($status == 'sembuh') $sembuh++;
            if ($status == 'drop') $drop++;
        }

        return compact('aktif', 'sembuh', 'drop');
    }

    /// ================= WILAYAH =================
    private function wilayah($patients)
    {
        $result = [];

        foreach ($patients as $p) {
            $desa = $p->village->name ?? 'Unknown';
            $status = $this->getStatus($p->id);

            if (!isset($result[$desa])) {
                $result[$desa] = [
                    'desa' => $desa,
                    'aktif' => 0,
                    'sembuh' => 0,
                    'drop' => 0,
                ];
            }

            $result[$desa][$status]++;
        }

        return array_values($result);
    }

    /// ================= CHART =================
    private function chart($patients, $month)
    {
        if ($month == 0) {
            return $this->monthlyChart($patients);
        } else {
            return $this->weeklyChart($patients);
        }
    }

    /// BULANAN
    private function monthlyChart($patients)
    {
        $result = [];

        foreach ($patients as $p) {
            $month = date('n', strtotime($p->created_at));
            $status = $this->getStatus($p->id);

            if (!isset($result[$month])) {
                $result[$month] = [
                    'month' => $month,
                    'aktif' => 0,
                    'sembuh' => 0,
                    'drop' => 0,
                ];
            }

            $result[$month][$status]++;
        }

        return array_values($result);
    }

    /// MINGGUAN (SIMULASI)
    private function weeklyChart($patients)
    {
        $summary = $this->summary($patients);

        $ratios = [0.18, 0.27, 0.32, 0.23];

        $result = [];
        $usedA = $usedS = $usedD = 0;

        for ($i = 0; $i < 4; $i++) {

            $aktif  = round($summary['aktif'] * $ratios[$i]);
            $sembuh = round($summary['sembuh'] * $ratios[$i]);
            $drop   = round($summary['drop'] * $ratios[$i]);

            if ($i == 3) {
                $aktif  = $summary['aktif'] - $usedA;
                $sembuh = $summary['sembuh'] - $usedS;
                $drop   = $summary['drop'] - $usedD;
            }

            $usedA += $aktif;
            $usedS += $sembuh;
            $usedD += $drop;

            $result[] = [
                'week' => $i + 1,
                'aktif' => $aktif,
                'sembuh' => $sembuh,
                'drop' => $drop,
            ];
        }

        return $result;
    }
}
