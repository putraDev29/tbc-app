<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Models\Petugas;
use App\Models\Manajemen;
use App\Models\Patient;

class UserSeeder extends Seeder
{
    public function run()
    {
        // ambil data
        $petugas = Petugas::first();
        $kapus = Manajemen::first();
        $patient = Patient::first(); // 🔥 tambah ini

        // ================= PETUGAS =================
        if ($petugas) {
            User::create([
                'username' => $petugas->nip,
                'password' => Hash::make('123456'),
                'role' => 'petugas',
                'ref_id' => $petugas->id,
            ]);
        }

        // ================= KAPUS =================
        if ($kapus) {
            User::create([
                'username' => $kapus->nip,
                'password' => Hash::make('123456'),
                'role' => 'manajemen',
                'ref_id' => $kapus->id,
            ]);
        }

        // ================= PASIEN =================
        if ($patient) {
            User::create([
                'username' => $patient->nik, // 🔥 pakai NIK
                'password' => Hash::make('123456'),
                'role' => 'pasien',
                'ref_id' => $patient->id,
            ]);
        }
    }
}