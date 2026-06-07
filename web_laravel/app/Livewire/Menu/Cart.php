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
        // ── 1. Baca ?table= atau ?meja= dari URL ──────────────────────────────
        //    Ini HARUS diproses sebelum session supaya scan QR baru selalu menang
        $tableParam = request()->query('table') ?? request()->query('meja');

        if ($tableParam) {
            // Ada param di URL → resolve dari DB, simpan ke session
            $tableModel = \App\Models\Table::where('number', $tableParam)
                ->orWhere('name', $tableParam)
                ->first();

            if ($tableModel) {
                $label = 'Meja ' . $tableModel->number;
                if ($tableModel->name
                    && $tableModel->name !== 'Meja ' . $tableModel->number
                    && $tableModel->name !== $tableModel->number) {
                    $label .= ' • ' . $tableModel->name;
                }
            } else {
                $label = 'Meja ' . $tableParam;
            }

            $this->tableName = $label;
            // Timpa session dengan meja yang baru
            session()->put('table_name', $label);

        } elseif ($tableName) {
            // Prop dari blade (Livewire mount prop)
            $this->tableName = $tableName;
            session()->put('table_name', $tableName);

        } else {
            // Tidak ada URL param dan tidak ada prop → ambil dari session (jika ada)
            $this->tableName = session()->get('table_name', '');
        }

        // ── 2. Restore state lain dari session ────────────────────────────────
        $this->items        = session()->get('cart_items', []);
        $this->customerName = session()->get('customer_name', '');
        $this->promoCode    = session()->get('promo_code', null);
        $this->appliedPromo = session()->get('applied_promo', null);
        $this->promoMessage = session()->get('promo_message', '');
        $this->promoValid   = session()->get('promo_valid', false);
        $this->activeScreen = session()->get('active_screen', 'menu');
    }

    public function updated($propertyName): void
    {
        $this->saveToSession();
    }

    private function saveToSession(): void
    {
        session()->put('cart_items', $this->items);
        session()->put('customer_name', $this->customerName);
        session()->put('table_name', $this->tableName);
        session()->put('promo_code', $this->promoCode);
        session()->put('applied_promo', $this->appliedPromo);
        session()->put('promo_message', $this->promoMessage);
        session()->put('promo_valid', $this->promoValid);
        session()->put('active_screen', $this->activeScreen);
    }

    // Called from ProductList via dispatch
    public function addToCart(int $productId): void
    {
        $key = (string) $productId;
        $this->items[$key] = ($this->items[$key] ?? 0) + 1;
        $this->saveToSession();
    }

    public function updateQty(int $productId, int $qty): void
    {
        $key = (string) $productId;
        if ($qty <= 0) {
            unset($this->items[$key]);
        } else {
            $this->items[$key] = $qty;
        }
        $this->saveToSession();
    }

    public function removeItem(int $productId): void
    {
        unset($this->items[(string) $productId]);
        $this->saveToSession();
    }

    public function clearCart(): void
    {
        $this->items = [];
        $this->promoCode    = null;
        $this->appliedPromo = null;
        $this->promoMessage = '';
        $this->promoValid   = false;
        $this->saveToSession();
    }

    public function applyPromoFromBanner(string $code): void
    {
        $this->promoCode = $code;
        $this->applyPromo();
        $this->setScreen('cart');
    }

    public function applyPromo(): void
    {
        $this->promoMessage = '';
        $this->appliedPromo = null;
        $this->promoValid   = false;

        if (!$this->promoCode) {
            $this->promoMessage = 'Masukkan kode promo terlebih dahulu.';
            $this->saveToSession();
            return;
        }

        $promo = Promo::where('code', strtoupper($this->promoCode))
            ->where('is_active', true)
            ->first();

        if (!$promo) {
            $this->promoMessage = 'Kode promo tidak valid atau sudah tidak aktif.';
            $this->saveToSession();
            return;
        }

        // Skip min_purchase check for bundling — these promos ARE the product
        if ($promo->promo_type === 'diskon' && $promo->min_purchase > 0 && $this->subtotal() < $promo->min_purchase) {
            $this->promoMessage = 'Belanja minimum Rp ' . number_format($promo->min_purchase, 0, ',', '.') . ' untuk menggunakan promo ini.';
            $this->saveToSession();
            return;
        }

        $this->appliedPromo = $promo->toArray();
        $this->promoValid   = true;
        $this->promoMessage = 'Promo berhasil diterapkan!';
        $this->saveToSession();
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

        // Tambahkan harga bundling ke subtotal
        if ($this->appliedPromo && $this->appliedPromo['promo_type'] === 'bundling') {
            $total += $this->appliedPromo['value'];
        }

        return $total;
    }

    public function discount(): float
    {
        if (!$this->appliedPromo) return 0;
        $promo = $this->appliedPromo;

        if ($promo['promo_type'] === 'bundling') {
            return 0; // Bundling tidak dikurangi dari subtotal sebagai diskon nominal
        }

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
        $this->saveToSession();
    }

    public function placeOrder(): void
    {
        if (empty($this->items) && (!$this->appliedPromo || $this->appliedPromo['promo_type'] === 'diskon')) {
            return;
        }

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

        $promoDesc = '';
        if ($this->appliedPromo) {
            if ($this->appliedPromo['promo_type'] === 'bundling') {
                $promoDesc = "Promo Bundling: " . $this->appliedPromo['name'] . " (" . $this->appliedPromo['bundling_items'] . ")";
            } else {
                $promoDesc = "Promo Code: " . $this->appliedPromo['code'];
            }
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
            'review'         => $promoDesc ?: null,
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
            'promoDesc'  => $promoDesc,
        ];

        $this->orderStatus = 'pending';
        $this->orderNotification = '⏳ Pesanan Anda sedang menunggu konfirmasi dari kasir...';
        $this->notificationLevel = 'info';

        $this->clearCart();
        $this->activeScreen = 'status';
        $this->saveToSession();
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
