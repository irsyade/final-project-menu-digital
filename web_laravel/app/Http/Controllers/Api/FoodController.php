<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    public function categories()
    {
        return response()->json(Category::all());
    }

    public function products(Request $request)
    {
        $query = Product::with('category');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('q')) {
            $query->where('name', 'like', '%' . $request->q . '%');
        }

        return response()->json($query->get());
    }

    public function popular()
    {
        return response()->json(Product::where('is_popular', true)->get());
    }
}
