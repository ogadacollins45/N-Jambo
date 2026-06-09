<?php

namespace App\Http\Controllers;

use App\Models\DiseaseCategory;
use App\Models\DiseaseSubcategory;
use Illuminate\Http\Request;

class DiseaseCategoryController extends Controller
{
    public function index()
    {
        $categories = DiseaseCategory::with('subcategories')->orderBy('name')->get();
        return response()->json($categories);
    }

    public function storeCategory(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:disease_categories,name',
            'description' => 'nullable|string'
        ]);

        $category = DiseaseCategory::create($validated);
        // eager load to return consistently
        $category->load('subcategories');
        return response()->json($category, 201);
    }

    public function updateCategory(Request $request, $id)
    {
        $category = DiseaseCategory::findOrFail($id);
        
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:disease_categories,name,' . $id,
            'description' => 'nullable|string'
        ]);

        $category->update($validated);
        $category->load('subcategories');
        return response()->json($category);
    }

    public function destroyCategory($id)
    {
        $category = DiseaseCategory::findOrFail($id);
        $category->delete();
        return response()->json(['message' => 'Category deleted successfully']);
    }

    public function storeSubcategory(Request $request, $categoryId)
    {
        $category = DiseaseCategory::findOrFail($categoryId);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string'
        ]);

        // check uniqueness in this category
        if ($category->subcategories()->where('name', $validated['name'])->exists()) {
            return response()->json(['message' => 'Subcategory name must be unique within the category'], 422);
        }

        $subcategory = $category->subcategories()->create($validated);
        return response()->json($subcategory, 201);
    }

    public function updateSubcategory(Request $request, $categoryId, $subcategoryId)
    {
        $subcategory = DiseaseSubcategory::where('disease_category_id', $categoryId)->findOrFail($subcategoryId);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string'
        ]);

        if ($subcategory->name !== $validated['name']) {
            if (DiseaseSubcategory::where('disease_category_id', $categoryId)->where('name', $validated['name'])->exists()) {
                return response()->json(['message' => 'Subcategory name must be unique within the category'], 422);
            }
        }

        $subcategory->update($validated);
        return response()->json($subcategory);
    }

    public function destroySubcategory($categoryId, $subcategoryId)
    {
        $subcategory = DiseaseSubcategory::where('disease_category_id', $categoryId)->findOrFail($subcategoryId);
        $subcategory->delete();
        return response()->json(['message' => 'Subcategory deleted successfully']);
    }
}
