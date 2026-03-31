<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('pelanggan', function (Blueprint $table) {
            $table->id();
            $table->string('nama');
            $table->string('no_hp');
            $table->text('keterangan')->nullable();

            // UKURAN BADAN (BLUS, KEMEJA, BLEZER)
            // Panjang
            $table->string('baju_pu')->nullable();
            $table->string('baju_pi')->nullable();
            $table->string('baju_pa')->nullable();
            $table->string('baju_lt')->nullable();
            $table->string('baju_gn')->nullable();
            // Lingkar
            $table->string('baju_le')->nullable();
            $table->string('baju_da')->nullable();
            $table->string('baju_pi_lingkar')->nullable();
            $table->string('baju_pa_lingkar')->nullable();
            // Lebar
            $table->string('baju_bh')->nullable();
            $table->string('baju_pu_lebar')->nullable();
            $table->string('baju_da_lebar')->nullable();
            // Lingkar Kerung Lengan
            $table->string('baju_ats')->nullable();
            $table->string('baju_sk')->nullable();
            $table->string('baju_bwh')->nullable();
            // Panjang Lengan
            $table->string('baju_a')->nullable();
            $table->string('baju_b')->nullable();

            // UKURAN CELANA
            // Lingkar
            $table->string('celana_pi')->nullable();
            $table->string('celana_pa')->nullable();
            $table->string('celana_ph')->nullable();
            $table->string('celana_lt')->nullable();
            $table->string('celana_psk')->nullable();
            // Panjang
            $table->string('celana_lt_panjang')->nullable();
            $table->string('celana_cln')->nullable();

            // UKURAN ROK
            // Lingkar
            $table->string('rok_pi')->nullable();
            $table->string('rok_pa')->nullable();
            // Panjang
            $table->string('rok_pa_panjang')->nullable();
            $table->string('rok_lt')->nullable();
            $table->string('rok_rok')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pelanggan');
    }
};
