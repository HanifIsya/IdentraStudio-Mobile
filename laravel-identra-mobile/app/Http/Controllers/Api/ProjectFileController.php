<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;
use App\Models\ProjectFile;
use Illuminate\Support\Facades\Storage;

class ProjectFileController extends Controller
{
    /**
     * GET /api/projects/{project_id}/files
     * Menampilkan daftar file dalam satu project
     */
    public function getFiles(Request $request, $project_id)
    {
        $user = $request->user();
        $project = Project::find($project_id);

        if (!$project) {
            return response()->json(['message' => 'Project tidak ditemukan.'], 404);
        }

        // Cek Otorisasi (Admin atau Pemilik Project)
        if ($user->role !== 'admin' && $user->role !== 'Admin' && $project->user_id !== $user->id) {
            return response()->json(['message' => 'Akses terlarang.'], 403);
        }

        $files = ProjectFile::with('user')
            ->where('project_id', $project_id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($file) {
                return [
                    'id' => $file->id,
                    'project_id' => $file->project_id,
                    'file_name' => $file->file_name ?? 'file_asset',
                    'file_url' => asset('storage/' . $file->file_path),
                    'file_size' => $file->file_size ?? '0 KB',
                    'uploaded_by' => $file->user->name ?? 'User',
                    'created_at' => $file->created_at ? $file->created_at->format('d M Y, H:i') : '',
                ];
            });

        return response()->json(['status' => 'success', 'data' => $files], 200);
    }

    /**
     * POST /api/projects/{project_id}/files
     * Mengunggah file ke project
     */
   public function uploadFile(Request $request, $project_id)
    {
        $user = $request->user();
        $project = Project::find($project_id);

        if (!$project) {
            return response()->json(['message' => 'Project tidak ditemukan.'], 404);
        }

        // Check Hak Akses Admin atau Pemilik Project
        $isAdmin = strtolower($user->role ?? '') === 'admin';
        if (!$isAdmin && $project->user_id !== $user->id) {
            return response()->json(['message' => 'Akses terlarang.'], 403);
        }

        $request->validate([
            'file' => 'required|file|max:20480',
        ]);

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $originalName = $file->getClientOriginalName();
            $fileExtension = strtolower($file->getClientOriginalExtension()); // Ambil ekstensi (e.g. pdf, png)
            $fileSize = round($file->getSize() / 1024, 1) . ' KB';
            $path = $file->store('project_files', 'public');

            $roleUploader = $isAdmin ? 'admin' : 'client';

            $projectFile = ProjectFile::create([
                'project_id'  => $project_id,
                'user_id'     => $user->id,
                'uploaded_by' => $roleUploader,
                'file_name'   => $originalName,
                'file_type'   => $fileExtension, // TAMBAHKAN INI (Mengisi kolom file_type)
                'file_path'   => $path,
                'file_size'   => $fileSize,
            ]);

            return response()->json([
                'status'  => 'success',
                'message' => 'File berhasil diunggah!',
                'data'    => $projectFile->load('user')
            ], 201);
        }

        return response()->json(['message' => 'File tidak ditemukan.'], 400);
    }
}