<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin user
        User::create([
            'nama'     => 'Admin',
            'email'    => 'admin@rimakonveksi.com',
            'password' => Hash::make('admin123'),
            'role'     => 'admin',
        ]);

        // Data aplikasi
        $this->call([
            ProdukSeeder::class,
            KatalogSeeder::class,
            PelangganSeeder::class,
            TransaksiSeeder::class,
        ]);
    }
}
