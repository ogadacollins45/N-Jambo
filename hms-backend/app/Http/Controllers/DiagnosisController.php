<?php

namespace App\Http\Controllers;

use App\Models\Diagnosis;
use App\Models\Treatment;
use Illuminate\Http\Request;

class DiagnosisController extends Controller
{
    /**
     * Store a new diagnosis for a treatment
     */
    public function store(Request $request, $treatment_id)
    {
        $validated = $request->validate([
            'diagnosis' => 'required|string',
            'diagnosis_category' => 'nullable|string|max:100',
            'diagnosis_subcategory' => 'nullable|string|max:100',
        ]);

        $treatment = Treatment::findOrFail($treatment_id);

        $resolvedCategory = $validated['diagnosis_category'] ?? null;
        $resolvedSubcategory = $validated['diagnosis_subcategory'] ?? null;

        if (!empty($validated['diagnosis'])) {
            $diseaseOption = \App\Models\DiseaseOption::with(['category', 'subcategory'])->where('name', $validated['diagnosis'])->first();
            if ($diseaseOption) {
                if ($diseaseOption->category) {
                    $resolvedCategory = $diseaseOption->category->name;
                }
                if ($diseaseOption->subcategory) {
                    $resolvedSubcategory = $diseaseOption->subcategory->name;
                }
            }
        }

        $diagnosis = Diagnosis::create([
            'treatment_id' => $treatment_id,
            'diagnosis' => $validated['diagnosis'],
            'diagnosis_category' => $resolvedCategory,
            'diagnosis_subcategory' => $resolvedSubcategory,
            'is_primary' => false,
        ]);

        return response()->json([
            'message' => 'Diagnosis added successfully',
            'diagnosis' => $diagnosis,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'diagnosis' => 'required|string',
            'diagnosis_category' => 'nullable|string|max:100',
            'diagnosis_subcategory' => 'nullable|string|max:100',
        ]);

        $diagnosis = Diagnosis::findOrFail($id);

        $resolvedCategory = $validated['diagnosis_category'] ?? null;
        $resolvedSubcategory = $validated['diagnosis_subcategory'] ?? null;

        if (!empty($validated['diagnosis'])) {
            $diseaseOption = \App\Models\DiseaseOption::with(['category', 'subcategory'])->where('name', $validated['diagnosis'])->first();
            if ($diseaseOption) {
                if ($diseaseOption->category) {
                    $resolvedCategory = $diseaseOption->category->name;
                }
                if ($diseaseOption->subcategory) {
                    $resolvedSubcategory = $diseaseOption->subcategory->name;
                }
            }
        }
        
        $validated['diagnosis_category'] = $resolvedCategory;
        $validated['diagnosis_subcategory'] = $resolvedSubcategory;

        $diagnosis->update($validated);

        return response()->json([
            'message' => 'Diagnosis updated successfully',
            'diagnosis' => $diagnosis,
        ]);
    }

    /**
     * Delete a diagnosis
     */
    public function destroy($id)
    {
        $diagnosis = Diagnosis::findOrFail($id);
        $diagnosis->delete();

        return response()->json([
            'message' => 'Diagnosis deleted successfully',
        ]);
    }
}
