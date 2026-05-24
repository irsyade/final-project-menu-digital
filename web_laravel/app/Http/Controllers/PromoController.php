<?php

namespace App\Http\Controllers;

use App\Models\Promo;
use Illuminate\Http\Request;

class PromoController extends Controller
{
    public function index()
    {
        $promos = Promo::latest()->get();
        return view('admin.promos.index', compact('promos'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|unique:promos,code',
            'type' => 'required|string|in:percentage,fixed',
            'description' => 'nullable|string',
            'promo_type' => 'required|string|in:diskon,bundling,free_item',
            'value' => 'required|numeric|min:0',
            'min_purchase' => 'nullable|numeric|min:0',
            'quota' => 'nullable|integer|min:1',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'is_banner' => 'boolean',
            'is_active' => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');
        $data['is_banner'] = $request->has('is_banner');
        $data['min_purchase'] = $data['min_purchase'] ?? 0;

        if ($request->hasFile('image')) {
            $imageName = time() . '.' . $request->image->extension();
            $request->image->move(public_path('storage/promos'), $imageName);
            $data['image'] = $imageName;
        }

        Promo::create($data);

        return back()->with('success', 'Promo added successfully!');
    }

    public function update(Request $request, Promo $promo)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|unique:promos,code,' . $promo->id,
            'type' => 'required|string|in:percentage,fixed',
            'description' => 'nullable|string',
            'promo_type' => 'required|string|in:diskon,bundling,free_item',
            'value' => 'required|numeric|min:0',
            'min_purchase' => 'nullable|numeric|min:0',
            'quota' => 'nullable|integer|min:1',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'is_banner' => 'boolean',
            'is_active' => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');
        $data['is_banner'] = $request->has('is_banner');
        $data['min_purchase'] = $data['min_purchase'] ?? 0;

        if ($request->hasFile('image')) {
            if ($promo->image && file_exists(public_path('storage/promos/' . $promo->image))) {
                unlink(public_path('storage/promos/' . $promo->image));
            }
            $imageName = time() . '.' . $request->image->extension();
            $request->image->move(public_path('storage/promos'), $imageName);
            $data['image'] = $imageName;
        }

        $promo->update($data);

        return back()->with('success', 'Promo updated successfully!');
    }

    public function toggleStatus(Promo $promo)
    {
        $promo->update(['is_active' => !$promo->is_active]);
        
        if (request()->expectsJson()) {
            return response()->json(['success' => true, 'is_active' => $promo->is_active]);
        }
        return back()->with('success', 'Promo status updated!');
    }

    public function destroy(Promo $promo)
    {
        $promo->delete();
        if (request()->expectsJson()) {
            return response()->json(['success' => true]);
        }
        return back()->with('success', 'Promo removed successfully!');
    }
}
