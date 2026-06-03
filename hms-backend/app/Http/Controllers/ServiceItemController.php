<?php

namespace App\Http\Controllers;

use App\Models\ServiceItem;
use Illuminate\Http\Request;

class ServiceItemController extends Controller
{
    /**
     * List all service items.
     * Pass ?active=true to only get active items (e.g., for billing dropdown).
     */
    public function index(Request $request)
    {
        $query = ServiceItem::orderBy('name');

        if ($request->query('active') === 'true') {
            $query->active();
        }

        return response()->json($query->get());
    }

    /**
     * Create a new service item.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'        => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'price'       => 'required|numeric|min:0',
            'is_active'   => 'nullable|boolean',
        ]);

        $item = ServiceItem::create([
            'name'        => $validated['name'],
            'description' => $validated['description'] ?? null,
            'price'       => $validated['price'],
            'is_active'   => $validated['is_active'] ?? true,
        ]);

        return response()->json([
            'message' => 'Service item created successfully',
            'data'    => $item,
        ], 201);
    }

    /**
     * Show a single service item.
     */
    public function show($id)
    {
        $item = ServiceItem::findOrFail($id);
        return response()->json($item);
    }

    /**
     * Update an existing service item.
     */
    public function update(Request $request, $id)
    {
        $item = ServiceItem::findOrFail($id);

        $validated = $request->validate([
            'name'        => 'sometimes|required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'price'       => 'sometimes|required|numeric|min:0',
            'is_active'   => 'nullable|boolean',
        ]);

        $item->update($validated);

        return response()->json([
            'message' => 'Service item updated successfully',
            'data'    => $item,
        ]);
    }

    /**
     * Delete a service item.
     */
    public function destroy($id)
    {
        $item = ServiceItem::findOrFail($id);
        $item->delete();

        return response()->json([
            'message' => 'Service item deleted successfully',
        ]);
    }
}
