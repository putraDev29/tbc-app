<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Village extends Model
{
    protected $fillable = [
        'name',
    ];

    // =====================
    // RELASI KE PASIEN
    // =====================
    public function patients()
    {
        return $this->hasMany(Patient::class);
    }
}