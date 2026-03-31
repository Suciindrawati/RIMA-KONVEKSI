<?php

namespace Database\Seeders;

use App\Models\Produk;
use Illuminate\Database\Seeder;

class ProdukSeeder extends Seeder
{
    public function run(): void
    {
        $produk = [
            [
                'nama_produk' => 'Kemeja Batik Formal',
                'jenis_produk' => 'Kemeja',
                'stok' => 25,
                'deskripsi' => 'Kemeja batik motif klasik cocok untuk acara formal dan semi formal. Bahan katun halus berkualitas tinggi.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Blus Kantor Polos',
                'jenis_produk' => 'Blus',
                'stok' => 30,
                'deskripsi' => 'Blus polos elegan untuk seragam kantor. Tersedia berbagai warna sesuai kebutuhan.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Celana Bahan Formal',
                'jenis_produk' => 'Celana',
                'stok' => 20,
                'deskripsi' => 'Celana bahan berkualitas untuk seragam kantor dan acara formal. Bahan premium anti kusut.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Rok Span Knee',
                'jenis_produk' => 'Rok',
                'stok' => 15,
                'deskripsi' => 'Rok span pendek selutut, cocok untuk seragam kantor dan sekolah. Bahan polyester lembut.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Blazer Formal Wanita',
                'jenis_produk' => 'Blazer',
                'stok' => 10,
                'deskripsi' => 'Blazer formal wanita bahan wool premium. Cocok untuk acara resmi dan seragam perusahaan.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Seragam Batik Couple',
                'jenis_produk' => 'Seragam',
                'stok' => 50,
                'deskripsi' => 'Paket seragam batik couple untuk pasangan. Motif senada dengan bahan katun prima.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Kaos Polo Bordir',
                'jenis_produk' => 'Kaos',
                'stok' => 40,
                'deskripsi' => 'Kaos polo berkerah dengan bordir nama/logo perusahaan. Bahan lacoste pique premium.',
                'gambar' => null,
            ],
            [
                'nama_produk' => 'Gamis Syari',
                'jenis_produk' => 'Gamis',
                'stok' => 18,
                'deskripsi' => 'Gamis syari dengan bahan wolfis lembut dan adem. Cocok untuk seragam pengajian dan acara keagamaan.',
                'gambar' => null,
            ],
        ];

        foreach ($produk as $data) {
            Produk::create($data);
        }
    }
}
