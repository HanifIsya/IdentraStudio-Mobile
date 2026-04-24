<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Chat;
use App\Models\Order;
use App\Models\Offer;
use App\Models\Transaction;
use App\Models\User;

class DashboardSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Ambil User pertama (Hanif) sebagai pemilik data
        // Jika belum ada user, seeder ini akan berhenti agar tidak error
        $user = User::first();

        if (!$user) {
            $this->command->info('Eits! Belum ada User di database. Register dulu di Flutter atau buat User manual!');
            return;
        }

        // 2. Data Chat (Maria Lopez)
        Chat::create([
            'user_id'       => $user->id,
            'sender_name'   => 'Maria Lopez',
            'last_message'  => 'I have one revision request',
            'status'        => 'open',
        ]);

        // 3. Data Order Service (Motion Graphics & Digital Services)
        Order::create([
            'user_id' => $user->id,
            'title'   => 'Motion Graphics',
            'price'   => 250,
            'status'  => 'active',
        ]);

        Order::create([
            'user_id' => $user->id,
            'title'   => 'Digital Services',
            'price'   => 150,
            'status'  => 'active',
        ]);

        // 4. Data Best Offers (Premium Pack Film Production)
        // Note: Offer biasanya bersifat global/umum
        Offer::create([
            'title'          => 'Premium Pack',
            'category'       => 'Film Production',
            'original_price' => 123,
            'discount_price' => 99,
        ]);

        // 5. Data Transaction History (#INV-2026)
        Transaction::create([
            'user_id'        => $user->id,
            'invoice_number' => '#INV-2026',
            'title'          => 'Motion Graphics',
            'amount'         => 250,
        ]);

        $this->command->info('Mantap! Data dummy Identra Studio berhasil disuntikkan.');
    }
}