<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Patient extends Model
{
    protected $fillable = [
        'nik',
        'name',
        'date_born',
        'village_id',
        'address',
        'phone',
        'photo_url'
    ];

    protected $casts = [
        'date_born' => 'date'
    ];

    /// ================= RELATION =================
    public function logs()
    {
        return $this->hasMany(MedicationLog::class);
    }

    public function healthRecords()
    {
        return $this->hasMany(HealthRecord::class);
    }

    public function progress()
    {
        return $this->hasOne(TreatmentProgress::class);
    }

    /// ================= HELPER =================
    public function getAgeAttribute()
    {
        return $this->date_born
            ? $this->date_born->diffInYears(Carbon::now())
            : null;
    }

    public function todayStatus()
    {
        $log = $this->logs()
            ->whereDate('date', now())
            ->first();

        return $log ? $log->status : 'BELUM';
    }

    // Accessor untuk full URL foto
    public function getPhotoUrlAttribute($value)
    {
        if (!$value) {
            return null;
        }

        return asset('storage/' . $value);
    }

    public function user()
    {
        return $this->hasOne(User::class, 'ref_id')
            ->where('role', 'pasien');
    }


    public function village()
    {
        return $this->belongsTo(Village::class);
    }
}
