<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\CekPesananController;
use App\Http\Controllers\KatalogWebController;

Route::get('/', [CekPesananController::class, 'index'])->name('cek-pesanan');
Route::post('/verify', [CekPesananController::class, 'verify'])->name('cek-pesanan.verify');
Route::get('/lacak/{id}', [CekPesananController::class, 'showHasil'])->name('cek-pesanan.hasil');

// Catalog Routes
Route::get('/katalog', [KatalogWebController::class, 'index'])->name('katalog.index');
Route::get('/katalog/{id}', [KatalogWebController::class, 'show'])->name('katalog.show');
