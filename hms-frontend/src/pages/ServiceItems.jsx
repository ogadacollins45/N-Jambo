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
  Package,
  ToggleLeft,
  ToggleRight,
  ChevronLeft,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

/* ─────────────────────────────────────────────
   Tiny helper: format currency
───────────────────────────────────────────── */
const fmt = (n) =>
  Number(n).toLocaleString("en-KE", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/* ─────────────────────────────────────────────
   Inline form for create / edit
───────────────────────────────────────────── */
const ItemForm = ({ initial, onSave, onCancel, saving }) => {
  const [form, setForm] = useState(
    initial ?? { name: "", description: "", price: "", is_active: true }
  );

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave({ ...form, price: parseFloat(form.price) });
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-gradient-to-br from-indigo-50 to-blue-50 border border-indigo-200 rounded-2xl p-6 mb-6 shadow-md"
    >
      <h3 className="text-lg font-bold text-indigo-800 mb-4">
        {initial ? "Edit Service Item" : "New Service Item"}
      </h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Name */}
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Item Name *</label>
          <input
            type="text"
            name="name"
            value={form.name}
            onChange={handleChange}
            required
            placeholder="e.g. Wound Dressing"
            className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white text-sm"
          />
        </div>
        {/* Price */}
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Price (KES) *</label>
          <input
            type="number"
            name="price"
            value={form.price}
            onChange={handleChange}
            required
            min="0"
            step="0.01"
            placeholder="0.00"
            className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white text-sm"
          />
        </div>
        {/* Description */}
        <div className="md:col-span-2">
          <label className="block text-sm font-semibold text-gray-700 mb-1">
            Description (optional)
          </label>
          <textarea
            name="description"
            value={form.description ?? ""}
            onChange={handleChange}
            rows={2}
            placeholder="Brief description of this service/procedure..."
            className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white text-sm resize-none"
          />
        </div>
        {/* Active toggle */}
        <div className="flex items-center gap-3">
          <label className="text-sm font-semibold text-gray-700">Active</label>
          <input
            type="checkbox"
            name="is_active"
            checked={form.is_active}
            onChange={handleChange}
            className="w-5 h-5 rounded text-indigo-600 cursor-pointer"
          />
          <span className={`text-xs font-medium ${form.is_active ? "text-green-600" : "text-gray-400"}`}>
            {form.is_active ? "Visible in billing" : "Hidden from billing"}
          </span>
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
          {saving ? "Saving..." : "Save Item"}
        </button>
      </div>
    </form>
  );
};

