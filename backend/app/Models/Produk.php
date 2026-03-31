<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $table = 'produk';

    protected $fillable = [
        'nama_produk',
        'jenis_produk',
        'harga',
        'stok',
        'deskripsi',
        'gambar',
    ];

    public function transaksi()
    {
        return $this->hasMany(Transaksi::class, 'produk_id');
    }
}
