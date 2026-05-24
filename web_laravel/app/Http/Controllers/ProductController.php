<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::with('category')->latest()->get();
        $categories = Category::all();
        return view('admin.products', compact('products', 'categories'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'cuisine' => 'nullable|string|max:100',
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'discount_percentage' => 'nullable|integer|min:0|max:100',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,svg,webp|max:2048',
            'image_url' => 'nullable|url',
            'tags' => 'nullable|string',
            'is_popular' => 'boolean',
            'is_available' => 'boolean',
        ]);

        $data['is_popular'] = $request->has('is_popular');
        $data['is_available'] = $request->has('is_available') || !$request->has('from_form'); 
        if ($request->filled('tags')) {
            $data['tags'] = array_map('trim', explode(',', $request->tags));
        } else {
            $data['tags'] = [];
        }

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('products', 'public');
        } elseif ($request->filled('image_url')) {
            $data['image'] = $request->input('image_url');
        }
        unset($data['image_url']);

        Product::create($data);
        return back()->with('success', 'Product created successfully!');
    }

    public function update(Request $request, Product $product)
    {
        $data = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'cuisine' => 'nullable|string|max:100',
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'discount_percentage' => 'nullable|integer|min:0|max:100',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,svg,webp|max:2048',
            'image_url' => 'nullable|url',
            'tags' => 'nullable|string',
            'is_popular' => 'boolean',
            'is_available' => 'boolean'
        ]);

        $data['is_popular'] = $request->has('is_popular');
        $data['is_available'] = $request->has('is_available');

        // Process tags: "Pedas, Manis" -> ["Pedas", "Manis"]
        if ($request->has('tags')) {
            $data['tags'] = $request->tags ? array_map('trim', explode(',', $request->tags)) : [];
        }

        if ($request->hasFile('image')) {
            if ($product->image && !str_starts_with($product->image, 'http')) Storage::disk('public')->delete($product->image);
            $data['image'] = $request->file('image')->store('products', 'public');
        } elseif ($request->filled('image_url')) {
            if ($product->image && !str_starts_with($product->image, 'http')) Storage::disk('public')->delete($product->image);
            $data['image'] = $request->input('image_url');
        }
        unset($data['image_url']);

        $product->update($data);
        return back()->with('success', 'Product updated successfully!');
    }

    public function toggleStatus(Product $product)
    {
        $product->update([
            'is_available' => !$product->is_available
        ]);
        
        if (request()->expectsJson()) {
            return response()->json(['success' => true, 'is_available' => $product->is_available]);
        }
        return back()->with('success', 'Availability status updated!');
    }

    public function destroy(Product $product)
    {
        if ($product->image && !str_starts_with($product->image, 'http')) Storage::disk('public')->delete($product->image);
        $product->delete();
        
        if (request()->expectsJson()) {
            return response()->json(['success' => true]);
        }
        return back()->with('success', 'Product deleted successfully!');
    }
}
