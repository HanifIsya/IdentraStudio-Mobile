<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;
use Illuminate\Support\Facades\Auth;

class ProjectController extends Controller
{
    /**
     * Mengambil daftar project milik user yang sedang login
     */
    public function index()
    {
        $user = Auth::user();

        // Mengambil project milik user + load data relation dari tabel services
        $projects = Project::with('service')
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $projects
        ], 200);
    }
}