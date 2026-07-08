<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Invoice {{ $invoice_id }}</title>
    <style>
        body { font-family: sans-serif; color: #333; margin: 0; padding: 20px; }
        .header { border-bottom: 2px solid #D4AF37; padding-bottom: 20px; margin-bottom: 20px; }
        .logo { font-size: 24px; font-weight: bold; color: #000; letter-spacing: 2px; }
        .status { float: right; background: #28a745; color: #fff; padding: 5px 15px; border-radius: 4px; font-weight: bold; font-size: 12px; }
        .info-table { width: 100%; margin-bottom: 30px; }
        .info-table td { vertical-align: top; }
        .items-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .items-table th { background: #1a1a1a; color: #fff; text-align: left; padding: 10px; font-size: 12px; }
        .items-table td { border-bottom: 1px solid #ddd; padding: 10px; font-size: 13px; }
        .footer { margin-top: 50px; text-align: center; color: #777; font-size: 11px; border-top: 1px solid #eee; padding-top: 15px; }
    </style>
</head>
<body>
    <div class="header">
        <span class="status">PAID / LUNAS</span>
        <div class="logo">IDENTRA STUDIO</div>
        <p style="font-size: 12px; color: #666; margin: 5px 0 0 0;">Official Digital Agency Invoice</p>
    </div>

    <table class="info-table">
        <tr>
            <td>
                <strong>Diterbitkan Untuk:</strong><br>
                {{ $user->name }}<br>
                {{ $user->email }}
            </td>
            <td style="text-align: right;">
                <strong>Nomor Invoice:</strong><br>
                {{ $invoice_id }}<br><br>
                <strong>Tanggal Transaksi:</strong><br>
                {{ $tanggal }}
            </td>
        </tr>
    </table>

    <table class="items-table">
        <thead>
            <tr>
                <th>NO</th>
                <th>DESKRIPSI LAYANAN / PRODUK</th>
                <th style="text-align: right;">STATUS WORKSPACE</th>
            </tr>
        </thead>
        <tbody>
            @foreach($projects as $index => $project)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td><strong>{{ $project->service->nama_layanan ?? 'Layanan Digital' }}</strong></td>
                <td style="text-align: right; color: #28a745; font-weight: bold;">ACTIVE ROOM</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="footer">
        Terima kasih telah mempercayakan project Anda kepada IdentraStudio.<br>
        Dokumen ini dibuat secara otomatis dan sah tanpa tanda tangan basah.
    </div>
</body>
</html>