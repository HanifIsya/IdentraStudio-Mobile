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

    /**
     * Relasi ke model Message (Satu project memiliki banyak pesan chat)
     */
    public function messages()
    {
        return $this->hasMany(Message::class, 'project_id');
    }

    /**
     * Relasi ke model ProjectFile (Satu project memiliki banyak berkas/aset)
     */
    public function files()
    {
        return $this->hasMany(ProjectFile::class, 'project_id');
    }
}