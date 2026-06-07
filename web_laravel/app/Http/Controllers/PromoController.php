<?php

namespace App\Http\Controllers;

use App\Models\Promo;
use Illuminate\Http\Request;

class PromoController extends Controller
{
    public function index()
    {
        $promos = Promo::latest()->get();

        if (request()->expectsJson() || request()->is('api/*')) {
            return response()->json($promos);
        }

        return view('admin.promos.index', compact('promos'));
    }

    public function store(Request $request)
    {
        // Base validation rules
        $rules = [
            'name'            => 'required|string|max:255',
            'code'            => 'required|string|unique:promos,code',
            'type'            => 'required|string|in:percentage,fixed',
            'description'     => 'nullable|string',
            'promo_type'      => 'required|string|in:diskon,bundling',
            'min_purchase'    => 'nullable|numeric|min:0',
            'quota'           => 'nullable|integer|min:1',
            'start_date'      => 'nullable|date',
            'end_date'        => 'nullable|date',
            'image'           => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'is_banner'       => 'nullable',
            'is_active'       => 'nullable',
            'bundling_items'  => 'nullable|string',
        ];

        // Dynamic validation based on promo type
        if ($request->input('promo_type') === 'bundling') {
            $rules['value'] = 'required|numeric|min:0';
            $rules['bundling_items'] = 'required|string';
        } else {
            // For 'diskon' type
            $rules['value'] = 'required|numeric|min:0';
        }

        $data = $request->validate($rules);

        // Accept boolean from JSON (true/false), int (1/0), or string ("1"/"0")
        $data['is_active']    = $this->parseBool($request->input('is_active'), true);
        $data['is_banner']    = $this->parseBool($request->input('is_banner'), false);
        $data['min_purchase'] = $data['min_purchase'] ?? 0;

        if ($request->hasFile('image')) {
            $imageName = time() . '.' . $request->image->extension();
            $dir = public_path('storage/promos');
            if (!is_dir($dir)) mkdir($dir, 0755, true);
            $request->image->move($dir, $imageName);
            $data['image'] = 'promos/' . $imageName;
        }

        $promo = Promo::create($data);

        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json(['success' => true, 'data' => $promo], 201);
        }

        return back()->with('success', 'Promo added successfully!');
    }

    public function update(Request $request, Promo $promo)
    {
        // Base validation rules
        $rules = [
            'name'            => 'required|string|max:255',
            'code'            => 'required|string|unique:promos,code,' . $promo->id,
            'type'            => 'required|string|in:percentage,fixed',
            'description'     => 'nullable|string',
            'promo_type'      => 'required|string|in:diskon,bundling',
            'min_purchase'    => 'nullable|numeric|min:0',
            'quota'           => 'nullable|integer|min:1',
            'start_date'      => 'nullable|date',
            'end_date'        => 'nullable|date',
            'image'           => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'is_banner'       => 'nullable',
            'is_active'       => 'nullable',
            'bundling_items'  => 'nullable|string',
        ];

        // Dynamic validation based on promo type  
        if ($request->input('promo_type') === 'bundling') {
            $rules['value'] = 'required|numeric|min:0';
            $rules['bundling_items'] = 'required|string';
        } else {
            // For 'diskon' type
            $rules['value'] = 'required|numeric|min:0';
        }

        $data = $request->validate($rules);

        $data['is_active']    = $this->parseBool($request->input('is_active'), $promo->is_active);
        $data['is_banner']    = $this->parseBool($request->input('is_banner'), $promo->is_banner);
        $data['min_purchase'] = $data['min_purchase'] ?? 0;

        if ($request->hasFile('image')) {
            // Delete old image
            if ($promo->image && file_exists(public_path('storage/' . $promo->image))) {
                @unlink(public_path('storage/' . $promo->image));
            }
            $imageName = time() . '.' . $request->image->extension();
            $dir = public_path('storage/promos');
            if (!is_dir($dir)) mkdir($dir, 0755, true);
            $request->image->move($dir, $imageName);
            $data['image'] = 'promos/' . $imageName;
        }

        $promo->update($data);

        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json(['success' => true, 'data' => $promo->fresh()]);
        }

        return back()->with('success', 'Promo updated successfully!');
    }

    public function toggleStatus(Promo $promo)
    {
        $promo->update(['is_active' => !$promo->is_active]);

        if (request()->expectsJson() || request()->is('api/*')) {
            return response()->json(['success' => true, 'is_active' => $promo->is_active]);
        }

        return back()->with('success', 'Promo status updated!');
    }

    public function destroy(Promo $promo)
    {
        if ($promo->image && file_exists(public_path('storage/' . $promo->image))) {
            @unlink(public_path('storage/' . $promo->image));
        }

        $promo->delete();

        if (request()->expectsJson() || request()->is('api/*')) {
            return response()->json(['success' => true]);
        }

        return back()->with('success', 'Promo removed successfully!');
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    /**
     * Parse boolean from any source: PHP bool, JSON int (1/0), string ("1"/"true"/"false").
     */
    private function parseBool(mixed $value, bool $default = false): bool
    {
        if ($value === null) return $default;
        if (is_bool($value)) return $value;
        if (is_int($value)) return $value !== 0;
        if (is_string($value)) {
            return in_array(strtolower($value), ['1', 'true', 'yes'], true);
        }
        return $default;
    }
}
