<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Message;
use App\Models\Project;
use Illuminate\Support\Facades\Auth;

class MessageController extends Controller
{
    /**
     * 1. GET: Mengambil riwayat chat berdasarkan Room Project tertentu
     */
    public function getMessages($projectId)
    {
        $user = Auth::user();

        // Validasi keamanan: Pastikan project ini memang milik user yang sedang login
        $project = Project::where('id', $projectId)
            ->where('user_id', $user->id)
            ->first();

        if (!$project) {
            return response()->json(['message' => 'Ruang proyek tidak ditemukan atau akses dilarang.'], 403);
        }

        // Ambil semua pesan di room ini, urutkan dari yang paling lama ke baru
        $messages = Message::where('project_id', $projectId)
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $messages
        ], 200);
    }

    /**
     * 2. POST: Mengirim pesan baru ke dalam Room Project tertentu
     */
    public function sendMessage(Request $request, $projectId)
    {
        $request->validate([
            'message' => 'required|string'
        ]);

        $user = Auth::user();

        // Validasi keamanan kepemilikan room
        $project = Project::where('id', $projectId)
            ->where('user_id', $user->id)
            ->first();

        if (!$project) {
            return response()->json(['message' => 'Gagal mengirim pesan. Ruang proyek tidak valid.'], 403);
        }

        // Simpan pesan baru ke database
        $newMessage = Message::create([
            'project_id' => $projectId,
            'sender_id' => $user->id, // ID User yang sedang login bertindak sebagai pengirim
            'message' => $request->input('message'),
            'attachment_url' => null // Bisa dikembangkan untuk fitur upload file di chat nanti
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Pesan berhasil dikirim.',
            'data' => $newMessage
        ], 201);
    }
}