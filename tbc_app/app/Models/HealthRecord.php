<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HealthRecord extends Model
{
    protected $fillable = [
        'patient_id',
        'date',
        'weight',
        'height',
        'bmi',
        'status_gizi'
    ];

    protected $casts = [
        'date' => 'date',
        'weight' => 'float',
        'height' => 'float',
        'bmi' => 'float',
    ];

    /// ================= RELATION =================
    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    /// ================= AUTO BMI =================
    protected static function booted()
    {
        static::saving(function ($model) {
            if ($model->height > 0) {
                $heightMeter = $model->height / 100;
                $model->bmi = $model->weight / ($heightMeter * $heightMeter);
            }
        });
    }
}