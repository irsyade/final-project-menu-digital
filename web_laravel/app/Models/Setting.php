<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $fillable = [
        'site_name', 
        'site_logo', 
        'site_favicon', 
        'login_background', 
        'primary_color',
        'qris_image',
        'bank_name',
        'account_number',
        'account_name',
        'phone',
        'email',
        'address',
        'description',
        'operational_hours',
        'is_cash_active',
        'is_qris_active',
        'is_transfer_active',
        'quick_amounts'
    ];

    protected $casts = [
        'operational_hours' => 'array',
        'quick_amounts' => 'array',
        'is_cash_active' => 'boolean',
        'is_qris_active' => 'boolean',
        'is_transfer_active' => 'boolean',
    ];
}
