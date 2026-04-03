<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KatalogGambar extends Model
{
    protected $table = 'katalog_gambars';

    protected $fillable = [
        'katalog_id',
        'gambar',
    ];

    public function katalog()
    {
        return $this->belongsTo(Katalog::class);
    }
}
