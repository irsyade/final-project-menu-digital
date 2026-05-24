<?php

namespace App\Livewire\Admin;

use App\Models\Category;
use Livewire\Component;
use Livewire\WithFileUploads;

class CategoryManagement extends Component
{
    use WithFileUploads;

    public ?int $editingId = null;
    public string $name = '';
    public $photo = null;
    public ?string $existingImage = null;
    public bool $showModal = false;
    public ?int $deletingId = null;

    protected function rules(): array
    {
        return [
            'name'  => 'required|string|max:255',
            'photo' => 'nullable|image|max:2048',
        ];
    }

    public function openAdd(): void
    {
        $this->reset(['editingId', 'name', 'photo', 'existingImage']);
        $this->showModal = true;
    }

    public function openEdit(int $id): void
    {
        $cat = Category::findOrFail($id);
        $this->editingId     = $id;
        $this->name          = $cat->name;
        $this->existingImage = $cat->image;
        $this->showModal     = true;
    }

    public function save(): void
    {
        $this->validate();

        $imageUrl = $this->existingImage;
        if ($this->photo) {
            $imageUrl = '/storage/' . $this->photo->store('categories', 'public');
        }

        if ($this->editingId) {
            Category::findOrFail($this->editingId)->update(['name' => $this->name, 'image' => $imageUrl]);
            session()->flash('success', 'Kategori berhasil diperbarui!');
        } else {
            Category::create(['name' => $this->name, 'image' => $imageUrl]);
            session()->flash('success', 'Kategori berhasil ditambahkan!');
        }

        $this->showModal = false;
    }

    public function confirmDelete(int $id): void
    {
        $this->deletingId = $id;
    }

    public function delete(): void
    {
        if ($this->deletingId) {
            Category::findOrFail($this->deletingId)->delete();
            $this->deletingId = null;
            session()->flash('success', 'Kategori berhasil dihapus!');
        }
    }

    public function render()
    {
        return view('livewire.admin.category-management', [
            'categories' => Category::withCount('products')->latest()->get(),
        ]);
    }
}
