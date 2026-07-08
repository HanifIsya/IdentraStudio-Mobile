<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;

class ProjectController extends Controller
{
    /**
     * GET /api/projects
     * Mengambil daftar project
     */
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'admin') {
            $projects = Project::with(['user', 'service'])
                ->orderBy('created_at', 'desc')
                ->get();
        } else {
            $projects = Project::with(['service'])
                ->where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->get();
        }

        $formattedProjects = $projects->map(function ($project) {
            return [
                'id' => $project->id,
                'external_id' => $project->external_id ?? 'INV-UNKNOWN',
                'status' => $project->status ?? 'briefing',
                'progress_percent' => $project->progress_percent ?? 0,
                'created_at' => $project->created_at ? $project->created_at->format('d M Y') : null,
                'user' => [
                    'id' => $project->user->id ?? null,
                    'name' => $project->user->name ?? 'Klien Identra',
                    'email' => $project->user->email ?? '-',
                ],
                'service' => [
                    'id' => $project->service->id ?? null,
                    'nama_layanan' => $project->service->nama_layanan ?? 'Project Service',
                    'harga' => $project->service->harga ?? 0,
                ],
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $formattedProjects
        ], 200);
    }

    /**
     * PUT/POST /api/projects/{id}
     * KUNCI PERBAIKAN: Fungsi update yang dicari Laravel
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();

        // 1. Verifikasi Admin
        if ($user->role !== 'admin' && $user->role !== 'Admin') {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses ditolak. Hanya Admin.'
            ], 403);
        }

        // 2. Gabungkan JSON payload jika dikirim lewat JSON raw body
        $data = $request->all();
        if (empty($data)) {
            $data = $request->json()->all();
        }

        // 3. Validasi Data
        $validator = \Illuminate\Support\Facades\Validator::make($data, [
            'status' => 'required|string',
            'progress_percent' => 'required|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // 4. Cari Project
        $project = Project::find($id);

        if (!$project) {
            return response()->json([
                'status' => 'error',
                'message' => 'Project tidak ditemukan.'
            ], 404);
        }

        // 5. Simpan Perubahan
        $project->update([
            'status' => $data['status'],
            'progress_percent' => (int) $data['progress_percent'],
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Status & Progress project berhasil diperbarui!',
            'data' => $project
        ], 200);
    }
}