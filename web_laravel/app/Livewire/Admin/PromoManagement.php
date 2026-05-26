<?php

namespace App\Livewire\Admin;

use App\Models\Promo;
use Livewire\Component;
use Livewire\WithFileUploads;

class PromoManagement extends Component
{
    use WithFileUploads;

    public bool $showModal = false;
    public ?int $editingId = null;

    // Form fields
    public string $name = '';
    public string $description = '';
    public string $code = '';
    public string $type = 'percentage';
    public string $promo_type = 'diskon';
    public string $value = '';
    public string $min_purchase = '0';
    public string $quota = '';
    public bool $is_active = true;
    public bool $is_banner = false;
    public string $bundling_items = '';
    public string $free_item_name = '';
    public $photo = null;
    public ?string $existingImage = null;

    protected function rules(): array
    {
        return [
            'name'         => 'required|string|max:255',
            'description'  => 'nullable|string',
            'code'         => 'required|string|max:50',
            'type'         => 'required|in:percentage,fixed',
            'promo_type'   => 'required|string',
            'value'        => 'required|numeric|min:0',
            'min_purchase' => 'nullable|numeric|min:0',
            'quota'        => 'nullable|integer|min:0',
            'is_active'    => 'boolean',
            'is_banner'    => 'boolean',
            'bundling_items' => 'nullable|string',
            'free_item_name' => 'nullable|string',
            'photo'        => 'nullable|image|max:2048',
        ];
    }

    public function openAdd(): void
    {
        $this->reset(['editingId','name','description','code','type','promo_type','value','min_purchase','quota','is_active','is_banner','photo','existingImage','bundling_items','free_item_name']);
        $this->is_active = true;
        $this->type = 'percentage';
        $this->promo_type = 'diskon';
        $this->min_purchase = '0';
        $this->showModal = true;
    }

    public function openEdit(int $id): void
    {
        $promo = Promo::findOrFail($id);
        $this->editingId     = $id;
        $this->name          = $promo->name;
        $this->description   = $promo->description ?? '';
        $this->code          = $promo->code;
        $this->type          = $promo->type;
        $this->promo_type    = $promo->promo_type ?? 'diskon';
        $this->value         = $promo->value;
        $this->min_purchase  = $promo->min_purchase ?? '0';
        $this->quota         = $promo->quota ?? '';
        $this->is_active     = $promo->is_active;
        $this->is_banner     = $promo->is_banner;
        $this->existingImage = $promo->image;
        $this->bundling_items = $promo->bundling_items ?? '';
        $this->free_item_name = $promo->free_item_name ?? '';
        $this->showModal     = true;
    }

    public function save(): void
    {
        $this->validate();

        $imageUrl = $this->existingImage;
        if ($this->photo) {
            $imageUrl = '/storage/' . $this->photo->store('promos', 'public');
        }

        $data = [
            'name'         => $this->name,
            'description'  => $this->description,
            'code'         => strtoupper($this->code),
            'type'         => $this->type,
            'promo_type'   => $this->promo_type,
            'value'        => $this->value,
            'min_purchase' => $this->min_purchase ?: 0,
            'quota'        => $this->quota ?: null,
            'is_active'    => $this->is_active,
            'is_banner'    => $this->is_banner,
            'image'        => $imageUrl,
            'bundling_items' => $this->promo_type === 'bundling' ? $this->bundling_items : null,
            'free_item_name' => $this->promo_type === 'free_item' ? $this->free_item_name : null,
        ];

        if ($this->editingId) {
            Promo::findOrFail($this->editingId)->update($data);
            session()->flash('success', 'Promo berhasil diperbarui!');
        } else {
            Promo::create($data);
            session()->flash('success', 'Promo baru berhasil ditambahkan!');
        }

        $this->showModal = false;
    }

    public function toggleActive(int $id): void
    {
        $promo = Promo::findOrFail($id);
        $promo->update(['is_active' => !$promo->is_active]);
    }

    public function delete(int $id): void
    {
        Promo::findOrFail($id)->delete();
        session()->flash('success', 'Promo berhasil dihapus!');
    }

    public function render()
    {
        return view('livewire.admin.promo-management', [
            'promos' => Promo::latest()->get(),
        ]);
    }
}
