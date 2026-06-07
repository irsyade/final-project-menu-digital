<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('promos', function (Blueprint $table) {
            if (!Schema::hasColumn('promos', 'bundling_items')) {
                $table->text('bundling_items')->nullable()->after('is_active');
            }
            if (!Schema::hasColumn('promos', 'free_item_name')) {
                $table->string('free_item_name')->nullable()->after('bundling_items');
            }
        });
    }

    public function down(): void
    {
        Schema::table('promos', function (Blueprint $table) {
            $cols = array_filter(['bundling_items', 'free_item_name'], fn($c) => Schema::hasColumn('promos', $c));
            if ($cols) $table->dropColumn(array_values($cols));
        });
    }
};
