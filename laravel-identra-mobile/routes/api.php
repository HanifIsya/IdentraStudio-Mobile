<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TestController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\ProjectFileController;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::get('/cek-koneksi', [TestController::class, 'index']);
Route::get('/services', [TestController::class, 'getServices']); 
Route::post('/register', [AuthController::class, 'register']);

// 1. KUNCI PERBAIKAN: Beri nama 'login' pada rute login agar tidak crash saat unauthenticated
Route::post('/login', [AuthController::class, 'login'])->name('login');

// 2. KUNCI PERBAIKAN: Pindahkan Rute Download PDF ke Public Route agar bisa diakses Browser HP
Route::get('/invoices/{invoice_id}/pdf', [OrderController::class, 'downloadPdf']);


/*
|--------------------------------------------------------------------------
| Protected Routes (WAJIB Login / Pakai Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::post('/checkout', [OrderController::class, 'store']); 
    Route::get('/invoices', [OrderController::class, 'index']); // Daftar invoice tetap aman pakai token

    // Multi-room projects & chats
    Route::get('/projects', [ProjectController::class, 'index']); 
    Route::get('/projects/{project_id}/messages', [MessageController::class, 'getMessages']);
    Route::post('/projects/{project_id}/messages', [MessageController::class, 'sendMessage']);

    // Project Asset Files
    Route::get('/projects/{project_id}/files', [ProjectFileController::class, 'getFiles']);
    Route::post('/projects/{project_id}/files', [ProjectFileController::class, 'uploadFile']);

    // CRUD Services Admin
    Route::post('/services', [ServiceController::class, 'store']);
    Route::put('/services/{id}', [ServiceController::class, 'update']);
    Route::delete('/services/{id}', [ServiceController::class, 'destroy']);

    // UPDATE STATUS & PROGRESS PROJECT (Mendukung PUT dan POST agar bebas dari Error 405)
    Route::match(['put', 'post'], '/projects/{id}', [ProjectController::class, 'update']);
});