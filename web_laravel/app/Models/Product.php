<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = ['category_id', 
    'cuisine', 'name', 'description', 
    'tags', 'price', 'discount_percentage', 
    'image', 'is_popular', 'is_available'];

    protected $casts = [
        'tags' => 'array',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
