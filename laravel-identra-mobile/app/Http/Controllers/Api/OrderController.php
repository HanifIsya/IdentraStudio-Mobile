<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\Project; // Pastikan Anda sudah membuat Model Project (\App\Models\Project)
use Illuminate\Support\Facades\Auth;
use Xendit\Configuration;
use Xendit\Invoice\InvoiceApi;
use Xendit\Invoice\CreateInvoiceRequest;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        // 1. Validasi input dari Flutter
        $request->validate([
            'service_ids' => 'required|array',
            'service_ids.*' => 'exists:services,id'
        ]);

        $user = Auth::user();
        $serviceIds = $request->input('service_ids');

        // 2. Hitung total harga dari database
        $totalHarga = Service::whereIn('id', $serviceIds)->sum('harga');

        if ($totalHarga <= 0) {
            return response()->json(['message' => 'Total nominal transaksi tidak valid.'], 400);
        }

        // 3. Generate Nomor Invoice Unik
        $externalId = 'INV-' . time() . '-' . $user->id;

        // 4. Konfigurasi SDK Xendit menggunakan Secret Key dari file .env
        Configuration::setXenditKey(env('XENDIT_SECRET_KEY'));
        $apiInstance = new InvoiceApi();

        // 5. Susun data payload invoice untuk dikirim ke API Xendit
        $createInvoiceRequest = new CreateInvoiceRequest([
            'external_id' => $externalId,
            'amount' => (double) $totalHarga,
            'payer_email' => $user->email,
            'description' => 'Pembayaran Layanan Identra Studio oleh ' . $user->name,
            'invoice_duration' => 86400, // Aktif selama 24 jam (dalam hitungan detik)
            'currency' => 'IDR',
            
            // Callback otomatis saat pelanggan selesai membayar (Kembali ke aplikasi mobile)
            'success_redirect_url' => 'identra://checkout-success', 
            'failure_redirect_url' => 'identra://checkout-success',
        ]);

        try {
            // 6. Kirim request ke server Xendit untuk membuat Invoice resmi
            $result = $apiInstance->createInvoice($createInvoiceRequest);

            // 7. KUNCI MULTI-ROOM: Otomatis daftarkan ruang project & workspace chat terpisah per item layanan
            foreach ($serviceIds as $id) {
                Project::create([
                    'user_id' => $user->id,
                    'service_id' => $id,
                    'external_id' => $result['external_id'],
                    'status' => 'briefing',
                    'progress_percent' => 0,
                ]);
            }

            // 8. Kembalikan response URL Invoice resmi dari Xendit ke Flutter
            return response()->json([
                'status' => 'success',
                'message' => 'Invoice Xendit & Ruang Project berhasil dibuat.',
                'external_id' => $result['external_id'],
                'total_amount' => $result['amount'],
                'invoice_url' => $result['invoice_url']
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal terhubung ke Xendit Gateway: ' . $e->getMessage()
            ], 500);
        }
    }
}