<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    use HasFactory;

    protected $fillable = [
        'project_id',
        'sender_id',
        'message',
        'attachment_url',
    ];

    /**
     * Relasi ke model User (Mengetahui siapa pengirim pesan ini)
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }
}