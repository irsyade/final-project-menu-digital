<?php

namespace App\Livewire\Admin;

use Livewire\Component;
use Livewire\WithFileUploads;
use App\Models\Setting;
use Illuminate\Support\Facades\Storage;

class SettingsManagement extends Component
{
    use WithFileUploads;

    public $activeTab = 'informasi'; // informasi, operasional, pembayaran, tema

    // Model setting
    public $setting;

    // Tab 1: Informasi Restoran
    public $site_name;
    public $owner_name;
    public $phone;
    public $email;
    public $address;
    public $description;
    public $new_logo;
    public $new_favicon;
    public $new_login_background;

    // Tab 2: Jam Operasional
    public $operational_hours = [];

    // Tab 3: Pembayaran
    public $is_cash_active = true;
    public $is_qris_active = true;
    public $is_transfer_active = false;
    public $bank_name;
    public $account_number;
    public $account_name;
    public $new_qris_image;
    public $quick_amounts = [];

    // Tab 4: Tema & warna Menu
    public $primary_color = '#E8781A';

    protected $rules = [
        'site_name' => 'required|string|max:255',
        'owner_name' => 'nullable|string|max:255',
        'phone' => 'nullable|string|max:50',
        'email' => 'nullable|email|max:100',
        'address' => 'nullable|string',
        'description' => 'nullable|string|max:500',
        'new_logo' => 'nullable|image|max:2048',
        'new_favicon' => 'nullable|image|max:512',
        'new_login_background' => 'nullable|image|max:5120',
        'primary_color' => 'required|string|max:20',
        'bank_name' => 'nullable|string|max:255',
        'account_number' => 'nullable|string|max:255',
        'account_name' => 'nullable|string|max:255',
        'new_qris_image' => 'nullable|image|max:2048',
        'operational_hours.*.open' => 'nullable|string',
        'operational_hours.*.close' => 'nullable|string',
        'operational_hours.*.is_closed' => 'boolean',
        'quick_amounts.0' => 'required|integer|min:0',
        'quick_amounts.1' => 'required|integer|min:0',
        'quick_amounts.2' => 'required|integer|min:0',
        'quick_amounts.3' => 'required|integer|min:0',
    ];

    public function mount()
    {
        $this->setting = Setting::first() ?? new Setting();

        // Tab 1
        $this->site_name = $this->setting->site_name ?? 'Warung MenuKu';
        $this->owner_name = $this->setting->owner_name ?? 'Pemilik Restoran';
        $this->phone = $this->setting->phone ?? '021-7234567';
        $this->email = $this->setting->email ?? 'admin@menuku.id';
        $this->address = $this->setting->address ?? 'Jl. Digital Raya No. 404, Jakarta Selatan';
        $this->description = $this->setting->description ?? 'Sajian lezat dengan pelayanan digital tercepat.';

        // Tab 2
        $defaultHours = [
            ['day' => 'Senin', 'open' => '09:00', 'close' => '22:00', 'is_closed' => false],
            ['day' => 'Selasa', 'open' => '09:00', 'close' => '22:00', 'is_closed' => false],
            ['day' => 'Rabu', 'open' => '09:00', 'close' => '22:00', 'is_closed' => false],
            ['day' => 'Kamis', 'open' => '09:00', 'close' => '22:00', 'is_closed' => false],
            ['day' => 'Jumat', 'open' => '09:00', 'close' => '22:00', 'is_closed' => false],
            ['day' => 'Sabtu', 'open' => '09:00', 'close' => '22:00', 'is_closed' => false],
            ['day' => 'Minggu', 'open' => '09:00', 'close' => '22:00', 'is_closed' => true],
        ];
        $this->operational_hours = $this->setting->operational_hours ?? $defaultHours;

        // Tab 3
        $this->is_cash_active = filter_var($this->setting->is_cash_active ?? true, FILTER_VALIDATE_BOOLEAN);
        $this->is_qris_active = filter_var($this->setting->is_qris_active ?? true, FILTER_VALIDATE_BOOLEAN);
        $this->is_transfer_active = filter_var($this->setting->is_transfer_active ?? false, FILTER_VALIDATE_BOOLEAN);
        $this->bank_name = $this->setting->bank_name;
        $this->account_number = $this->setting->account_number;
        $this->account_name = $this->setting->account_name;
        $this->quick_amounts = $this->setting->quick_amounts ?? [5000, 10000, 20000, 50000];

        // Tab 4
        $this->primary_color = $this->setting->primary_color ?? '#E8781A';
    }

    public function selectColorPreset($color)
    {
        $this->primary_color = $color;
    }

    public function switchTab($tab)
    {
        if (in_array($tab, ['informasi', 'operasional', 'pembayaran', 'tema'])) {
            $this->activeTab = $tab;
        }
    }

    public function save()
    {
        $this->validate();

        // Handle File Uploads
        if ($this->new_logo) {
            if ($this->setting->site_logo) {
                Storage::disk('public')->delete($this->setting->site_logo);
            }
            $this->setting->site_logo = $this->new_logo->store('branding', 'public');
            $this->new_logo = null;
        }

        if ($this->new_favicon) {
            if ($this->setting->site_favicon) {
                Storage::disk('public')->delete($this->setting->site_favicon);
            }
            $this->setting->site_favicon = $this->new_favicon->store('branding', 'public');
            $this->new_favicon = null;
        }

        if ($this->new_login_background) {
            if ($this->setting->login_background) {
                Storage::disk('public')->delete($this->setting->login_background);
            }
            $this->setting->login_background = $this->new_login_background->store('branding', 'public');
            $this->new_login_background = null;
        }

        if ($this->new_qris_image) {
            if ($this->setting->qris_image) {
                Storage::disk('public')->delete($this->setting->qris_image);
            }
            $this->setting->qris_image = $this->new_qris_image->store('branding', 'public');
            $this->new_qris_image = null;
        }

        // Save attributes
        $this->setting->site_name = $this->site_name;
        $this->setting->owner_name = $this->owner_name;
        $this->setting->phone = $this->phone;
        $this->setting->email = $this->email;
        $this->setting->address = $this->address;
        $this->setting->description = $this->description;
        $this->setting->operational_hours = $this->operational_hours;
        $this->setting->is_cash_active = (bool)$this->is_cash_active;
        $this->setting->is_qris_active = (bool)$this->is_qris_active;
        $this->setting->is_transfer_active = (bool)$this->is_transfer_active;
        $this->setting->bank_name = $this->bank_name;
        $this->setting->account_number = $this->account_number;
        $this->setting->account_name = $this->account_name;
        $this->setting->quick_amounts = array_map('intval', $this->quick_amounts);
        $this->setting->primary_color = $this->primary_color;

        $this->setting->save();

        session()->flash('success', 'Perubahan berhasil disimpan!');
        $this->dispatch('settings-saved', ownerName: $this->owner_name);
    }

    public function render()
    {
        return view('livewire.admin.settings-management');
    }
}
