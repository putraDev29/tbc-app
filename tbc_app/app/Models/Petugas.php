<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Petugas extends Model
{
    protected $table = 'petugas';

    protected $fillable = [
        'nip',
        'name',
        'date_born',
        'jabatan',
        'address',
        'phone',
        'photo_url',
    ];

    protected $casts = [
        'date_born' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // 🔗 Relasi ke User
    public function user()
    {
        return $this->hasOne(User::class, 'ref_id')
                    ->where('role', 'petugas');
    }
}