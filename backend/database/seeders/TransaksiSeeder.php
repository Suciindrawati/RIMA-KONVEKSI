<?php

namespace Database\Seeders;

use App\Models\Transaksi;
use Illuminate\Database\Seeder;

class TransaksiSeeder extends Seeder
{
    public function run(): void
    {
        $transaksi = [
            [
                'pelanggan_id' => 1,
                'produk_id' => 1,
                'jumlah' => 5,
                'total_harga' => 750000,
                'status' => 'Selesai',
                'tanggal' => '2024-01-10',
            ],
            [
                'pelanggan_id' => 2,
                'produk_id' => 2,
                'jumlah' => 10,
                'total_harga' => 1200000,
                'status' => 'Selesai',
                'tanggal' => '2024-01-15',
            ],
            [
                'pelanggan_id' => 3,
                'produk_id' => 7,
                'jumlah' => 15,
                'total_harga' => 1350000,
                'status' => 'Dalam Proses',
                'tanggal' => '2024-02-01',
            ],
            [
                'pelanggan_id' => 4,
                'produk_id' => 6,
                'jumlah' => 8,
                'total_harga' => 2400000,
                'status' => 'Selesai',
                'tanggal' => '2024-02-14',
            ],
            [
                'pelanggan_id' => 5,
                'produk_id' => 3,
                'jumlah' => 20,
                'total_harga' => 2800000,
                'status' => 'Dalam Proses',
                'tanggal' => '2024-03-01',
            ],
            [
                'pelanggan_id' => 1,
                'produk_id' => 5,
                'jumlah' => 3,
                'total_harga' => 1800000,
                'status' => 'Pesanan Dibuat',
                'tanggal' => '2024-03-10',
            ],
            [
                'pelanggan_id' => 2,
                'produk_id' => 8,
                'jumlah' => 12,
                'total_harga' => 1560000,
                'status' => 'Dalam Proses',
                'tanggal' => '2024-03-15',
            ],
            [
                'pelanggan_id' => 3,
                'produk_id' => 4,
                'jumlah' => 6,
                'total_harga' => 540000,
                'status' => 'Pesanan Dibuat',
                'tanggal' => '2024-03-20',
            ],
        ];

        foreach ($transaksi as $data) {
            Transaksi::create($data);
        }
    }
}
