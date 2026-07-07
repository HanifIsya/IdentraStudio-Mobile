<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TestController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\MessageController; // <--- 1. IMPORT CONTROLLER CHAT BARU
use App\Http\Controllers\Api\ProjectFileController;

/*
|--------------------------------------------------------------------------
| Public Routes (Bisa diakses tanpa login)
|--------------------------------------------------------------------------
*/
Route::get('/cek-koneksi', [TestController::class, 'index']);
Route::get('/services', [TestController::class, 'getServices']); 
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

    // --- RUTE CHECKOUT / PENGORDERAN ---
    Route::post('/checkout', [OrderController::class, 'store']); 

    // --- RUTE DATA PROJECT MULTI-ROOM ---
    Route::get('/projects', [ProjectController::class, 'index']); 

    // --- RUTE CHAT ROOM PER PROJECT ---
    Route::get('/projects/{project_id}/messages', [MessageController::class, 'getMessages']); // <--- 2. AMBIL CHAT
    Route::post('/projects/{project_id}/messages', [MessageController::class, 'sendMessage']); // <--- 3. KIRIM CHAT

    Route::get('/projects/{project_id}/files', [ProjectFileController::class, 'getFiles']);
Route::post('/projects/{project_id}/files', [ProjectFileController::class, 'uploadFile']);

    // --- CRUD SERVICES UNTUK ADMIN ---
    Route::post('/services', [ServiceController::class, 'store']);
    Route::put('/services/{id}', [ServiceController::class, 'update']);
    Route::delete('/services/{id}', [ServiceController::class, 'destroy']);
});