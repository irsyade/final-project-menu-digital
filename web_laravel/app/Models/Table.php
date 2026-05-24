<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Table extends Model
{
    protected $fillable = ['number', 'name', 
    'type', 'capacity', 'status', 'customer_name',
     'is_active'];
}
