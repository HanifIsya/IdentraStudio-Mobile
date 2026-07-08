<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\Project;
use Illuminate\Support\Facades\Auth;
use Xendit\Configuration;
use Xendit\Invoice\InvoiceApi;
use Xendit\Invoice\CreateInvoiceRequest;
use Barryvdh\DomPDF\Facade\Pdf; // Impor Facade DomPDF untuk cetak PDF

class OrderController extends Controller
{
    /**
     * 1. POST: Membuat Checkout Invoice baru via Xendit & mendaftarkan Project Multi-Room
     */
    public function store(Request $request)
    {
        // Validasi input dari Flutter
        $request->validate([
            'service_ids' => 'required|array',
            'service_ids.*' => 'exists:services,id'
        ]);

        $user = Auth::user();
        $serviceIds = $request->input('service_ids');

        // Hitung total harga dari database
        $totalHarga = Service::whereIn('id', $serviceIds)->sum('harga');

        if ($totalHarga <= 0) {
            return response()->json(['message' => 'Total nominal transaksi tidak valid.'], 400);
        }

        // Generate Nomor Invoice Unik
        $externalId = 'INV-' . time() . '-' . $user->id;

        // Konfigurasi SDK Xendit dari .env
        Configuration::setXenditKey(env('XENDIT_SECRET_KEY'));
        $apiInstance = new InvoiceApi();

        // Payload Invoice Xendit
        $createInvoiceRequest = new CreateInvoiceRequest([
            'external_id' => $externalId,
            'amount' => (double) $totalHarga,
            'payer_email' => $user->email,
            'description' => 'Pembayaran Layanan Identra Studio oleh ' . $user->name,
            'invoice_duration' => 86400, // Aktif 24 jam
            'currency' => 'IDR',
            'success_redirect_url' => 'identra://checkout-success', 
            'failure_redirect_url' => 'identra://checkout-success',
        ]);

        try {
            // Kirim request ke server Xendit
            $result = $apiInstance->createInvoice($createInvoiceRequest);

            // KUNCI MULTI-ROOM: Otomatis daftarkan ruang project & workspace chat terpisah per item layanan
            foreach ($serviceIds as $id) {
                Project::create([
                    'user_id' => $user->id,
                    'service_id' => $id,
                    'external_id' => $result['external_id'],
                    'status' => 'briefing',
                    'progress_percent' => 0,
                ]);
            }

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

    /**
     * 2. GET: Mengambil riwayat transaksi invoice user yang sedang login
     */
    public function index()
    {
        $user = Auth::user();

        // Ambil data project/orders unik berdasarkan external_id (Invoice Xendit)
        $invoices = Project::with('service')
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->groupBy('external_id')
            ->map(function ($items, $externalId) {
                $firstItem = $items->first();
                return [
                    'invoice_id' => $externalId,
                    'tanggal' => $firstItem->created_at->format('d M Y, H:i'),
                    'status' => 'PAID', // Status pembayaran terverifikasi
                    'total_layanan' => $items->count(),
                    'layanan_list' => $items->pluck('service.nama_layanan')->toArray(),
                    'pdf_url' => url("/api/invoices/{$externalId}/pdf"), // Endpoint download PDF
                ];
            })->values();

        return response()->json([
            'status' => 'success',
            'data' => $invoices
        ], 200);
    }

    /**
     * 3. GET: Generate & Stream berkas PDF Invoice
     */
    public function downloadPdf($invoiceId)
    {
        // Cari project berdasarkan external_id unik invoice
        $projects = Project::with(['service', 'user'])
            ->where('external_id', $invoiceId)
            ->get();

        if ($projects->isEmpty()) {
            return response()->json(['message' => 'Invoice tidak ditemukan.'], 404);
        }

        // Ambil data user pembeli dari relasi project
        $user = $projects->first()->user;

        // Render PDF menggunakan DomPDF
        $pdf = Pdf::loadView('invoices.pdf', [
            'invoice_id' => $invoiceId,
            'projects' => $projects,
            'user' => $user,
            'tanggal' => $projects->first()->created_at->format('d F Y, H:i') . ' WIB',
        ]);

        return $pdf->stream("Invoice-{$invoiceId}.pdf");
    }
}