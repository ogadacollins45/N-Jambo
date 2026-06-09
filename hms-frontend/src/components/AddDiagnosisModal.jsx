import React, { useState } from "react";
import axios from "axios";
import { X, FileText, Loader, AlertCircle, CheckCircle } from "lucide-react";
import { DIAGNOSIS_CATEGORIES } from "../data/diagnosisCategories";
import SearchableDiagnosisDropdown from "./SearchableDiagnosisDropdown";

const AddDiagnosisModal = ({ treatment, mode = 'primary', diagnosisData = null, onClose, onSaved }) => {
    const getInitialValue = (field) => {
        if (mode === 'edit_additional' && diagnosisData) return diagnosisData[field] || "";
        if (mode === 'primary') return treatment[field] || "";
        return "";
    };

    const [diagnosis, setDiagnosis] = useState(getInitialValue('diagnosis'));
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState();

    const flashMessage = (setter, message) => {
        setter(message);
        setTimeout(() => setter(""), 3000);
    };

    const handleSubmit = async () => {
        if (!diagnosis.trim()) {
            flashMessage(setError, "Please enter a diagnosis");
            return;
        }

        if (diagnosis.trim() === "All Other Diseases") {
            flashMessage(setError, "Please specify the other disease details.");
            return;
        }

        setLoading(true);
        setError("");

        try {
            const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

            if (mode === 'additional') {
                // Create new diagnosis record
                await axios.post(`${API_BASE_URL}/treatments/${treatment.id}/diagnoses`, {
                    diagnosis: diagnosis.trim(),
                }, {
                    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
                });
            } else if (mode === 'edit_additional') {
                // Update additional diagnosis
                await axios.put(`${API_BASE_URL}/diagnoses/${diagnosisData.id}`, {
                    diagnosis: diagnosis.trim(),
                }, {
                    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
                });
            } else {
                // Update primary diagnosis in treatment
                await axios.put(`${API_BASE_URL}/treatments/${treatment.id}`, {
                    diagnosis: diagnosis.trim(),
                }, {
                    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
                });
            }

            flashMessage(setSuccess, "Diagnosis added successfully!");
            setTimeout(() => {
                onSaved();
                onClose();
            }, 1500);
        } catch (err) {
            console.error("Error adding diagnosis:", err);
            flashMessage(
                setError,
                err.response?.data?.message || "Failed to add diagnosis"
            );
        } finally {
            setLoading(false);
        }
    };



    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
                {/* Header */}
                <div className="sticky top-0 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white p-6 flex justify-between items-center rounded-t-xl">
                    <div className="flex items-center gap-3">
                        <FileText size={24} />
                        <h2 className="text-2xl font-bold">{mode === 'edit_additional' || (mode === 'primary' && treatment.diagnosis) ? 'Edit Diagnosis' : 'Add Diagnosis'}</h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-white/20 rounded-lg transition-colors"
                    >
                        <X size={24} />
                    </button>
                </div>

                {/* Content */}
                <div className="p-6 space-y-4">
                    {/* Error Message */}
                    {error && (
                        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg flex items-center gap-2">
                            <AlertCircle size={20} />
                            <span>{error}</span>
                        </div>
                    )}

                    {/* Success Message */}
                    {success && (
                        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg flex items-center gap-2">
                            <CheckCircle size={20} />
                            <span>{success}</span>
                        </div>
                    )}

                    {/* Treatment Info */}
                    <div className="bg-gray-50 p-4 rounded-lg">
                        <p className="text-sm text-gray-600">
                            <strong>Patient:</strong> {treatment.patient ? `${treatment.patient.first_name} ${treatment.patient.last_name}` : "N/A"}
                        </p>
                        <p className="text-sm text-gray-600">
                            <strong>Visit Date:</strong>{" "}
                            {new Date(treatment.visit_date).toLocaleDateString()}
                        </p>
                    </div>

                    {/* Diagnosis Input */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Diagnosis <span className="text-red-500">*</span>
                        </label>
                        <SearchableDiagnosisDropdown 
                            value={diagnosis}
                            onChange={(val) => setDiagnosis(val)}
                            placeholder="Search or select diagnosis..."
                        />
                        <p className="text-xs text-gray-500 mt-2">
                            The disease category and subcategory will be automatically assigned.
                        </p>
                    </div>
                </div>

                {/* Footer */}
                <div className="sticky bottom-0 bg-gray-50 px-6 py-4 flex justify-end gap-3 rounded-b-xl border-t">
                    <button
                        onClick={onClose}
                        className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                        disabled={loading}
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleSubmit}
                        disabled={loading}
                        className="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {loading ? (
                            <>
                                <Loader className="animate-spin" size={18} />
                                Saving...
                            </>
                        ) : (
                            "Save Diagnosis"
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default AddDiagnosisModal;
