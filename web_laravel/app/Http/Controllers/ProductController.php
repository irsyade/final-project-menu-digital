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
            'category_id'          => 'required|exists:categories,id',
            'cuisine'              => 'nullable|string|max:100',
            'name'                 => 'required|string|max:255',
            'description'          => 'nullable|string',
            'price'                => 'required|numeric|min:0',
            'discount_percentage'  => 'nullable|integer|min:0|max:100',
            'image'                => 'nullable|image|mimes:jpeg,png,jpg,svg,webp|max:2048',
            'image_url'            => 'nullable|url',
            'tags'                 => 'nullable',
            'is_popular'           => 'nullable',
            'is_available'         => 'nullable',
        ]);

        // Accept bool, int(1/0), string("1"/"true") from both JSON and form data
        $data['is_popular']  = $this->parseBool($request->input('is_popular'), false);
        $data['is_available'] = $this->parseBool($request->input('is_available'), true);

        // Convert tags string "Gurih,Pedas" → array ["Gurih","Pedas"]
        $tags = $request->input('tags');
        if (is_array($tags)) {
            $data['tags'] = $tags;
        } elseif (is_string($tags) && trim($tags) !== '') {
            $data['tags'] = array_map('trim', explode(',', $tags));
        } else {
            $data['tags'] = [];
        }

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('products', 'public');
        } elseif ($request->filled('image_url')) {
            $data['image'] = $request->input('image_url');
        }
        unset($data['image_url']);

        $product = Product::create($data);

        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'message' => 'Product created successfully!',
                'product' => $product->load('category'),
            ]);
        }

        return back()->with('success', 'Product created successfully!');
    }

    public function update(Request $request, Product $product)
    {
        $data = $request->validate([
            'category_id'         => 'required|exists:categories,id',
            'cuisine'             => 'nullable|string|max:100',
            'name'                => 'required|string|max:255',
            'description'         => 'nullable|string',
            'price'               => 'required|numeric|min:0',
            'discount_percentage' => 'nullable|integer|min:0|max:100',
            'image'               => 'nullable|image|mimes:jpeg,png,jpg,svg,webp|max:2048',
            'image_url'           => 'nullable|url',
            'tags'                => 'nullable',
            'is_popular'          => 'nullable',
            'is_available'        => 'nullable',
        ]);

        $data['is_popular']  = $this->parseBool($request->input('is_popular'), $product->is_popular);
        $data['is_available'] = $this->parseBool($request->input('is_available'), $product->is_available);

        $tags = $request->input('tags');
        if (is_array($tags)) {
            $data['tags'] = $tags;
        } elseif (is_string($tags) && trim($tags) !== '') {
            $data['tags'] = array_map('trim', explode(',', $tags));
        }

        if ($request->hasFile('image')) {
            if ($product->image && !str_starts_with($product->image, 'http')) {
                Storage::disk('public')->delete($product->image);
            }
            $data['image'] = $request->file('image')->store('products', 'public');
        } elseif ($request->filled('image_url')) {
            if ($product->image && !str_starts_with($product->image, 'http')) {
                Storage::disk('public')->delete($product->image);
            }
            $data['image'] = $request->input('image_url');
        }
        unset($data['image_url']);

        $product->update($data);

        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'message' => 'Product updated successfully!',
                'product' => $product->fresh()->load('category'),
            ]);
        }

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

    // ─── Helper ───────────────────────────────────────────────────────────────

    private function parseBool(mixed $value, bool $default = false): bool
    {
        if ($value === null)  return $default;
        if (is_bool($value))  return $value;
        if (is_int($value))   return $value !== 0;
        if (is_string($value)) {
            return in_array(strtolower($value), ['1', 'true', 'yes'], true);
        }
        return $default;
    }
}
