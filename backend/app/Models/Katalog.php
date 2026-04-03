<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Katalog extends Model
{
    protected $table = 'katalog';

    protected $fillable = [
        'judul',
        'deskripsi',
        'gambar',
    ];

    public function gambars()
    {
        return $this->hasMany(KatalogGambar::class);
    }
}
