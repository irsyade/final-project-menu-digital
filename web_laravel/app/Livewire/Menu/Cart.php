<?php

namespace App\Livewire\Menu;

use App\Models\Product;
use App\Models\Promo;
use Livewire\Component;

class Cart extends Component
{
    public array $items = [];       // ['product_id' => qty, ...]
    public string $customerName = '';
    public string $tableName = '';
    public ?string $promoCode = null;
    public ?array $appliedPromo = null;
    public string $promoMessage = '';
    public bool $promoValid = false;
    public string $activeScreen = 'menu'; // menu | cart | status

    // Last placed order for status screen
    public ?array $lastOrder = null;

    // Order status polling
    public string $orderStatus = 'pending';   // pending | processing | ready | completed
    public string $orderNotification = '';     // shown alert message
    public string $notificationLevel = '';    // info | success | warning

    protected $listeners = ['addToCart'];

    public function mount(string $tableName = ''): void
    {
        $this->tableName = $tableName;
    }

    // Called from ProductList via dispatch
    public function addToCart(int $productId): void
    {
        $key = (string) $productId;
        $this->items[$key] = ($this->items[$key] ?? 0) + 1;
    }

    public function updateQty(int $productId, int $qty): void
    {
        $key = (string) $productId;
        if ($qty <= 0) {
            unset($this->items[$key]);
        } else {
            $this->items[$key] = $qty;
        }
    }

    public function removeItem(int $productId): void
    {
        unset($this->items[(string) $productId]);
    }

    public function clearCart(): void
    {
        $this->items = [];
        $this->promoCode    = null;
        $this->appliedPromo = null;
        $this->promoMessage = '';
        $this->promoValid   = false;
    }

    public function applyPromo(): void
    {
        $this->promoMessage = '';
        $this->appliedPromo = null;
        $this->promoValid   = false;

        if (!$this->promoCode) {
            $this->promoMessage = 'Masukkan kode promo terlebih dahulu.';
            return;
        }

        $promo = Promo::where('code', strtoupper($this->promoCode))
            ->where('is_active', true)
            ->first();

        if (!$promo) {
            $this->promoMessage = 'Kode promo tidak valid atau sudah tidak aktif.';
            return;
        }

        if ($promo->min_purchase > 0 && $this->subtotal() < $promo->min_purchase) {
            $this->promoMessage = 'Belanja minimum Rp ' . number_format($promo->min_purchase, 0, ',', '.') . ' untuk menggunakan promo ini.';
            return;
        }

        $this->appliedPromo = $promo->toArray();
        $this->promoValid   = true;
        $this->promoMessage = 'Promo berhasil diterapkan!';
    }

    public function subtotal(): float
    {
        $total = 0;
        $products = Product::whereIn('id', array_keys($this->items))->get()->keyBy('id');

        foreach ($this->items as $productId => $qty) {
            $product = $products[$productId] ?? null;
            if (!$product) continue;
            $price = $product->discount_percentage > 0
                ? $product->price * (1 - $product->discount_percentage / 100)
                : $product->price;
            $total += $price * $qty;
        }

        return $total;
    }

    public function discount(): float
    {
        if (!$this->appliedPromo) return 0;

        $promo = $this->appliedPromo;
        if ($promo['type'] === 'percentage') {
            return $this->subtotal() * ($promo['value'] / 100);
        }
        return min($promo['value'], $this->subtotal());
    }

    public function grandTotal(): float
    {
        return max(0, $this->subtotal() - $this->discount());
    }

    public function cartCount(): int
    {
        return array_sum($this->items);
    }

    public function setScreen(string $screen): void
    {
        $this->activeScreen = $screen;
    }

    public function placeOrder(): void
    {
        if (empty($this->items)) return;

        $products = Product::whereIn('id', array_keys($this->items))->get()->keyBy('id');
        $orderItems = [];

        foreach ($this->items as $productId => $qty) {
            $product = $products[$productId] ?? null;
            if (!$product) continue;
            $price = $product->discount_percentage > 0
                ? $product->price * (1 - $product->discount_percentage / 100)
                : $product->price;
            $orderItems[] = [
                'product_id' => $productId,
                'quantity'   => $qty,
                'price'      => $price,
                'name'       => $product->name,
                'image'      => $product->image,
            ];
        }

        $order = \App\Models\Order::create([
            'total_price'    => $this->grandTotal(),
            'discount'       => $this->discount(),
            'status'         => 'pending',
            'payment_method' => 'cash',
            'payment_status' => 'unpaid',
            'name'           => $this->customerName ?: 'Pelanggan',
            'address'        => $this->tableName,
            'phone'          => '-',
            'email'          => '-',
        ]);

        foreach ($orderItems as $item) {
            $order->items()->create([
                'product_id' => $item['product_id'],
                'quantity'   => $item['quantity'],
                'price'      => $item['price'],
            ]);
        }

        $this->lastOrder = [
            'id'         => $order->id,
            'items'      => $orderItems,
            'subtotal'   => $this->subtotal(),
            'discount'   => $this->discount(),
            'grandTotal' => $this->grandTotal(),
            'tableName'  => $this->tableName,
        ];

        $this->orderStatus = 'pending';
        $this->orderNotification = '⏳ Pesanan Anda sedang menunggu konfirmasi dari kasir...';
        $this->notificationLevel = 'info';

        $this->clearCart();
        $this->activeScreen = 'status';
    }

    // Called every 5s via wire:poll when on status screen
    public function pollOrderStatus(): void
    {
        if (!$this->lastOrder || $this->activeScreen !== 'status') return;

        $order = \App\Models\Order::find($this->lastOrder['id']);
        if (!$order) return;

        $newStatus = $order->status;

        // Only update notification when status changes
        if ($newStatus !== $this->orderStatus) {
            $this->orderStatus = $newStatus;

            match ($newStatus) {
                'processing' => [
                    $this->orderNotification = '👨‍🍳 Pesanan Anda sedang diproses oleh dapur!',
                    $this->notificationLevel = 'warning',
                ],
                'ready' => [
                    $this->orderNotification = '🛵 Pesanan Anda siap dan sedang dalam perjalanan ke meja Anda!',
                    $this->notificationLevel = 'success',
                ],
                'completed' => [
                    $this->orderNotification = '✅ Pesanan Anda telah selesai. Selamat menikmati!',
                    $this->notificationLevel = 'success',
                ],
                'cancelled' => [
                    $this->orderNotification = '❌ Maaf, pesanan Anda dibatalkan. Silakan hubungi kasir.',
                    $this->notificationLevel = 'error',
                ],
                default => [
                    $this->orderNotification = '⏳ Pesanan Anda sedang menunggu konfirmasi dari kasir...',
                    $this->notificationLevel = 'info',
                ],
            };
        }
    }

    public function render()
    {
        $cartProducts = collect();
        if (!empty($this->items)) {
            $cartProducts = Product::whereIn('id', array_keys($this->items))->get();
        }

        $setting = \App\Models\Setting::first() ?? new \App\Models\Setting();

        return view('livewire.menu.cart', compact('cartProducts', 'setting'));
    }
}
