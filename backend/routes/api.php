<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PelangganController;
use App\Http\Controllers\Api\ProdukController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\KatalogController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Protected routes (require token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard', [TransaksiController::class, 'dashboard']);

    // Pelanggan
    Route::apiResource('pelanggan', PelangganController::class);

    // Produk
    Route::apiResource('produk', ProdukController::class);

    // Transaksi
    Route::get('/transaksi',      [TransaksiController::class, 'index']);
    Route::post('/transaksi',     [TransaksiController::class, 'store']);
    Route::put('/transaksi/{id}', [TransaksiController::class, 'update']);
    Route::delete('/transaksi/{id}', [TransaksiController::class, 'destroy']);

    // Katalog
    Route::get('/katalog',         [KatalogController::class, 'index']);
    Route::post('/katalog',        [KatalogController::class, 'store']);
    Route::get('/katalog/{id}',    [KatalogController::class, 'show']);
    Route::delete('/katalog/{id}', [KatalogController::class, 'destroy']);
});
