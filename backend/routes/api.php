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

// Proxy Storage for CORS (Flutter Web)
Route::get('/storage/{disk}/{file}', function ($disk, $file) {
    $path = storage_path("app/public/{$disk}/{$file}");
    if (!file_exists($path)) abort(404);
    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET',
        'Access-Control-Allow-Headers' => 'Content-Type, X-Requested-With',
    ]);
})->where('file', '.*');

// Protected routes (require token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard', [TransaksiController::class, 'dashboard']);

    // Pelanggan
    Route::get('/pelanggan',      [PelangganController::class, 'index']);
    Route::get('/pelanggan/{id}', [PelangganController::class, 'show']);
    Route::middleware('admin')->group(function () {
        Route::post('/pelanggan',     [PelangganController::class, 'store']);
        Route::put('/pelanggan/{id}', [PelangganController::class, 'update']);
        Route::delete('/pelanggan/{id}', [PelangganController::class, 'destroy']);
    });

    // Produk
    Route::get('/produk',      [ProdukController::class, 'index']);
    Route::get('/produk/{id}', [ProdukController::class, 'show']);
    Route::middleware('admin')->group(function () {
        Route::post('/produk',     [ProdukController::class, 'store']);
        Route::put('/produk/{id}', [ProdukController::class, 'update']);
        Route::delete('/produk/{id}', [ProdukController::class, 'destroy']);
    });

    // Transaksi
    Route::get('/transaksi',      [TransaksiController::class, 'index']);
    Route::middleware('admin')->group(function () {
        Route::post('/transaksi',     [TransaksiController::class, 'store']);
        Route::put('/transaksi/{id}', [TransaksiController::class, 'update']);
        Route::delete('/transaksi/{id}', [TransaksiController::class, 'destroy']);
    });

    // Katalog
    Route::get('/katalog',         [KatalogController::class, 'index']);
    Route::get('/katalog/{id}',    [KatalogController::class, 'show']);
    Route::middleware('admin')->group(function () {
        Route::post('/katalog',        [KatalogController::class, 'store']);
        Route::put('/katalog/{id}',     [KatalogController::class, 'update']);
        Route::delete('/katalog/{id}', [KatalogController::class, 'destroy']);
    });
});
