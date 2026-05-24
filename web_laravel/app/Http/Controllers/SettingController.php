<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    public function branding()
    {
        $setting = Setting::first() ?? new Setting();
        return view('admin.branding', compact('setting'));
    }

    public function updateBranding(Request $request)
    {
        $setting = Setting::first() ?? new Setting();
        
        $data = $request->validate([
            'site_name' => 'required|string|max:255',
            'primary_color' => 'required|string|max:20',
            'site_logo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp|max:2048',
            'site_favicon' => 'nullable|image|mimes:png,ico,svg|max:512',
            'login_background' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'qris_image' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'bank_name' => 'nullable|string|max:255',
            'account_number' => 'nullable|string|max:255',
            'account_name' => 'nullable|string|max:255',
        ]);

        if ($request->hasFile('site_logo')) {
            if ($setting->site_logo) Storage::disk('public')->delete($setting->site_logo);
            $data['site_logo'] = $request->file('site_logo')->store('branding', 'public');
        }

        if ($request->hasFile('site_favicon')) {
            if ($setting->site_favicon) Storage::disk('public')->delete($setting->site_favicon);
            $data['site_favicon'] = $request->file('site_favicon')->store('branding', 'public');
        }

        if ($request->hasFile('login_background')) {
            if ($setting->login_background) Storage::disk('public')->delete($setting->login_background);
            $data['login_background'] = $request->file('login_background')->store('branding', 'public');
        }

        if ($request->hasFile('qris_image')) {
            if ($setting->qris_image) Storage::disk('public')->delete($setting->qris_image);
            $data['qris_image'] = $request->file('qris_image')->store('branding', 'public');
        }

        $setting->fill($data)->save();

        return back()->with('success', 'Branding updated successfully!');
    }

    public function settings()
    {
        $setting = Setting::first() ?? new Setting();
        return view('admin.settings', compact('setting'));
    }

    public function updateSettings(Request $request)
    {
        // Add general settings logic here if needed
        return back()->with('success', 'Settings updated successfully!');
    }
}
