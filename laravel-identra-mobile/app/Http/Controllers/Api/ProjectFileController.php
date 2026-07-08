<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ProjectFile;
use App\Models\Project;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ProjectFileController extends Controller
{
    // 1. GET: Ambil list file per Project Room
    public function getFiles($projectId)
    {
        $user = Auth::user();
        $project = Project::where('id', $projectId)->where('user_id', $user->id)->first();

        if (!$project) {
            return response()->json(['message' => 'Akses dilarang.'], 403);
        }

        $files = ProjectFile::where('project_id', $projectId)->orderBy('created_at', 'desc')->get();
        return response()->json(['status' => 'success', 'data' => $files], 200);
    }

    // 2. POST: Unggah file baru ke Project Room
    public function uploadFile(Request $request, $projectId)
    {
        $request->validate([
            'file' => 'required|file|max:20480' // Batasan file max 20MB
        ]);

        $user = Auth::user();
        $project = Project::where('id', $projectId)->where('user_id', $user->id)->first();

        if (!$project) {
            return response()->json(['message' => 'Gagal mengunggah file.'], 403);
        }

        if ($request->file('file')->isValid()) {
            $file = $request->file('file');
            
            // Simpan file asli ke folder storage/app/public/project_assets
            $path = $file->store('project_assets', 'public');
            $publicUrl = Storage::url($path);

            // Hitung ukuran file dalam bentuk KB/MB yang mudah dibaca
            $sizeBytes = $file->getSize();
            $fileSizeFormatted = $sizeBytes >= 1048576 
                ? number_format($sizeBytes / 1048576, 2) . ' MB' 
                : number_format($sizeBytes / 1024, 2) . ' KB';

            $newFile = ProjectFile::create([
    'project_id' => $projectId,
    'user_id' => $user->id,
    'file_name' => $file->getClientOriginalName(),
    
    // GUNAKAN HELPER ASSET STORAGE INI:
    'file_path' => asset('storage/' . $path),
    
    'file_size' => $fileSizeFormatted,
    'uploaded_by' => 'client',
    'file_type' => $file->getClientOriginalExtension(),
]);

            return response()->json(['status' => 'success', 'data' => $newFile], 201);
        }

        return response()->json(['message' => 'File tidak valid.'], 400);
    }
}