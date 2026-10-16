<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'username',
        'password',
        'role',
        'ref_id',
    ];

    protected $hidden = [
        'password',
    ];

    // 🔥 RELASI DINAMIS
    public function pasien()
    {
        return $this->belongsTo(Patient::class, 'ref_id');
    }

    public function petugas()
    {
        return $this->belongsTo(Petugas::class, 'ref_id');
    }

    public function manajemen()
    {
        return $this->belongsTo(Manajemen::class, 'ref_id');
    }
    
}