<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Promo extends Model
{
    protected $fillable = [
        'name', 'description', 'code', 'type',
         'promo_type', 'value', 'min_purchase',
          'quota', 'used', 'start_date', 
          'end_date', 'image', 'is_banner', 
          'is_active', 'bundling_items'
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'is_active' => 'boolean',
    ];
}
