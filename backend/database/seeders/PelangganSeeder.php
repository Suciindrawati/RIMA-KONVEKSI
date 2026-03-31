<?php

namespace Database\Seeders;

use App\Models\Pelanggan;
use Illuminate\Database\Seeder;

class PelangganSeeder extends Seeder
{
    public function run(): void
    {
        $pelanggan = [
            [
                'nama' => 'Siti Rahayu',
                'no_hp' => '081234567890',
                'keterangan' => 'Pelanggan tetap, suka model modern',
                // Baju
                'baju_pu' => '60', 'baju_pi' => '38', 'baju_pa' => '36',
                'baju_lt' => '58', 'baju_gn' => '42',
                'baju_le' => '92', 'baju_da' => '88',
                'baju_pi_lingkar' => '32', 'baju_pa_lingkar' => '30',
                'baju_bh' => '46', 'baju_pu_lebar' => '48', 'baju_da_lebar' => '44',
                'baju_ats' => '42', 'baju_sk' => '38', 'baju_bwh' => '36',
                'baju_a' => '58', 'baju_b' => '24',
                // Celana
                'celana_pi' => '72', 'celana_pa' => '96', 'celana_ph' => '88',
                'celana_lt' => '52', 'celana_psk' => '40',
                'celana_lt_panjang' => '20', 'celana_cln' => '96',
                // Rok
                'rok_pi' => '72', 'rok_pa' => '96',
                'rok_pa_panjang' => '110', 'rok_lt' => '52', 'rok_rok' => '60',
            ],
            [
                'nama' => 'Dewi Lestari',
                'no_hp' => '082345678901',
                'keterangan' => 'Order seragam kantor rutin',
                'baju_pu' => '62', 'baju_pi' => '40', 'baju_pa' => '38',
                'baju_lt' => '60', 'baju_gn' => '44',
                'baju_le' => '96', 'baju_da' => '92',
                'baju_pi_lingkar' => '34', 'baju_pa_lingkar' => '32',
                'baju_bh' => '48', 'baju_pu_lebar' => '50', 'baju_da_lebar' => '46',
                'baju_ats' => '44', 'baju_sk' => '40', 'baju_bwh' => '38',
                'baju_a' => '60', 'baju_b' => '26',
                'celana_pi' => '76', 'celana_pa' => '100', 'celana_ph' => '92',
                'celana_lt' => '54', 'celana_psk' => '42',
                'celana_lt_panjang' => '22', 'celana_cln' => '98',
                'rok_pi' => '76', 'rok_pa' => '100',
                'rok_pa_panjang' => '112', 'rok_lt' => '54', 'rok_rok' => '62',
            ],
            [
                'nama' => 'Budi Santoso',
                'no_hp' => '083456789012',
                'keterangan' => 'Pesan seragam tim futsal',
                'baju_pu' => '68', 'baju_pi' => '44', 'baju_pa' => '42',
                'baju_lt' => '64', 'baju_gn' => '48',
                'baju_le' => '104', 'baju_da' => '100',
                'baju_pi_lingkar' => '38', 'baju_pa_lingkar' => '36',
                'baju_bh' => '52', 'baju_pu_lebar' => '54', 'baju_da_lebar' => '50',
                'baju_ats' => '46', 'baju_sk' => '42', 'baju_bwh' => '40',
                'baju_a' => '62', 'baju_b' => '28',
                'celana_pi' => '82', 'celana_pa' => '106', 'celana_ph' => '98',
                'celana_lt' => '58', 'celana_psk' => '46',
                'celana_lt_panjang' => '26', 'celana_cln' => '104',
                'rok_pi' => null, 'rok_pa' => null,
                'rok_pa_panjang' => null, 'rok_lt' => null, 'rok_rok' => null,
            ],
            [
                'nama' => 'Rina Wulandari',
                'no_hp' => '084567890123',
                'keterangan' => 'Seragam batik pernikahan keluarga',
                'baju_pu' => '58', 'baju_pi' => '36', 'baju_pa' => '34',
                'baju_lt' => '56', 'baju_gn' => '40',
                'baju_le' => '88', 'baju_da' => '84',
                'baju_pi_lingkar' => '30', 'baju_pa_lingkar' => '28',
                'baju_bh' => '44', 'baju_pu_lebar' => '46', 'baju_da_lebar' => '42',
                'baju_ats' => '40', 'baju_sk' => '36', 'baju_bwh' => '34',
                'baju_a' => '56', 'baju_b' => '22',
                'celana_pi' => '68', 'celana_pa' => '92', 'celana_ph' => '84',
                'celana_lt' => '48', 'celana_psk' => '38',
                'celana_lt_panjang' => '18', 'celana_cln' => '92',
                'rok_pi' => '68', 'rok_pa' => '92',
                'rok_pa_panjang' => '108', 'rok_lt' => '48', 'rok_rok' => '58',
            ],
            [
                'nama' => 'Ahmad Fauzi',
                'no_hp' => '085678901234',
                'keterangan' => 'Seragam OSIS sekolah',
                'baju_pu' => '65', 'baju_pi' => '42', 'baju_pa' => '40',
                'baju_lt' => '62', 'baju_gn' => '46',
                'baju_le' => '100', 'baju_da' => '96',
                'baju_pi_lingkar' => '36', 'baju_pa_lingkar' => '34',
                'baju_bh' => '50', 'baju_pu_lebar' => '52', 'baju_da_lebar' => '48',
                'baju_ats' => '44', 'baju_sk' => '40', 'baju_bwh' => '38',
                'baju_a' => '60', 'baju_b' => '26',
                'celana_pi' => '78', 'celana_pa' => '102', 'celana_ph' => '94',
                'celana_lt' => '56', 'celana_psk' => '44',
                'celana_lt_panjang' => '24', 'celana_cln' => '100',
                'rok_pi' => null, 'rok_pa' => null,
                'rok_pa_panjang' => null, 'rok_lt' => null, 'rok_rok' => null,
            ],
        ];

        foreach ($pelanggan as $data) {
            Pelanggan::create($data);
        }
    }
}
