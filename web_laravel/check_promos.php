<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Promo;

$promos = Promo::all();
echo "Total Promos in DB: " . $promos->count() . "\n";
foreach($promos as $p) {
    echo "ID: {$p->id} | Name: {$p->name} | Active: {$p->is_active} | Start: {$p->start_date} | End: {$p->end_date} | Used: {$p->used} | Quota: {$p->quota}\n";
}
