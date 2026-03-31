<?php

namespace Database\Seeders;

use App\Models\Katalog;
use Illuminate\Database\Seeder;

class KatalogSeeder extends Seeder
{
    public function run(): void
    {
        $katalog = [
            [
                'judul' => 'Koleksi Seragam Kantor 2024',
                'deskripsi' => 'Koleksi terbaru seragam kantor dengan desain modern dan profesional. Tersedia dalam berbagai pilihan warna dan model yang elegan untuk penampilan maksimal di tempat kerja.',
                'gambar' => null,
            ],
            [
                'judul' => 'Batik Premium Nusantara',
                'deskripsi' => 'Koleksi batik premium dengan motif-motif khas Nusantara. Dibuat dengan teknik printing berkualitas tinggi menggunakan bahan katun halus yang nyaman dipakai sepanjang hari.',
                'gambar' => null,
            ],
            [
                'judul' => 'Seragam Sekolah & Osis',
                'deskripsi' => 'Paket seragam lengkap untuk sekolah dan organisasi siswa. Bahan kuat dan tahan lama, nyaman untuk aktivitas sehari-hari. Tersedia untuk semua jenjang pendidikan.',
                'gambar' => null,
            ],
            [
                'judul' => 'Blazer & Jas Formal',
                'deskripsi' => 'Koleksi blazer dan jas formal berkualitas tinggi. Cocok untuk presentasi, meeting, dan acara resmi perusahaan. Dibuat dengan bahan wool premium anti kerut.',
                'gambar' => null,
            ],
            [
                'judul' => 'Pakaian Olahraga & Kaos Tim',
                'deskripsi' => 'Seragam olahraga dan kaos tim custom dengan sablon atau bordir. Bahan polyester moisture-wicking yang menyerap keringat dan nyaman untuk aktivitas olahraga.',
                'gambar' => null,
            ],
            [
                'judul' => 'Gamis & Busana Muslim',
                'deskripsi' => 'Koleksi gamis dan busana muslim syari untuk berbagai kesempatan. Bahan premium yang ringan, adem, dan tidak transparan. Tersedia dalam berbagai model dan warna.',
                'gambar' => null,
            ],
        ];

        foreach ($katalog as $data) {
            Katalog::create($data);
        }
    }
}
