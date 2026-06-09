import React, { useEffect, useState, useContext } from "react";
import axios from "axios";
import DashboardLayout from "../layout/DashboardLayout";
import { AuthContext } from "../context/AuthContext";
import {
  Plus,
  Pencil,
  Trash2,
  Save,
  X,
  Loader,
  CheckCircle,
  AlertCircle,
  Activity,
  ChevronLeft,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

/* ─────────────────────────────────────────────
   Inline form for create
───────────────────────────────────────────── */
const ItemForm = ({ onSave, onCancel, saving }) => {
  const [form, setForm] = useState({ name: "" });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave(form);
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-gradient-to-br from-indigo-50 to-blue-50 border border-indigo-200 rounded-2xl p-6 mb-6 shadow-md"
    >
      <h3 className="text-lg font-bold text-indigo-800 mb-4">
        New Custom Diagnosis
      </h3>
      <div className="grid grid-cols-1 gap-4">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Diagnosis Name *</label>
          <input
            type="text"
            name="name"
            value={form.name}
            onChange={handleChange}
            required
            placeholder="e.g. Chronic Migraine"
            className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white text-sm"
          />
        </div>
      </div>
      <div className="flex gap-3 mt-5 justify-end">
        <button
          type="button"
          onClick={onCancel}
          className="flex items-center gap-2 px-5 py-2.5 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-100 transition text-sm"
        >
          <X size={16} /> Cancel
        </button>
        <button
          type="submit"
          disabled={saving}
          className="flex items-center gap-2 px-5 py-2.5 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:bg-indigo-400 transition text-sm shadow-md"
        >
          {saving ? <Loader size={16} className="animate-spin" /> : <Save size={16} />}
          {saving ? "Saving..." : "Save Diagnosis"}
        </button>
      </div>
    </form>
  );
};

/* ─────────────────────────────────────────────
   Main page component
───────────────────────────────────────────── */
const DiagnosesManagement = () => {
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();

  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(null);

  const [showCreate, setShowCreate] = useState(false);

  const [toast, setToast] = useState({ type: "", text: "" });

  const token = localStorage.getItem("token");
  const headers = { Authorization: `Bearer ${token}` };

  const showToast = (type, text) => {
    setToast({ type, text });
    setTimeout(() => setToast({ type: "", text: "" }), 4000);
  };

  const fetchItems = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_BASE_URL}/disease-options`, { headers });
      setItems(res.data);
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to load diagnoses.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, []);

  const handleCreate = async (formData) => {
    setSaving(true);
    try {
      await axios.post(`${API_BASE_URL}/disease-options`, formData, { headers });
      showToast("success", "Diagnosis created successfully!");
      setShowCreate(false);
      await fetchItems();
    } catch (err) {
      console.error(err);
      showToast("error", err.response?.data?.message || "Failed to create diagnosis.");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this custom diagnosis? This cannot be undone.")) return;
    setDeleting(id);
    try {
      await axios.delete(`${API_BASE_URL}/disease-options/${id}`, { headers });
      showToast("success", "Diagnosis deleted.");
      setItems((prev) => prev.filter((i) => i.id !== id));
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to delete diagnosis.");
    } finally {
      setDeleting(null);
    }
  };

  const handleSeedDefaults = async () => {
    setLoading(true);
    try {
      const res = await axios.post(`${API_BASE_URL}/disease-options/seed-defaults`, {}, { headers });
      showToast("success", res.data.message);
      await fetchItems();
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to seed base diseases.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gray-50 py-10 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <div className="flex items-center gap-3 mb-2">
            <button
              onClick={() => navigate("/system-settings")}
              className="p-2 rounded-full hover:bg-gray-200 transition"
              title="Back to System Settings"
            >
              <ChevronLeft size={22} className="text-gray-600" />
            </button>
            <div>
              <h1 className="text-3xl font-bold text-gray-800 flex items-center gap-3">
                <Activity size={30} className="text-indigo-600" />
                Custom Diagnoses Management
              </h1>
              <p className="text-gray-500 text-sm mt-0.5">
                Manage a custom list of diagnoses to be available system-wide in addition to the standard database.
              </p>
            </div>
          </div>

          {toast.text && (
            <div
              className={`mt-4 flex items-center gap-3 px-5 py-4 rounded-xl shadow-md border-l-4 ${
                toast.type === "success"
                  ? "bg-green-50 border-green-500 text-green-700"
                  : "bg-red-50 border-red-500 text-red-700"
              }`}
            >
              {toast.type === "success" ? (
                <CheckCircle size={20} />
              ) : (
                <AlertCircle size={20} />
              )}
              <p className="text-sm font-medium">{toast.text}</p>
            </div>
          )}

          <div className="flex justify-end gap-3 mt-6 mb-4">
            <button
              onClick={handleSeedDefaults}
              className="flex items-center gap-2 px-5 py-2.5 bg-green-600 text-white font-semibold rounded-xl hover:bg-green-700 transition shadow-md text-sm"
            >
              <Activity size={18} /> Sync Base Diseases
            </button>
            {!showCreate && (
              <button
                onClick={() => setShowCreate(true)}
                className="flex items-center gap-2 px-5 py-2.5 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 transition shadow-md text-sm"
              >
                <Plus size={18} /> Add New Diagnosis
              </button>
            )}
          </div>

          {showCreate && (
            <ItemForm
              onSave={handleCreate}
              onCancel={() => setShowCreate(false)}
              saving={saving}
            />
          )}

          <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
            {loading ? (
              <div className="flex items-center justify-center py-20 text-gray-500">
                <Loader size={28} className="animate-spin mr-3 text-indigo-500" />
                <span>Loading custom diagnoses...</span>
              </div>
            ) : items.length === 0 ? (
              <div className="text-center py-20 text-gray-400">
                <Activity size={48} className="mx-auto mb-4 opacity-30" />
                <p className="text-lg font-medium">No custom diagnoses yet.</p>
                <p className="text-sm">Click "Add New Diagnosis" to add one to the system.</p>
              </div>
            ) : (
              <table className="min-w-full divide-y divide-gray-100">
                <thead className="bg-gradient-to-r from-indigo-600 to-indigo-700 text-white">
                  <tr>
                    <th className="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider">Diagnosis Name</th>
                    <th className="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider">Type</th>
                    <th className="px-6 py-3.5 text-right text-xs font-semibold uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {items.map((item) => (
                    <tr key={item.id} className="transition-colors hover:bg-indigo-50/30">
                      <td className="px-6 py-4 text-sm font-semibold text-gray-800">{item.name}</td>
                      <td className="px-6 py-4 text-sm">
                        {item.is_custom ? (
                          <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">Custom</span>
                        ) : (
                          <span className="px-2 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded-full">Base</span>
                        )}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          {item.is_custom ? (
                            <button
                              onClick={() => handleDelete(item.id)}
                              disabled={deleting === item.id}
                              className="p-2 rounded-lg text-red-500 hover:bg-red-100 transition disabled:opacity-40"
                              title="Delete Custom Diagnosis"
                            >
                              {deleting === item.id ? (
                                <Loader size={16} className="animate-spin" />
                              ) : (
                                <Trash2 size={16} />
                              )}
                            </button>
                          ) : (
                            <span className="text-xs text-gray-400 italic">Cannot delete base disease</span>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default DiagnosesManagement;
