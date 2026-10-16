<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Manajemen;

class ManajemenSeeder extends Seeder
{
    public function run()
    {
        Manajemen::create([
            'nip' => '197700001',
            'name' => 'Dr. Budi Kapus',
            'date_born' => '1980-01-01',
            'jabatan' => 'Kepala Puskesmas',
            'address' => 'Sidoarjo',
            'phone' => '081298765432',
        ]);
    }
}