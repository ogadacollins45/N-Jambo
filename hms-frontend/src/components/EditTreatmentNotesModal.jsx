import React, { useState } from "react";
import axios from "axios";
import { X, FileText, Loader, AlertCircle, CheckCircle } from "lucide-react";

const EditTreatmentNotesModal = ({ treatment, onClose, onSaved }) => {
  const [formData, setFormData] = useState({
    chief_complaint: treatment.chief_complaint || "",
    history_presenting_illness: treatment.history_presenting_illness || "",
    systemic_review: treatment.systemic_review || "",
    past_medical_history: treatment.past_medical_history || "",
    premedication: treatment.premedication || "",
    general_systemic_examination: treatment.general_systemic_examination || "",
    impression: treatment.impression || "",
    payment_type: treatment.payment_type || "",
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const flashMessage = (setter, message) => {
    setter(message);
    setTimeout(() => setter(""), 3000);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;
      await axios.put(`${API_BASE_URL}/treatments/${treatment.id}`, formData);

      flashMessage(setSuccess, "Treatment notes updated successfully!");
      if (onSaved) onSaved();
      setTimeout(() => {
        if (onClose) onClose();
      }, 1000);
    } catch (err) {
      console.error("Error updating treatment:", err);
      flashMessage(
        setError,
        err.response?.data?.message || "Failed to update treatment notes."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl p-6 md:p-8 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6 pb-4 border-b border-gray-200">
          <div className="flex items-center">
            <div className="bg-indigo-100 p-2 rounded-lg mr-3">
              <FileText className="w-6 h-6 text-indigo-600" />
            </div>
            <div>
              <h2 className="text-xl md:text-2xl font-bold text-gray-800">
                Edit Treatment Notes
              </h2>
              <p className="text-sm text-gray-500 mt-1">
                Treatment Date: {new Date(treatment.visit_date).toLocaleDateString()}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-full hover:bg-gray-200 transition-colors"
          >
            <X className="w-6 h-6 text-gray-600" />
          </button>
        </div>

        {error && (
          <div className="bg-red-100 border border-red-200 text-red-700 p-4 mb-6 rounded-lg flex items-center shadow-sm">
            <AlertCircle className="w-5 h-5 mr-3 flex-shrink-0" />
            <p>{error}</p>
          </div>
        )}
        {success && (
          <div className="bg-green-100 border border-green-200 text-green-700 p-4 mb-6 rounded-lg flex items-center shadow-sm">
            <CheckCircle className="w-5 h-5 mr-3 flex-shrink-0" />
            <p>{success}</p>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Chief Complaint */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Chief Complaint <span className="text-red-500">*</span>
              </label>
              <textarea
                name="chief_complaint"
                value={formData.chief_complaint}
                onChange={handleChange}
                placeholder="Patient's primary reason for visit"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* History of Presenting Illness */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                History of Presenting Illness <span className="text-red-500">*</span>
              </label>
              <textarea
                name="history_presenting_illness"
                value={formData.history_presenting_illness}
                onChange={handleChange}
                placeholder="Detailed history of the current condition"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* Systemic Review */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Systemic Review <span className="text-red-500">*</span>
              </label>
              <textarea
                name="systemic_review"
                value={formData.systemic_review}
                onChange={handleChange}
                placeholder="Review of systems"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* Past Medical History */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Past Medical & Surgical History <span className="text-red-500">*</span>
              </label>
              <textarea
                name="past_medical_history"
                value={formData.past_medical_history}
                onChange={handleChange}
                placeholder="Relevant past medical conditions, surgeries"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* Premedication */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Premedication <span className="text-red-500">*</span>
              </label>
              <textarea
                name="premedication"
                value={formData.premedication}
                onChange={handleChange}
                placeholder="Current medications and dosages"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* General & Systemic Examination */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                General & Systemic Examination <span className="text-red-500">*</span>
              </label>
              <textarea
                name="general_systemic_examination"
                value={formData.general_systemic_examination}
                onChange={handleChange}
                placeholder="Physical examination findings"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* Impression */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Impression <span className="text-red-500">*</span>
              </label>
              <textarea
                name="impression"
                value={formData.impression}
                onChange={handleChange}
                placeholder="Clinical impression and assessment"
                required
                rows="3"
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              />
            </div>

            {/* Payment Type */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Payment Type <span className="text-red-500">*</span>
              </label>
              <select
                name="payment_type"
                value={formData.payment_type}
                onChange={handleChange}
                required
                className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-colors"
              >
                <option value="">Select Payment Type</option>
                <option value="Cash">Cash</option>
                <option value="Mobile Money">Mobile Money (Mpesa/Airtel Money)</option>
                <option value="Bank Transfer">Bank Transfer</option>
                <option value="Insurance">Insurance</option>
                <option value="Other">Other</option>
              </select>
            </div>
          </div>

          <div className="pt-6 mt-6 border-t border-gray-200 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex items-center px-6 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:bg-indigo-400 transition-colors shadow-sm"
            >
              {loading ? (
                <>
                  <Loader className="w-4 h-4 mr-2 animate-spin" />
                  Saving...
                </>
              ) : (
                "Save Changes"
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EditTreatmentNotesModal;
