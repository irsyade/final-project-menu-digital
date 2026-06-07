<?php

namespace App\Livewire\Menu;

use App\Models\Category;
use App\Models\Product;
use Livewire\Component;

class ProductList extends Component
{
    public string $search = '';
    public string $activeCategory = '';
    public string $activeCuisine = '';

    // Communicate to Cart component
    protected $listeners = ['refreshList' => '$refresh'];

    public function selectCategory(string $id): void
    {
        $this->activeCategory = $this->activeCategory === $id ? '' : $id;
    }

    public function selectCuisine(string $cuisine): void
    {
        $this->activeCuisine = $this->activeCuisine === $cuisine ? '' : $cuisine;
    }

    public function addToCart(int $productId): void
    {
        $product = Product::find($productId);
        if (!$product || !$product->is_available) return;

        $this->dispatch('addToCart', productId: $productId);
    }

    public function render()
    {
        $products = Product::with('category')
            ->where('is_available', true)
            ->latest()
            ->get();

        $categories = Category::withCount(['products' => fn($q) => $q->where('is_available', true)])->get();
        $cuisines   = Product::where('is_available', true)->whereNotNull('cuisine')->distinct()->pluck('cuisine');

        return view('livewire.menu.product-list', compact('products', 'categories', 'cuisines'));
    }
}
