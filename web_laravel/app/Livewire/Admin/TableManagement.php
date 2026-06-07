<?php

namespace App\Livewire\Admin;

use App\Models\Table;
use Livewire\Component;

class TableManagement extends Component
{
    public bool $showModal = false;
    public ?int $editingId = null;

    public string $number = '';
    public string $name = '';
    public string $type = 'Regular';
    public int $capacity = 2;
    public string $status = 'available';
    public bool $is_active = true;

    public bool $showQrModal = false;
    public ?int $qrTableId = null;
    public string $qrTableNumber = '';
    public string $qrTableName = '';

    protected function rules(): array
    {
        return [
            'number'    => 'required|string|max:50',
            'name'      => 'nullable|string|max:100',
            'type'      => 'required|string|max:50',
            'capacity'  => 'required|integer|min:1|max:20',
            'status'    => 'required|in:available,occupied,reserved',
            'is_active' => 'boolean',
        ];
    }

    public function openAdd(): void
    {
        $this->reset(['editingId','number','name','type','capacity','status','is_active']);
        $this->type      = 'Regular';
        $this->capacity  = 2;
        $this->status    = 'available';
        $this->is_active = true;
        $this->showModal = true;
    }

    public function openEdit(int $id): void
    {
        $table = Table::findOrFail($id);
        $this->editingId = $id;
        $this->number    = $table->number;
        $this->name      = $table->name ?? '';
        $this->type      = $table->type ?? 'Regular';
        $this->capacity  = $table->capacity;
        $this->status    = $table->status;
        $this->is_active = $table->is_active;
        $this->showModal = true;
    }

    public function save(): void
    {
        $this->validate();

        $data = [
            'number'    => $this->number,
            'name'      => $this->name,
            'type'      => $this->type,
            'capacity'  => $this->capacity,
            'status'    => $this->status,
            'is_active' => $this->is_active,
        ];

        if ($this->editingId) {
            Table::findOrFail($this->editingId)->update($data);
            session()->flash('success', 'Meja berhasil diperbarui!');
        } else {
            Table::create($data);
            session()->flash('success', 'Meja berhasil ditambahkan!');
        }

        $this->showModal = false;
    }

    public function updateStatus(int $id, string $status): void
    {
        Table::findOrFail($id)->update(['status' => $status]);
    }

    public function delete(int $id): void
    {
        Table::findOrFail($id)->delete();
        session()->flash('success', 'Meja berhasil dihapus!');
    }

    public function showQr(int $id): void
    {
        $table = Table::findOrFail($id);
        $this->qrTableId = $table->id;
        $this->qrTableNumber = $table->number;
        $this->qrTableName = $table->name ?? '';
        $this->showQrModal = true;
    }

    public function render()
    {
        return view('livewire.admin.table-management', [
            'tables' => Table::orderBy('number')->get(),
        ]);
    }
}
