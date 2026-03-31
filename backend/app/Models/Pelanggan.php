<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pelanggan extends Model
{
    protected $table = 'pelanggan';

    protected $fillable = [
        'nama',
        'no_hp',
        'keterangan',
        'tanggal',

        // Baju
        'baju_pu', 'baju_pi', 'baju_pa', 'baju_lt', 'baju_gn',
        'baju_le', 'baju_da', 'baju_pi_lingkar', 'baju_pa_lingkar',
        'baju_bh', 'baju_pu_lebar', 'baju_da_lebar',
        'baju_ats', 'baju_sk', 'baju_bwh',
        'baju_a', 'baju_b',

        // Celana
        'celana_pi', 'celana_pa', 'celana_ph', 'celana_lt', 'celana_psk',
        'celana_lt_panjang', 'celana_cln',

        // Rok
        'rok_pi', 'rok_pa',
        'rok_pa_panjang', 'rok_lt', 'rok_rok',
    ];

    public function transaksi()
    {
        return $this->hasMany(Transaksi::class, 'pelanggan_id');
    }
}
