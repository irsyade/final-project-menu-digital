<?php

namespace App\Livewire\Admin;

use App\Models\Order;
use Livewire\Component;
use Livewire\WithPagination;

class OrderManagement extends Component
{
    use WithPagination;

    public string $filterStatus = '';
    public string $search = '';

    protected $queryString = ['filterStatus', 'search'];

    public function updatingFilterStatus(): void
    {
        $this->resetPage();
    }

    public function updatingSearch(): void
    {
        $this->resetPage();
    }

    public function updateStatus(int $orderId, string $status): void
    {
        if (auth()->user()->role !== 'kasir') {
            return;
        }

        $validStatuses = ['pending', 'processing', 'completed', 'cancelled'];
        if (!in_array($status, $validStatuses)) return;

        Order::findOrFail($orderId)->update(['status' => $status]);
        session()->flash('success', 'Status pesanan berhasil diperbarui!');
    }

    public function render()
    {
        $orders = Order::with('items.product')
            ->when($this->filterStatus && $this->filterStatus !== 'semua', fn($q) => $q->where('status', $this->filterStatus))
            ->when($this->search, fn($q) => $q->where('name', 'like', "%{$this->search}%")->orWhere('id', 'like', "%{$this->search}%"))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.order-management', compact('orders'));
    }
}
