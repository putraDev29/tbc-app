<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class TreatmentProgress extends Model
{
    protected $fillable = [
        'patient_id',
        'start_date',
        'end_date',
        'current_day',
        'total_days'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    /// ================= RELATION =================
    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    /// ================= AUTO HITUNG HARI =================
    public function updateCurrentDay()
    {
        if ($this->start_date) {
            $this->current_day = $this->start_date->diffInDays(Carbon::today());
            $this->save();
        }
    }

    /// ================= STATUS FASE =================
    public function getPhaseAttribute()
    {
        return $this->current_day <= 56 ? 'Fase Awal' : 'Fase Lanjutan';
    }
}
