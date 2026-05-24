<?php

namespace App\Livewire\Admin;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Support\Facades\Storage;
use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\WithPagination;

class ProductManagement extends Component
{
    use WithFileUploads, WithPagination;

    // Filters
    public string $search = '';
    public string $filterCategory = '';
    public string $filterCuisine = '';
    public string $viewMode = 'grid';

    // Form fields
    public ?int $editingId = null;
    public string $name = '';
    public string $description = '';
    public string $price = '';
    public int $discount_percentage = 0;
    public string $cuisine = '';
    public string $tags = '';
    public int $category_id = 0;
    public bool $is_popular = false;
    public bool $is_available = true;
    public $photo = null;
    public ?string $existingImage = null;

    public bool $showModal = false;

    protected $queryString = ['search', 'filterCategory', 'filterCuisine'];

    protected function rules(): array
    {
        return [
            'name'                => 'required|string|max:255',
            'description'         => 'nullable|string',
            'price'               => 'required|numeric|min:0',
            'discount_percentage' => 'required|integer|min:0|max:100',
            'cuisine'             => 'nullable|string|max:100',
            'tags'                => 'nullable|string',
            'category_id'         => 'required|exists:categories,id',
            'is_popular'          => 'boolean',
            'is_available'        => 'boolean',
            'photo'               => 'nullable|image|max:2048',
        ];
    }

    public function updatingSearch(): void
    {
        $this->resetPage();
    }

    public function openAdd(): void
    {
        $this->reset(['editingId','name','description','price','discount_percentage','cuisine','tags','category_id','is_popular','is_available','photo','existingImage']);
        $this->showModal = true;
    }

    public function openEdit(int $id): void
    {
        $product = Product::findOrFail($id);
        $this->editingId        = $id;
        $this->name             = $product->name;
        $this->description      = $product->description ?? '';
        $this->price            = $product->price;
        $this->discount_percentage = $product->discount_percentage;
        $this->cuisine          = $product->cuisine ?? '';
        $this->tags             = is_array($product->tags) ? implode(', ', $product->tags) : ($product->tags ?? '');
        $this->category_id      = $product->category_id;
        $this->is_popular       = $product->is_popular;
        $this->is_available     = $product->is_available;
        $this->existingImage    = $product->image;
        $this->showModal = true;
    }

    public function save(): void
    {
        $this->validate();

        $imageUrl = $this->existingImage;
        if ($this->photo) {
            $imageUrl = $this->photo->store('products', 'public');
            $imageUrl = '/storage/' . $imageUrl;
        }

        $tagsArray = array_filter(array_map('trim', explode(',', $this->tags)));

        $data = [
            'name'                => $this->name,
            'description'         => $this->description,
            'price'               => $this->price,
            'discount_percentage' => $this->discount_percentage,
            'cuisine'             => $this->cuisine,
            'tags'                => $tagsArray ?: null,
            'category_id'         => $this->category_id,
            'is_popular'          => $this->is_popular,
            'is_available'        => $this->is_available,
            'image'               => $imageUrl,
        ];

        if ($this->editingId) {
            Product::findOrFail($this->editingId)->update($data);
            session()->flash('success', 'Menu berhasil diperbarui!');
        } else {
            Product::create($data);
            session()->flash('success', 'Menu baru berhasil ditambahkan!');
        }

        $this->showModal = false;
    }

    public function toggleAvailability(int $id): void
    {
        $product = Product::findOrFail($id);
        $product->update(['is_available' => !$product->is_available]);
    }

    public function delete(int $id): void
    {
        Product::findOrFail($id)->delete();
        session()->flash('success', 'Menu berhasil dihapus!');
    }

    public function render()
    {
        $products = Product::with('category')
            ->when($this->search, fn($q) => $q->where('name', 'like', "%{$this->search}%"))
            ->when($this->filterCategory, fn($q) => $q->where('category_id', $this->filterCategory))
            ->when($this->filterCuisine, fn($q) => $q->where('cuisine', $this->filterCuisine))
            ->latest()
            ->paginate(12);

        $categories = Category::all();
        $cuisines = Product::whereNotNull('cuisine')->distinct()->pluck('cuisine');

        return view('livewire.admin.product-management', compact('products', 'categories', 'cuisines'));
    }
}
