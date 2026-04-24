<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;

    // Tambahkan baris sakti ini:
    protected $fillable = [
        'nama_layanan',
        'deskripsi',
    ];
}