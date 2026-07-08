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
        $request->validate([
            'nama_layanan' => 'required|string',
            'deskripsi'    => 'required|string',
            'harga'        => 'required|numeric',
        ]);

        $service = Service::create([
            'nama_layanan' => $request->nama_layanan,
            'deskripsi'    => $request->deskripsi,
            'harga'        => $request->harga,
        ]);

        return response()->json(['status' => 'success', 'data' => $service], 201);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_layanan' => 'required|string',
            'deskripsi'    => 'required|string',
            'harga'        => 'required|numeric',
        ]);

        $service = Service::find($id);
        if (!$service) {
            return response()->json(['message' => 'Layanan tidak ditemukan'], 404);
        }

        $service->update([
            'nama_layanan' => $request->nama_layanan,
            'deskripsi'    => $request->deskripsi,
            'harga'        => $request->harga,
        ]);

        return response()->json(['status' => 'success', 'data' => $service], 200);
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