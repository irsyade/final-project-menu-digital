<?php

namespace App\Http\Controllers;

use App\Models\Table;
use Illuminate\Http\Request;

class TableController extends Controller
{
    public function index()
    {
        $tables = Table::orderBy('number')->get();
        return view('admin.tables.index', compact('tables'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'number' => 'required|string|unique:tables,number',
            'name' => 'nullable|string|max:255',
            'type' => 'required|string|max:50',
            'capacity' => 'required|integer|min:1',
            'customer_name' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');
        if (!isset($data['status'])) {
            $data['status'] = 'available'; // Default status for POS
        }

        Table::create($data);
        return back()->with('success', 'Table added successfully!');
    }

    public function update(Request $request, Table $table)
    {
        $data = $request->validate([
            'number' => 'required|string|unique:tables,number,' . $table->id,
            'name' => 'nullable|string|max:255',
            'type' => 'required|string|max:50',
            'capacity' => 'required|integer|min:1',
            'status' => 'required|string|in:available,occupied,booked',
            'customer_name' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $data['is_active'] = $request->has('is_active');

        $table->update($data);
        return back()->with('success', 'Table updated successfully!');
    }

    public function toggleStatus(Table $table)
    {
        $table->update([
            'is_active' => !$table->is_active
        ]);
        
        if (request()->expectsJson()) {
            return response()->json(['success' => true, 'is_active' => $table->is_active]);
        }
        return back()->with('success', 'Table status updated!');
    }

    public function destroy(Table $table)
    {
        $table->delete();
        
        if (request()->expectsJson()) {
            return response()->json(['success' => true]);
        }
        return back()->with('success', 'Table removed successfully!');
    }
}
