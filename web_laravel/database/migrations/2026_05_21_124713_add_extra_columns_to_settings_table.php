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
        Schema::table('settings', function (Blueprint $table) {
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->text('address')->nullable();
            $table->text('description')->nullable();
            $table->json('operational_hours')->nullable();
            $table->boolean('is_cash_active')->default(true);
            $table->boolean('is_qris_active')->default(true);
            $table->boolean('is_transfer_active')->default(false);
            $table->json('quick_amounts')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            $table->dropColumn([
                'phone',
                'email',
                'address',
                'description',
                'operational_hours',
                'is_cash_active',
                'is_qris_active',
                'is_transfer_active',
                'quick_amounts',
            ]);
        });
    }
};
