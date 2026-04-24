<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
// Import semua model yang kamu buat tadi
use App\Models\Chat;
use App\Models\Order;
use App\Models\Offer;
use App\Models\Transaction;

class DashboardController extends Controller
{
    /**
     * Mengambil data untuk Dashboard Identra Studio.
     * Menggunakan middleware auth:sanctum agar data yang muncul
     * sesuai dengan user yang sedang login.
     */
    public function index(Request $request)
    {
        $user = $request->user(); // Mengambil data user yang sedang login

        return response()->json([
            'success' => true,
            'message' => 'Data Dashboard Berhasil Diambil',
            'data' => [
                // Info User
                'user' => [
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                
                // Ambil 1 chat terbaru milik user ini
                'chat' => Chat::where('user_id', $user->id)
                    ->latest()
                    ->first(),

                // Ambil daftar order yang statusnya masih 'pending' atau 'active'
                'orders' => Order::where('user_id', $user->id)
                    ->whereIn('status', ['pending', 'active'])
                    ->get(),

                // Ambil penawaran terbaik (Best Offers)
                // Kita ambil 1 saja yang paling baru
                'best_offer' => Offer::latest()->first(),

                // Ambil 2 riwayat transaksi terakhir
                'transactions' => Transaction::where('user_id', $user->id)
                    ->latest()
                    ->take(2)
                    ->get(),
            ]
        ], 200);
    }
}