<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;
use App\Models\Message;

class MessageController extends Controller
{
    /**
     * GET /api/projects/{project_id}/messages
     * Mengambil daftar pesan obrolan dalam satu project
     */
    public function getMessages(Request $request, $project_id)
    {
        $user = $request->user();
        $project = Project::find($project_id);

        if (!$project) {
            return response()->json([
                'status' => 'error',
                'message' => 'Ruang proyek tidak ditemukan.'
            ], 404);
        }

        // KUNCI PERBAIKAN:
        // Izinkan akses JIKA user adalah ADMIN ATAU user adalah Pemilik Project (Klien)
        if ($user->role !== 'admin' && $user->role !== 'Admin' && $project->user_id !== $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses terlarang ke ruang chat proyek ini.'
            ], 403);
        }

        // Ambil semua pesan beserta informasi pengirimnya (User/Admin)
        $messages = Message::with('user')
            ->where('project_id', $project_id)
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $messages
        ], 200);
    }

    /**
     * POST /api/projects/{project_id}/messages
     * Mengirim pesan baru dari Admin atau Klien
     */
    /**
     * POST /api/projects/{project_id}/messages
     */
    public function sendMessage(Request $request, $project_id)
    {
        $user = $request->user();
        $project = Project::find($project_id);

        if (!$project) {
            return response()->json([
                'status' => 'error',
                'message' => 'Ruang proyek tidak ditemukan.'
            ], 404);
        }

        // Check Izin Akses
        if ($user->role !== 'admin' && $user->role !== 'Admin' && $project->user_id !== $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses terlarang.'
            ], 403);
        }

        $request->validate([
            'message' => 'required|string',
        ]);

        // KUNCI PERBAIKAN: Masukkan sender_id dan user_id sekaligus
        $newMessage = Message::create([
            'project_id' => $project_id,
            'user_id'    => $user->id,
            'sender_id'  => $user->id, // Mengisi kolom sender_id
            'message'    => $request->message,
        ]);

        $messageWithUser = Message::with('user')->find($newMessage->id);

        return response()->json([
            'status' => 'success',
            'message' => 'Pesan berhasil dikirim.',
            'data' => $messageWithUser
        ], 201);
    }
}