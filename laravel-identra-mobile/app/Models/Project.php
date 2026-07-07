<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'service_id',
        'external_id',
        'status',
        'progress_percent',
    ];

    /**
     * Relasi ke model Service (Satu project memiliki satu Layanan)
     */
    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    /**
     * Relasi ke model User (Satu project dimiliki oleh satu User)
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}