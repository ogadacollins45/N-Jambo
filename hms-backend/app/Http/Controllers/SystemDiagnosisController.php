<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\SystemDiagnosis;

class SystemDiagnosisController extends Controller
{
    public function index()
    {
        $diagnoses = SystemDiagnosis::orderBy('name', 'asc')->get();
        return response()->json($diagnoses);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:system_diagnoses,name',
        ]);

        $diagnosis = SystemDiagnosis::create([
            'name' => $request->name,
        ]);

        return response()->json($diagnosis, 201);
    }

    public function destroy($id)
    {
        $diagnosis = SystemDiagnosis::findOrFail($id);
        $diagnosis->delete();

        return response()->json(['message' => 'Diagnosis deleted successfully']);
    }
}
