<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    // ─── Web admin views ─────────────────────────────────────────────────────

    public function branding()
    {
        $setting = Setting::firstOrCreate([]);
        return view('admin.branding', compact('setting'));
    }

    public function updateBranding(Request $request)
    {
        $setting = Setting::firstOrCreate([]);

        $data = $request->validate([
            'site_name'        => 'required|string|max:255',
            'owner_name'       => 'nullable|string|max:255',
            'address'          => 'nullable|string',
            'primary_color'    => 'required|string|max:20',
            'site_logo'        => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp|max:2048',
            'site_favicon'     => 'nullable|image|mimes:png,ico,svg|max:512',
            'login_background' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'qris_image'       => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'bank_name'        => 'nullable|string|max:255',
            'account_number'   => 'nullable|string|max:255',
            'account_name'     => 'nullable|string|max:255',
        ]);

        foreach (['site_logo', 'site_favicon', 'login_background', 'qris_image'] as $field) {
            if ($request->hasFile($field)) {
                if ($setting->$field) Storage::disk('public')->delete($setting->$field);
                $data[$field] = $request->file($field)->store('branding', 'public');
            }
        }

        $setting->fill($data)->save();
        return back()->with('success', 'Branding updated successfully!');
    }

    public function settings()
    {
        $setting = Setting::firstOrCreate([]);
        return view('admin.settings', compact('setting'));
    }

    public function updateSettings(Request $request)
    {
        $data = $request->validate([
            'site_name'        => 'required|string|max:255',
            'owner_name'       => 'nullable|string|max:255',
            'description'      => 'nullable|string',
            'address'          => 'nullable|string',
            'phone'            => 'nullable|string|max:20',
            'site_logo'        => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp|max:2048',
        ]);

        $setting = Setting::firstOrCreate([]);

        // Handle file upload
        if ($request->hasFile('site_logo')) {
            if ($setting->site_logo) {
                Storage::disk('public')->delete($setting->site_logo);
            }
            $data['site_logo'] = $request->file('site_logo')->store('branding', 'public');
        }

        $setting->fill($data)->save();
        return back()->with('success', 'Pengaturan berhasil disimpan!');
    }

    // ─── API endpoints (used by Flutter) ────────────────────────────────────

    public function apiSettings()
    {
        $setting = Setting::firstOrCreate([]);
        return response()->json([
            'success' => true,
            'data'    => $setting,
        ]);
    }

    public function apiUpdateSettings(Request $request)
    {
        try {
            // Always work with the first (and only) settings record
            $setting = Setting::firstOrCreate([]);
            $data    = [];

            // ── Profil Toko ─────────────────────────────────────────────────
            if ($request->has('name'))         $data['site_name']     = $request->input('name');
            if ($request->has('site_name'))    $data['site_name']     = $request->input('site_name');
            if ($request->has('owner_name'))   $data['owner_name']    = $request->input('owner_name');
            if ($request->has('account_name')) $data['account_name']  = $request->input('account_name');
            if ($request->has('address'))      $data['address']       = $request->input('address');
            if ($request->has('description'))  $data['description']   = $request->input('description');
            if ($request->has('email'))        $data['email']         = $request->input('email');
            if ($request->has('phone'))        $data['phone']         = $request->input('phone');

            // ── Tema & Warna ────────────────────────────────────────────────
            if ($request->has('color')) $data['primary_color'] = $request->input('color');
            if ($request->has('theme')) $data['theme']         = $request->input('theme');

            // ── Jam Operasional ─────────────────────────────────────────────
            if ($request->has('operational_hours')) {
                $hours = $request->input('operational_hours');
                $data['operational_hours'] = is_string($hours)
                    ? json_decode($hours, true)
                    : $hours;
            }

            // ── Metode Pembayaran ───────────────────────────────────────────
            if ($request->has('payment_methods')) {
                $pm = $request->input('payment_methods');
                if (is_string($pm)) $pm = json_decode($pm, true);
                if (is_array($pm)) {
                    // Accept bool, int(1/0), or string("true"/"1")
                    $data['is_qris_active']     = $this->toBool($pm['qris']     ?? null, $setting->is_qris_active);
                    $data['is_transfer_active'] = $this->toBool($pm['transfer'] ?? null, $setting->is_transfer_active);
                    $data['is_cash_active']     = $this->toBool($pm['cash']     ?? null, $setting->is_cash_active);
                }
            }

            // ── Transfer / Bank ─────────────────────────────────────────────
            if ($request->has('bank_name'))       $data['bank_name']       = $request->input('bank_name');
            if ($request->has('account_number'))  $data['account_number']  = $request->input('account_number');

            // ── File uploads ────────────────────────────────────────────────
            if ($request->hasFile('site_logo')) {
                if ($setting->site_logo) Storage::disk('public')->delete($setting->site_logo);
                $data['site_logo'] = $request->file('site_logo')->store('branding', 'public');
            }

            if ($request->hasFile('qris_image')) {
                if ($setting->qris_image) Storage::disk('public')->delete($setting->qris_image);
                $data['qris_image'] = $request->file('qris_image')->store('branding', 'public');
            }

            if (empty($data)) {
                // Nothing to update — return current settings as success
                return response()->json(['success' => true, 'data' => $setting]);
            }

            $setting->fill($data)->save();
            $setting->refresh();

            return response()->json([
                'success' => true,
                'data'    => $setting,
            ]);
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::error('apiUpdateSettings error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan pengaturan: ' . $e->getMessage(),
            ], 500);
        }
    }

    // ─── Helper ──────────────────────────────────────────────────────────────

    private function toBool(mixed $value, bool $default = false): bool
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
