<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            if (!Schema::hasColumn('settings', 'phone'))              $table->string('phone')->nullable();
            if (!Schema::hasColumn('settings', 'email'))              $table->string('email')->nullable();
            if (!Schema::hasColumn('settings', 'address'))            $table->text('address')->nullable();
            if (!Schema::hasColumn('settings', 'description'))        $table->text('description')->nullable();
            if (!Schema::hasColumn('settings', 'operational_hours'))  $table->json('operational_hours')->nullable();
            if (!Schema::hasColumn('settings', 'is_cash_active'))     $table->boolean('is_cash_active')->default(true);
            if (!Schema::hasColumn('settings', 'is_qris_active'))     $table->boolean('is_qris_active')->default(true);
            if (!Schema::hasColumn('settings', 'is_transfer_active')) $table->boolean('is_transfer_active')->default(false);
            if (!Schema::hasColumn('settings', 'quick_amounts'))      $table->json('quick_amounts')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            $cols = array_filter(
                ['phone', 'email', 'address', 'description', 'operational_hours',
                 'is_cash_active', 'is_qris_active', 'is_transfer_active', 'quick_amounts'],
                fn($c) => Schema::hasColumn('settings', $c)
            );
            if ($cols) $table->dropColumn(array_values($cols));
        });
    }
};
