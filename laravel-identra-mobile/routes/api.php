<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TestController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ServiceController; // <--- Import Controller Baru

/*
|--------------------------------------------------------------------------
| Public Routes (Bisa diakses tanpa login)
|--------------------------------------------------------------------------
*/
Route::get('/cek-koneksi', [TestController::class, 'index']);
Route::get('/services', [TestController::class, 'getServices']); // User biasa cuma bisa LIHAT
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);


/*
|--------------------------------------------------------------------------
| Protected Routes (WAJIB Login / Pakai Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    
    // Ambil data user yang sedang login
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Dashboard Data
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // --- CRUD SERVICES UNTUK ADMIN ---
    // Pintu untuk Menambah layanan baru
    Route::post('/services', [ServiceController::class, 'store']);
    
    // Pintu untuk Mengupdate layanan (butuh ID)
    Route::put('/services/{id}', [ServiceController::class, 'update']);
    
    // Pintu untuk Menghapus layanan (butuh ID)
    Route::delete('/services/{id}', [ServiceController::class, 'destroy']);
});