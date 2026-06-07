<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * This migration is a no-op guard.
     * The 'address' column was already added by 2026_05_21_124713_add_extra_columns_to_settings_table.php.
     * This file exists only to prevent migration errors on servers where it was partially run.
     */
    public function up(): void
    {
        // Guard: only add if not already present (prevents duplicate column error)
        if (!Schema::hasColumn('settings', 'address')) {
            Schema::table('settings', function (Blueprint $table) {
                $table->text('address')->nullable()->after('site_name');
            });
        }
    }

    public function down(): void
    {
        // Do nothing — column ownership belongs to the earlier migration
    }
};
