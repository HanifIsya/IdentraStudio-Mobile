<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB; // Import DB facade

class ServiceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
      DB::table('services')->insert([
            [
                'nama_layanan' => 'Website Design',
                'deskripsi' => 'Create your own website with our expert design services.',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_layanan' => 'Logo Creation',
                'deskripsi' => 'Design your perfect logo with our professional designers.',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_layanan' => 'App Development',
                'deskripsi' => 'Develop your mobile app with our experienced developers.',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_layanan' => 'Graphic Design',
                'deskripsi' => 'Create stunning graphics for your brand and marketing materials.',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_layanan' => 'Film Production',
                'deskripsi' => 'Produce short films and corporate videos with our expert team.',
                'created_at' => now(),
                'updated_at' => now(),
            ],
           
        ]);
    }
}
