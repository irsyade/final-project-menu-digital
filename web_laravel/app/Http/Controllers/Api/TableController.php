<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Table;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TableController extends Controller
{
    // Mapping status dari Flutter ke DB (dan sebaliknya)
    private array $allowedStatuses = [
        'available', 'occupied', 'reserved',
        'Aktif', 'Nonaktif', 'Booking',
    ];

    /**
     * GET /api/tables - Ambil semua meja (dengan created_at)
     */
    public function index()
    {
        $tables = Table::orderBy('number')->get()->map(function ($table) {
            return [
                'id'            => $table->id,
                'number'        => $table->number,
                'name'          => $table->name,
                'type'          => $table->type,
                'capacity'      => $table->capacity,
                'status'        => $table->status,
                'customer_name' => $table->customer_name,
                'is_active'     => (bool) $table->is_active,
                'created_at'    => $table->created_at?->toISOString(),
                'updated_at'    => $table->updated_at?->toISOString(),
            ];
        });

        return response()->json($tables);
    }

    /**
     * POST /api/tables - Buat meja baru
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'number'    => 'required|string|max:50',
            'name'      => 'nullable|string|max:100',
            'type'      => 'required|string|max:50',
            'capacity'  => 'required|integer|min:1|max:50',
            'status'    => 'required|in:' . implode(',', $this->allowedStatuses),
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        try {
            $table = Table::create([
                'number'    => $request->number,
                'name'      => $request->name,
                'type'      => $request->type,
                'capacity'  => $request->capacity,
                'status'    => $request->status,
                'is_active' => $request->boolean('is_active', true),
            ]);

            return response()->json([
                'success' => true,
                'data'    => $this->formatTable($table),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambah meja: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * PUT /api/tables/{id} - Update meja
     */
    public function update(Request $request, $id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Meja tidak ditemukan',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'number'    => 'required|string|max:50',
            'name'      => 'nullable|string|max:100',
            'type'      => 'required|string|max:50',
            'capacity'  => 'required|integer|min:1|max:50',
            'status'    => 'required|in:' . implode(',', $this->allowedStatuses),
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        try {
            $table->update([
                'number'    => $request->number,
                'name'      => $request->name,
                'type'      => $request->type,
                'capacity'  => $request->capacity,
                'status'    => $request->status,
                'is_active' => $request->boolean('is_active', $table->is_active),
            ]);

            return response()->json([
                'success' => true,
                'data'    => $this->formatTable($table->fresh()),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui meja: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * DELETE /api/tables/{id} - Hapus meja
     */
    public function destroy($id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Meja tidak ditemukan',
            ], 404);
        }

        try {
            $table->delete();
            return response()->json([
                'success' => true,
                'message' => 'Meja berhasil dihapus',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus meja: ' . $e->getMessage(),
            ], 500);
        }
    }

    private function formatTable(Table $table): array
    {
        return [
            'id'            => $table->id,
            'number'        => $table->number,
            'name'          => $table->name,
            'type'          => $table->type,
            'capacity'      => $table->capacity,
            'status'        => $table->status,
            'customer_name' => $table->customer_name,
            'is_active'     => (bool) $table->is_active,
            'created_at'    => $table->created_at?->toISOString(),
            'updated_at'    => $table->updated_at?->toISOString(),
        ];
    }
}
