<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;
use App\Models\Service;
use App\Models\Message;
use Throwable;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();

            // 1. Ambil semua project milik user
            $projects = Project::with('service')
                ->where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->get();

            // 2. Format list 'orders' untuk Workspace Project Aktif
            $orders = $projects->map(function ($project) {
                return [
                    'id' => $project->id,
                    'title' => optional($project->service)->nama_layanan ?? 'Project Service',
                    'price' => number_format(optional($project->service)->harga ?? 0, 0, ',', '.'),
                    'status' => ucfirst($project->status ?? 'briefing'),
                    'progress' => $project->progress_percent ?? 0,
                ];
            });

            // 3. Format list 'transactions'
            $transactions = $projects
                ->whereNotNull('external_id')
                ->groupBy('external_id')
                ->map(function ($items, $externalId) {
                    $firstItem = $items->first();
                    return [
                        'invoice_number' => $externalId,
                        'title' => 'Pembayaran ' . $items->count() . ' Layanan',
                        'date' => $firstItem->created_at ? $firstItem->created_at->format('d M Y') : date('d M Y'),
                        'status' => 'PAID',
                    ];
                })
                ->values();

            // 4. Safely query Chat / Message
            $chatInfo = [
                'sender_name' => 'Admin Identra',
                'last_message' => 'Selamat datang di IdentraStudio! Silakan mulai obrolan brief.',
                'created_at' => now()->format('H:i A'),
            ];

            try {
                $lastMessage = Message::whereHas('project', function ($q) use ($user) {
                    $q->where('user_id', $user->id);
                })->latest()->first();

                if ($lastMessage) {
                    $chatInfo = [
                        'sender_name' => $lastMessage->sender_id == $user->id ? 'Saya' : 'Admin Identra',
                        'last_message' => $lastMessage->message,
                        'created_at' => $lastMessage->created_at ? $lastMessage->created_at->format('H:i A') : now()->format('H:i A'),
                    ];
                }
            } catch (Throwable $e) {}

            // 5. PERUBAHAN: Ambil daftar layanan unggulan (List Services) agar bisa digeser
            $offers = [];
            try {
                $services = Service::all();
                $offers = $services->map(function ($svc) {
                    return [
                        'id' => $svc->id,
                        'title' => $svc->nama_layanan,
                        'description' => $svc->deskripsi ?? 'Layanan Digital Agency Premium',
                        'price' => 'Rp ' . number_format($svc->harga ?? 0, 0, ',', '.'),
                    ];
                });
            } catch (Throwable $e) {}

            // 6. Return Response JSON
            return response()->json([
                'success' => true,
                'message' => 'Data Dashboard Berhasil Diambil',
                'data' => [
                    'user' => [
                        'name' => $user->name,
                        'email' => $user->email,
                    ],
                    'chat' => $chatInfo,
                    'orders' => $orders,
                    'best_offer' => $offers->first() ?? null, // Fallback untuk model lama
                    'offers' => $offers, // Array layanan untuk slider/carousel
                    'transactions' => $transactions,
                ]
            ], 200);

        } catch (Throwable $th) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat Dashboard: ' . $th->getMessage()
            ], 500);
        }
    }
}