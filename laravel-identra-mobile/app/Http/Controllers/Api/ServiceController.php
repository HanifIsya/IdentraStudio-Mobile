<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Service; // Pastikan nama Model Anda sesuai (Service atau Layanan)

class ServiceController extends Controller
{
    /**
     * Menyimpan layanan baru (Create)
     */
    public function store(Request $request)
    {
        // 1. Validasi Role: Pastikan hanya admin yang bisa menambah
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Akses ditolak. Anda bukan Admin.'], 403);
        }

        // 2. Validasi Input dari Flutter
        $request->validate([
            'nama_layanan' => 'required|string|max:255',
            'deskripsi'    => 'required|string',
        ]);

        // 3. Eksekusi simpan ke database
        $service = Service::create([
            'nama_layanan' => $request->nama_layanan,
            'deskripsi'    => $request->deskripsi,
        ]);

        return response()->json([
            'message' => 'Layanan berhasil ditambahkan',
            'data'    => $service
        ], 201);
    }

    /**
     * Memperbarui layanan (Update)
     */
    public function update(Request $request, $id)
    {
        // 1. Validasi Role
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Akses ditolak.'], 403);
        }

        // 2. Cari data berdasarkan ID
        $service = Service::find($id);

        if (!$service) {
            return response()->json(['message' => 'Layanan tidak ditemukan'], 404);
        }

        // 3. Validasi dan Update
        $request->validate([
            'nama_layanan' => 'required|string|max:255',
            'deskripsi'    => 'required|string',
        ]);

        $service->update([
            'nama_layanan' => $request->nama_layanan,
            'deskripsi'    => $request->deskripsi,
        ]);

        return response()->json([
            'message' => 'Layanan berhasil diperbarui',
            'data'    => $service
        ], 200);
    }

    /**
     * Menghapus layanan (Delete)
     */
    public function destroy(Request $request, $id)
    {
        // 1. Validasi Role
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Akses ditolak.'], 403);
        }

        // 2. Cari dan Hapus
        $service = Service::find($id);

        if (!$service) {
            return response()->json(['message' => 'Layanan tidak ditemukan'], 404);
        }

        $service->delete();

        return response()->json([
            'message' => 'Layanan berhasil dihapus'
        ], 200);
    }
}