<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class MedicationLog extends Model
{
    protected $fillable = [
        'patient_id',
        'date',
        'day',
        'status',
        'taken_at',
        'proof_image',
        'status_validate',
        'validated'
    ];

    protected $casts = [
        'date' => 'date',
        'taken_at' => 'datetime',
        'validated' => 'boolean',
    ];

    /// ================= RELATION =================
    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    /// ================= HELPER =================
    public function isToday()
    {
        return $this->date->isToday();
    }

    public function isLate()
    {
        return $this->status === 'TERLAMBAT';
    }
}