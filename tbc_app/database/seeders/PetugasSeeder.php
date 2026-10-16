<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Petugas;

class PetugasSeeder extends Seeder
{
    public function run()
    {
        Petugas::create([
            'nip' => '1987654321',
            'name' => 'Ahmad Petugas',
            'date_born' => '1990-05-10',
            'jabatan' => 'Petugas Lapangan',
            'address' => 'Surabaya',
            'phone' => '081234567890',
        ]);
    }
}