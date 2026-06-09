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
  ChevronDown,
  ChevronRight,
  FolderTree,
  List,
  CheckSquare,
  Square
} from "lucide-react";
import { useNavigate } from "react-router-dom";

const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

/* ─────────────────────────────────────────────
   Diagnosis Form
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

  const [activeTab, setActiveTab] = useState("diagnoses");

  const [items, setItems] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(null);

  const [showCreate, setShowCreate] = useState(false);
  const [toast, setToast] = useState({ type: "", text: "" });

  // Batch Assignment State
  const [selectedIds, setSelectedIds] = useState([]);
  const [assignCategoryId, setAssignCategoryId] = useState("");
  const [assignSubcategoryId, setAssignSubcategoryId] = useState("");

  // Categories UI State
  const [expandedCats, setExpandedCats] = useState({});
  const [editingCat, setEditingCat] = useState(null);
  const [editingSub, setEditingSub] = useState(null);
  const [showCatForm, setShowCatForm] = useState(false);
  const [showSubFormFor, setShowSubFormFor] = useState(null); // Category ID

  const [catForm, setCatForm] = useState({ name: "", description: "" });
  const [subForm, setSubForm] = useState({ name: "", description: "" });

  const token = localStorage.getItem("token");
  const headers = { Authorization: `Bearer ${token}` };

  const showToast = (type, text) => {
    setToast({ type, text });
    setTimeout(() => setToast({ type: "", text: "" }), 4000);
  };

  const fetchData = async () => {
    setLoading(true);
    try {
      const [resOptions, resCats] = await Promise.all([
        axios.get(`${API_BASE_URL}/disease-options`, { headers }),
        axios.get(`${API_BASE_URL}/disease-categories`, { headers })
      ]);
      setItems(resOptions.data);
      setCategories(resCats.data);
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to load data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleCreateDiagnosis = async (formData) => {
    setSaving(true);
    try {
      await axios.post(`${API_BASE_URL}/disease-options`, formData, { headers });
      showToast("success", "Diagnosis created successfully!");
      setShowCreate(false);
      await fetchData();
    } catch (err) {
      console.error(err);
      showToast("error", err.response?.data?.message || "Failed to create diagnosis.");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteDiagnosis = async (id) => {
    if (!window.confirm("Delete this custom diagnosis? This cannot be undone.")) return;
    setDeleting(id);
    try {
      await axios.delete(`${API_BASE_URL}/disease-options/${id}`, { headers });
      showToast("success", "Diagnosis deleted.");
      setItems((prev) => prev.filter((i) => i.id !== id));
      setSelectedIds(prev => prev.filter(selectedId => selectedId !== id));
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
      await fetchData();
    } catch (err) {
      console.error(err);
      showToast("error", "Failed to seed base diseases.");
    } finally {
      setLoading(false);
    }
  };

  const toggleSelection = (id) => {
    setSelectedIds(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  const toggleAll = () => {
    if (selectedIds.length === items.length) {
      setSelectedIds([]);
    } else {
      setSelectedIds(items.map(i => i.id));
    }
  };

  const handleBatchAssign = async () => {
    if (selectedIds.length === 0) return showToast("error", "Select at least one diagnosis.");
    if (!assignCategoryId || !assignSubcategoryId) return showToast("error", "Select both category and subcategory.");

    setSaving(true);
    try {
      await axios.post(`${API_BASE_URL}/disease-options/batch-assign-category`, {
        disease_option_ids: selectedIds,
        disease_category_id: assignCategoryId,
        disease_subcategory_id: assignSubcategoryId
      }, { headers });
      showToast("success", "Categories assigned successfully.");
      setSelectedIds([]);
      setAssignCategoryId("");
      setAssignSubcategoryId("");
      await fetchData();
    } catch (err) {
      showToast("error", err.response?.data?.message || "Failed to assign categories.");
    } finally {
      setSaving(false);
    }
  };

  // Category Handlers
  const handleSaveCat = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (editingCat) {
        await axios.put(`${API_BASE_URL}/disease-categories/${editingCat.id}`, catForm, { headers });
        showToast("success", "Category updated.");
      } else {
        await axios.post(`${API_BASE_URL}/disease-categories`, catForm, { headers });
        showToast("success", "Category created.");
      }
      setCatForm({ name: "", description: "" });
      setEditingCat(null);
      setShowCatForm(false);
      await fetchData();
    } catch (err) {
      showToast("error", err.response?.data?.message || "Failed to save category.");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteCat = async (id) => {
    if (!window.confirm("Delete this category? Subcategories and assignments will be affected.")) return;
    try {
      await axios.delete(`${API_BASE_URL}/disease-categories/${id}`, { headers });
      showToast("success", "Category deleted.");
      await fetchData();
    } catch (err) {
      showToast("error", "Failed to delete category.");
    }
  };

  // Subcategory Handlers
  const handleSaveSub = async (e, categoryId) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (editingSub) {
        await axios.put(`${API_BASE_URL}/disease-categories/${categoryId}/subcategories/${editingSub.id}`, subForm, { headers });
        showToast("success", "Subcategory updated.");
      } else {
        await axios.post(`${API_BASE_URL}/disease-categories/${categoryId}/subcategories`, subForm, { headers });
        showToast("success", "Subcategory created.");
        setExpandedCats(prev => ({ ...prev, [categoryId]: true }));
      }
      setSubForm({ name: "", description: "" });
      setEditingSub(null);
      setShowSubFormFor(null);
      await fetchData();
    } catch (err) {
      showToast("error", err.response?.data?.message || "Failed to save subcategory.");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteSub = async (categoryId, subId) => {
    if (!window.confirm("Delete this subcategory?")) return;
    try {
      await axios.delete(`${API_BASE_URL}/disease-categories/${categoryId}/subcategories/${subId}`, { headers });
      showToast("success", "Subcategory deleted.");
      await fetchData();
    } catch (err) {
      showToast("error", "Failed to delete subcategory.");
    }
  };

  const selectedCatObj = categories.find(c => c.id == assignCategoryId);
  const availableAssignSubs = selectedCatObj ? selectedCatObj.subcategories : [];

  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gray-50 py-10 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <div className="flex items-center gap-3 mb-6">
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
                Diagnoses Management
              </h1>
              <p className="text-gray-500 text-sm mt-0.5">
                Manage custom diagnoses and their classification according to standard ICD groupings.
              </p>
            </div>
          </div>

          {toast.text && (
            <div
              className={`mb-6 flex items-center gap-3 px-5 py-4 rounded-xl shadow-md border-l-4 ${
                toast.type === "success"
                  ? "bg-green-50 border-green-500 text-green-700"
                  : "bg-red-50 border-red-500 text-red-700"
              }`}
            >
              {toast.type === "success" ? <CheckCircle size={20} /> : <AlertCircle size={20} />}
              <p className="text-sm font-medium">{toast.text}</p>
            </div>
          )}

          {/* Tabs */}
          <div className="flex border-b border-gray-200 mb-6 bg-white rounded-t-xl overflow-hidden shadow-sm">
            <button
              onClick={() => setActiveTab("diagnoses")}
              className={`flex-1 py-4 text-sm font-semibold transition-colors flex items-center justify-center gap-2 ${
                activeTab === "diagnoses" ? "bg-indigo-50 text-indigo-700 border-b-2 border-indigo-600" : "text-gray-500 hover:text-gray-700 hover:bg-gray-50"
              }`}
            >
              <List size={18} />
              Diagnoses & Mapping
            </button>
            <button
              onClick={() => setActiveTab("categories")}
              className={`flex-1 py-4 text-sm font-semibold transition-colors flex items-center justify-center gap-2 ${
                activeTab === "categories" ? "bg-indigo-50 text-indigo-700 border-b-2 border-indigo-600" : "text-gray-500 hover:text-gray-700 hover:bg-gray-50"
              }`}
            >
              <FolderTree size={18} />
              Categories & Subcategories
            </button>
          </div>

          {/* TAB 1: DIAGNOSES */}
          {activeTab === "diagnoses" && (
            <div>
              <div className="flex justify-between items-end gap-3 mb-6">
                
                {/* Batch Actions */}
                <div className="flex-1 bg-white p-4 rounded-xl shadow-sm border border-gray-200 flex flex-wrap items-end gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-gray-600 mb-1">Assign Category</label>
                    <select
                      value={assignCategoryId}
                      onChange={(e) => {
                        setAssignCategoryId(e.target.value);
                        setAssignSubcategoryId("");
                      }}
                      className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-indigo-500 outline-none w-56"
                    >
                      <option value="">-- Select Category --</option>
                      {categories.map(c => (
                        <option key={c.id} value={c.id}>{c.name}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-gray-600 mb-1">Assign Subcategory</label>
                    <select
                      value={assignSubcategoryId}
                      onChange={(e) => setAssignSubcategoryId(e.target.value)}
                      disabled={!assignCategoryId}
                      className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-indigo-500 outline-none w-56 disabled:bg-gray-100"
                    >
                      <option value="">-- Select Subcategory --</option>
                      {availableAssignSubs.map(s => (
                        <option key={s.id} value={s.id}>{s.name}</option>
                      ))}
                    </select>
                  </div>
                  <button
                    onClick={handleBatchAssign}
                    disabled={selectedIds.length === 0 || saving}
                    className="px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 disabled:bg-indigo-300 transition shadow flex items-center gap-2"
                  >
                    {saving ? <Loader size={16} className="animate-spin" /> : <Save size={16} />}
                    Assign to Selected ({selectedIds.length})
                  </button>
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={handleSeedDefaults}
                    className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white font-semibold rounded-lg hover:bg-green-700 transition shadow-sm text-sm whitespace-nowrap"
                  >
                    <Activity size={16} /> Sync Base Diseases
                  </button>
                  {!showCreate && (
                    <button
                      onClick={() => setShowCreate(true)}
                      className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white font-semibold rounded-lg hover:bg-indigo-700 transition shadow-sm text-sm whitespace-nowrap"
                    >
                      <Plus size={16} /> Add Custom Diagnosis
                    </button>
                  )}
                </div>
              </div>

              {showCreate && (
                <ItemForm
                  onSave={handleCreateDiagnosis}
                  onCancel={() => setShowCreate(false)}
                  saving={saving}
                />
              )}

              <div className="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100">
                {loading ? (
                  <div className="flex items-center justify-center py-20 text-gray-500">
                    <Loader size={28} className="animate-spin mr-3 text-indigo-500" />
                    <span>Loading diagnoses...</span>
                  </div>
                ) : items.length === 0 ? (
                  <div className="text-center py-20 text-gray-400">
                    <Activity size={48} className="mx-auto mb-4 opacity-30" />
                    <p className="text-lg font-medium">No diagnoses yet.</p>
                  </div>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-100">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider w-12">
                            <button onClick={toggleAll} className="text-gray-500 hover:text-indigo-600">
                              {selectedIds.length === items.length && items.length > 0 ? (
                                <CheckSquare size={18} className="text-indigo-600" />
                              ) : (
                                <Square size={18} />
                              )}
                            </button>
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Diagnosis Name</th>
                          <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Type</th>
                          <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Assigned Category</th>
                          <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Assigned Subcategory</th>
                          <th className="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-100 bg-white">
                        {items.map((item) => (
                          <tr key={item.id} className={`transition-colors hover:bg-indigo-50/50 ${selectedIds.includes(item.id) ? 'bg-indigo-50/30' : ''}`}>
                            <td className="px-6 py-4">
                              <button onClick={() => toggleSelection(item.id)} className="text-gray-400 hover:text-indigo-600">
                                {selectedIds.includes(item.id) ? (
                                  <CheckSquare size={18} className="text-indigo-600" />
                                ) : (
                                  <Square size={18} />
                                )}
                              </button>
                            </td>
                            <td className="px-6 py-4 text-sm font-semibold text-gray-800">{item.name}</td>
                            <td className="px-6 py-4 text-sm">
                              {item.is_custom ? (
                                <span className="px-2 py-1 text-[10px] font-bold bg-blue-100 text-blue-800 rounded-full uppercase tracking-wide">Custom</span>
                              ) : (
                                <span className="px-2 py-1 text-[10px] font-bold bg-gray-100 text-gray-600 rounded-full uppercase tracking-wide">Base</span>
                              )}
                            </td>
                            <td className="px-6 py-4 text-sm text-gray-600">
                              {item.category ? (
                                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-purple-50 text-purple-700 border border-purple-100">
                                  <FolderTree size={14} /> {item.category.name}
                                </span>
                              ) : <span className="text-gray-300 italic">Unassigned</span>}
                            </td>
                            <td className="px-6 py-4 text-sm text-gray-600">
                              {item.subcategory ? (
                                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-indigo-50 text-indigo-700 border border-indigo-100">
                                  <List size={14} /> {item.subcategory.name}
                                </span>
                              ) : <span className="text-gray-300 italic">Unassigned</span>}
                            </td>
                            <td className="px-6 py-4 text-right">
                              {item.is_custom && (
                                <button
                                  onClick={() => handleDeleteDiagnosis(item.id)}
                                  disabled={deleting === item.id}
                                  className="p-1.5 rounded-lg text-red-500 hover:bg-red-50 transition disabled:opacity-40"
                                  title="Delete Custom Diagnosis"
                                >
                                  {deleting === item.id ? <Loader size={16} className="animate-spin" /> : <Trash2 size={16} />}
                                </button>
                              )}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* TAB 2: CATEGORIES & SUBCATEGORIES */}
          {activeTab === "categories" && (
            <div>
              <div className="flex justify-end mb-6">
                {!showCatForm && (
                  <button
                    onClick={() => {
                      setCatForm({ name: "", description: "" });
                      setEditingCat(null);
                      setShowCatForm(true);
                    }}
                    className="flex items-center gap-2 px-5 py-2.5 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 transition shadow-md text-sm"
                  >
                    <Plus size={18} /> Add Category
                  </button>
                )}
              </div>

              {showCatForm && (
                <form onSubmit={handleSaveCat} className="bg-white p-6 rounded-2xl shadow-lg border border-indigo-100 mb-6">
                  <h3 className="text-lg font-bold text-gray-800 mb-4">{editingCat ? "Edit Category" : "New Category"}</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1">Name *</label>
                      <input
                        type="text"
                        required
                        value={catForm.name}
                        onChange={e => setCatForm({...catForm, name: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                        placeholder="e.g. Neoplasms"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1">Description</label>
                      <input
                        type="text"
                        value={catForm.description}
                        onChange={e => setCatForm({...catForm, description: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                      />
                    </div>
                  </div>
                  <div className="flex justify-end gap-2">
                    <button type="button" onClick={() => setShowCatForm(false)} className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 text-sm font-medium">Cancel</button>
                    <button type="submit" disabled={saving} className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 text-sm font-medium flex items-center gap-2">
                      {saving ? <Loader size={16} className="animate-spin" /> : <Save size={16} />} Save
                    </button>
                  </div>
                </form>
              )}

              {loading && categories.length === 0 ? (
                <div className="flex justify-center py-10"><Loader className="animate-spin text-indigo-500" size={30} /></div>
              ) : categories.length === 0 ? (
                <div className="text-center py-20 bg-white rounded-2xl border border-gray-100">
                  <FolderTree size={48} className="mx-auto text-gray-300 mb-4" />
                  <p className="text-gray-500">No categories found. Create one to organize diagnoses.</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {categories.map(category => (
                    <div key={category.id} className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                      {/* Category Header */}
                      <div className="bg-gray-50 px-5 py-4 flex items-center justify-between border-b border-gray-100">
                        <div className="flex items-center gap-3">
                          <button 
                            onClick={() => setExpandedCats(prev => ({...prev, [category.id]: !prev[category.id]}))}
                            className="p-1 text-gray-500 hover:text-indigo-600 hover:bg-indigo-50 rounded"
                          >
                            {expandedCats[category.id] ? <ChevronDown size={20} /> : <ChevronRight size={20} />}
                          </button>
                          <div>
                            <h3 className="font-bold text-gray-800 text-lg flex items-center gap-2">
                              <FolderTree size={18} className="text-indigo-500" />
                              {category.name}
                            </h3>
                            {category.description && <p className="text-xs text-gray-500 mt-0.5">{category.description}</p>}
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-medium bg-white px-2 py-1 rounded-md border text-gray-500">
                            {category.subcategories?.length || 0} subs
                          </span>
                          <button
                            onClick={() => {
                              setCatForm({ name: category.name, description: category.description || "" });
                              setEditingCat(category);
                              setShowCatForm(true);
                            }}
                            className="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition"
                          >
                            <Pencil size={16} />
                          </button>
                          <button
                            onClick={() => handleDeleteCat(category.id)}
                            className="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition"
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </div>

                      {/* Subcategories Area */}
                      {expandedCats[category.id] && (
                        <div className="p-5 bg-white">
                          
                          {/* Subcategory List */}
                          {category.subcategories && category.subcategories.length > 0 ? (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 mb-4">
                              {category.subcategories.map(sub => (
                                <div key={sub.id} className="border border-indigo-100 bg-indigo-50/30 rounded-lg p-3 flex justify-between items-start group">
                                  <div>
                                    <h4 className="font-semibold text-sm text-gray-800">{sub.name}</h4>
                                    {sub.description && <p className="text-xs text-gray-500 mt-1 line-clamp-2">{sub.description}</p>}
                                  </div>
                                  <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button 
                                      onClick={() => {
                                        setSubForm({ name: sub.name, description: sub.description || "" });
                                        setEditingSub(sub);
                                        setShowSubFormFor(category.id);
                                      }}
                                      className="p-1 text-gray-400 hover:text-blue-600 bg-white rounded shadow-sm"
                                    ><Pencil size={12} /></button>
                                    <button 
                                      onClick={() => handleDeleteSub(category.id, sub.id)}
                                      className="p-1 text-gray-400 hover:text-red-600 bg-white rounded shadow-sm"
                                    ><Trash2 size={12} /></button>
                                  </div>
                                </div>
                              ))}
                            </div>
                          ) : (
                            <p className="text-sm text-gray-400 italic mb-4">No subcategories added yet.</p>
                          )}

                          {/* Add/Edit Subcategory Form */}
                          {showSubFormFor === category.id ? (
                            <form onSubmit={(e) => handleSaveSub(e, category.id)} className="bg-gray-50 p-4 rounded-xl border border-gray-200">
                              <h4 className="text-sm font-bold text-gray-700 mb-3">{editingSub ? "Edit Subcategory" : "New Subcategory"}</h4>
                              <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
                                <div>
                                  <input type="text" required placeholder="Subcategory Name" value={subForm.name} onChange={e => setSubForm({...subForm, name: e.target.value})} className="w-full text-sm px-3 py-2 border rounded-md" />
                                </div>
                                <div>
                                  <input type="text" placeholder="Description (optional)" value={subForm.description} onChange={e => setSubForm({...subForm, description: e.target.value})} className="w-full text-sm px-3 py-2 border rounded-md" />
                                </div>
                              </div>
                              <div className="flex justify-end gap-2">
                                <button type="button" onClick={() => setShowSubFormFor(null)} className="px-3 py-1.5 border border-gray-300 rounded text-xs font-medium">Cancel</button>
                                <button type="submit" disabled={saving} className="px-3 py-1.5 bg-indigo-600 text-white rounded text-xs font-medium">{saving ? "Saving..." : "Save Subcategory"}</button>
                              </div>
                            </form>
                          ) : (
                            <button 
                              onClick={() => {
                                setSubForm({ name: "", description: "" });
                                setEditingSub(null);
                                setShowSubFormFor(category.id);
                              }}
                              className="text-sm text-indigo-600 hover:text-indigo-800 font-medium flex items-center gap-1"
                            >
                              <Plus size={16} /> Add Subcategory
                            </button>
                          )}

                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

        </div>
      </div>
    </DashboardLayout>
  );
};

export default DiagnosesManagement;