/* ─────────────────────────────────────────────
   Main page component
───────────────────────────────────────────── */
const ServiceItems = () => {
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();

  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(null); // id of item being deleted

  const [showCreate, setShowCreate] = useState(false);
  const [editItem, setEditItem] = useState(null); // item being edited

  const [toast, setToast] = useState({ type: "", text: "" });

  const token = localStorage.getItem("token");
  const headers = { Authorization: `Bearer ${token}` };

  /* Flash message helper */
  const showToast = (type, text) => {
    setToast({ type, text });
    setTimeout(() => setToast({ type: "", text: "" }), 4000);
  };

  /* Fetch all service items */
  const fetchItems = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_BASE_URL}/service-items`);
      setItems(res.data);
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to load service items.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, []);

  /* Create */
  const handleCreate = async (formData) => {
    setSaving(true);
    try {
      await axios.post(`${API_BASE_URL}/service-items`, formData, { headers });
      showToast("success", "Service item created successfully!");
      setShowCreate(false);
      await fetchItems();
    } catch (err) {
      console.error(err);
      showToast("error", err.response?.data?.message || "Failed to create item.");
    } finally {
      setSaving(false);
    }
  };

  /* Update */
  const handleUpdate = async (formData) => {
    setSaving(true);
    try {
      await axios.put(`${API_BASE_URL}/service-items/${editItem.id}`, formData, { headers });
      showToast("success", "Service item updated successfully!");
      setEditItem(null);
      await fetchItems();
    } catch (err) {
      console.error(err);
      showToast("error", err.response?.data?.message || "Failed to update item.");
    } finally {
      setSaving(false);
    }
  };

  /* Toggle active */
  const handleToggle = async (item) => {
    try {
      await axios.put(
        `${API_BASE_URL}/service-items/${item.id}`,
        { is_active: !item.is_active },
        { headers }
      );
      setItems((prev) =>
        prev.map((i) => (i.id === item.id ? { ...i, is_active: !i.is_active } : i))
      );
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to toggle item status.");
    }
  };

  /* Delete */
  const handleDelete = async (id) => {
    if (!window.confirm("Delete this service item? This cannot be undone.")) return;
    setDeleting(id);
    try {
      await axios.delete(`${API_BASE_URL}/service-items/${id}`, { headers });
      showToast("success", "Service item deleted.");
      setItems((prev) => prev.filter((i) => i.id !== id));
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to delete item.");
    } finally {
      setDeleting(null);
    }
  };

  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gray-50 py-10 px-4 sm:px-6 lg:px-8">
        {/* Header */}
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
                <Package size={30} className="text-indigo-600" />
                Procedures &amp; Extra Items
              </h1>
              <p className="text-gray-500 text-sm mt-0.5">
                Configure billable services and procedures that staff can add to any patient bill.
              </p>
            </div>
          </div>

          {/* Toast */}
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

          {/* Add new button */}
          <div className="flex justify-end mt-6 mb-4">
            {!showCreate && !editItem && (
              <button
                onClick={() => setShowCreate(true)}
                className="flex items-center gap-2 px-5 py-2.5 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 transition shadow-md text-sm"
              >
                <Plus size={18} /> Add New Item
              </button>
            )}
          </div>

          {/* Create form */}
          {showCreate && (
            <ItemForm
              initial={null}
              onSave={handleCreate}
              onCancel={() => setShowCreate(false)}
              saving={saving}
            />
          )}

          {/* Edit form */}
          {editItem && (
            <ItemForm
              initial={editItem}
              onSave={handleUpdate}
              onCancel={() => setEditItem(null)}
              saving={saving}
            />
          )}

          {/* Items list */}
          <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
            {loading ? (
              <div className="flex items-center justify-center py-20 text-gray-500">
                <Loader size={28} className="animate-spin mr-3 text-indigo-500" />
                <span>Loading items...</span>
              </div>
            ) : items.length === 0 ? (
              <div className="text-center py-20 text-gray-400">
                <Package size={48} className="mx-auto mb-4 opacity-30" />
                <p className="text-lg font-medium">No service items yet.</p>
                <p className="text-sm">Click "Add New Item" to create your first billable procedure.</p>
              </div>
            ) : (
              <table className="min-w-full divide-y divide-gray-100">
                <thead className="bg-gradient-to-r from-indigo-600 to-indigo-700 text-white">
                  <tr>
                    <th className="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider">Item Name</th>
                    <th className="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider hidden md:table-cell">Description</th>
                    <th className="px-6 py-3.5 text-right text-xs font-semibold uppercase tracking-wider">Price (KES)</th>
                    <th className="px-6 py-3.5 text-center text-xs font-semibold uppercase tracking-wider">Status</th>
                    <th className="px-6 py-3.5 text-center text-xs font-semibold uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {items.map((item) => (
                    <tr
                      key={item.id}
                      className={`transition-colors ${
                        !item.is_active ? "opacity-50 bg-gray-50" : "hover:bg-indigo-50/30"
                      }`}
                    >
                      <td className="px-6 py-4 text-sm font-semibold text-gray-800">{item.name}</td>
                      <td className="px-6 py-4 text-sm text-gray-500 hidden md:table-cell max-w-xs truncate">
                        {item.description || <span className="italic text-gray-300">—</span>}
                      </td>
                      <td className="px-6 py-4 text-sm font-bold text-gray-800 text-right">
                        {fmt(item.price)}
                      </td>
                      <td className="px-6 py-4 text-center">
                        <button
                          onClick={() => handleToggle(item)}
                          title={item.is_active ? "Click to deactivate" : "Click to activate"}
                          className="inline-flex items-center gap-1.5 text-xs font-semibold rounded-full px-3 py-1 transition"
                          style={{
                            background: item.is_active ? "#d1fae5" : "#f3f4f6",
                            color: item.is_active ? "#065f46" : "#6b7280",
                          }}
                        >
                          {item.is_active ? (
                            <><ToggleRight size={14} /> Active</>
                          ) : (
                            <><ToggleLeft size={14} /> Inactive</>
                          )}
                        </button>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className="flex items-center justify-center gap-2">
                          <button
                            onClick={() => {
                              setShowCreate(false);
                              setEditItem(item);
                            }}
                            className="p-2 rounded-lg text-indigo-600 hover:bg-indigo-100 transition"
                            title="Edit"
                          >
                            <Pencil size={16} />
                          </button>
                          <button
                            onClick={() => handleDelete(item.id)}
                            disabled={deleting === item.id}
                            className="p-2 rounded-lg text-red-500 hover:bg-red-100 transition disabled:opacity-40"
                            title="Delete"
                          >
                            {deleting === item.id ? (
                              <Loader size={16} className="animate-spin" />
                            ) : (
                              <Trash2 size={16} />
                            )}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>

          <p className="text-xs text-gray-400 mt-4 text-center">
            Items marked "Inactive" will not appear in the billing dropdown.
          </p>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default ServiceItems;
