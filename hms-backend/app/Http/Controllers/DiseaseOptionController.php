<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DiseaseOption;
use App\Services\DiseaseMapper;

class DiseaseOptionController extends Controller
{
    public function index()
    {
        $options = DiseaseOption::with(['category', 'subcategory'])->orderBy('name', 'asc')->get();
        return response()->json($options);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:disease_options,name',
        ]);

        $diseaseOption = DiseaseOption::create([
            'name' => $request->name,
            'is_custom' => true,
        ]);

        return response()->json($diseaseOption, 201);
    }

    public function destroy($id)
    {
        $diseaseOption = DiseaseOption::findOrFail($id);
        
        // Prevent deletion of base (non-custom) diseases
        if (!$diseaseOption->is_custom) {
            return response()->json(['message' => 'Cannot delete base disease options.'], 403);
        }

        $diseaseOption->delete();

        return response()->json(['message' => 'Disease option deleted successfully']);
    }

    public function seedDefaults()
    {
        // Get base labels from DiseaseMapper
        $baseLabels = array_values(DiseaseMapper::labels());

        // We ensure 'All Other Diseases' is present
        if (!in_array('All Other Diseases', $baseLabels)) {
            $baseLabels[] = 'All Other Diseases';
        }

        $count = 0;
        foreach ($baseLabels as $label) {
            // First or create based on name, making sure it's marked as non-custom
            $existing = DiseaseOption::where('name', $label)->first();
            if (!$existing) {
                DiseaseOption::create([
                    'name' => $label,
                    'is_custom' => false
                ]);
                $count++;
            } else if ($existing->is_custom) {
                // if it exists but marked custom, update it
                $existing->update(['is_custom' => false]);
                $count++;
            }
        }

        return response()->json(['message' => "Seeded defaults successfully. Added/Updated {$count} options."]);
    }
    public function batchAssignCategory(Request $request)
    {
        $validated = $request->validate([
            'disease_option_ids' => 'required|array',
            'disease_option_ids.*' => 'exists:disease_options,id',
            'disease_category_id' => 'required|exists:disease_categories,id',
            'disease_subcategory_id' => 'required|exists:disease_subcategories,id',
        ]);

        // ensure subcategory belongs to category
        $subcategory = \App\Models\DiseaseSubcategory::where('id', $validated['disease_subcategory_id'])
            ->where('disease_category_id', $validated['disease_category_id'])
            ->first();

        if (!$subcategory) {
            return response()->json(['message' => 'The selected subcategory does not belong to the selected category.'], 422);
        }

        DiseaseOption::whereIn('id', $validated['disease_option_ids'])->update([
            'disease_category_id' => $validated['disease_category_id'],
            'disease_subcategory_id' => $validated['disease_subcategory_id'],
        ]);

        return response()->json(['message' => 'Categories assigned successfully.']);
    }
}
