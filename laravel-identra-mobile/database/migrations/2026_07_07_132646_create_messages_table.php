<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up(): void
{
    Schema::create('messages', function (Blueprint $table) {
        $table->id();
        $table->foreignId('project_id')->constrained()->onDelete('cascade'); // Terikat ke project spesifik
        $table->foreignId('sender_id')->constrained('users')->onDelete('cascade'); // Siapa yang kirim (User/Admin)
        $table->text('message');
        $table->string('attachment_url')->nullable(); // Jika ada kirim file/gambar di chat
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
