<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Tambah kolom user_id HANYA JIKA kolomnya belum ada
        if (!Schema::hasColumn('messages', 'user_id')) {
            Schema::table('messages', function (Blueprint $table) {
                $table->unsignedBigInteger('user_id')->nullable()->after('project_id');
            });
        }

        // 2. Isi data user_id untuk pesan lama jika masih NULL
        $firstUserId = DB::table('users')->value('id');
        if ($firstUserId) {
            DB::table('messages')->whereNull('user_id')->update(['user_id' => $firstUserId]);
        }

        // 3. Pasang Foreign Key constraint (dibalut try-catch agar tidak crash jika sudah terpasang)
        try {
            Schema::table('messages', function (Blueprint $table) {
                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        } catch (\Exception $e) {
            // Abaikan jika foreign key sudah ada
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            if (Schema::hasColumn('messages', 'user_id')) {
                $table->dropForeign(['user_id']);
                $table->dropColumn('user_id');
            }
        });
    }
};