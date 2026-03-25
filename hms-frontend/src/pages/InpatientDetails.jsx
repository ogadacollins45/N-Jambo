import React, { useEffect, useState, useContext } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import DashboardLayout from "../layout/DashboardLayout";
import { AuthContext } from "../context/AuthContext";
import AddPrescriptionModal from "../components/AddPrescriptionModal";
import {
  ChevronLeft, Loader, AlertCircle, CheckCircle, X,
  BedDouble, User, Clock, Stethoscope, Activity,
  PlusCircle, ClipboardList, LogOut, CreditCard, Pill, Trash2, Microscope,
} from "lucide-react";

const InpatientDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useContext(AuthContext);

  const [admission, setAdmission] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [activeTab, setActiveTab] = useState("summary");

  // Cardex entry form
  const [showEntryForm, setShowEntryForm] = useState(false);
  const [entryForm, setEntryForm] = useState({ bp: "", pulse: "", temp: "", spo2: "", note: "", recorded_at: "" });
  const [savingEntry, setSavingEntry] = useState(false);

  // Discharge form
  const [showDischargeModal, setShowDischargeModal] = useState(false);
  const [dischargeNote, setDischargeNote] = useState("");
  const [discharging, setDischarging] = useState(false);

  // Prescription modal & state
  const [showPrescriptionModal, setShowPrescriptionModal] = useState(false);
  const [expandedPrescriptions, setExpandedPrescriptions] = useState({});

  // Lab request states
  const [availableTests, setAvailableTests] = useState([]);
  const [showLabTestModal, setShowLabTestModal] = useState(false);
  const [selectedTests, setSelectedTests] = useState([]);
  const [labPriority, setLabPriority] = useState("routine");
  const [submittingLabRequest, setSubmittingLabRequest] = useState(false);
  const [labRequests, setLabRequests] = useState([]);
  const [expandedLabRequests, setExpandedLabRequests] = useState({});

  const API_BASE = `${import.meta.env.VITE_API_BASE_URL}/api`;

  const flashMessage = (setter, message) => {
    setter(message);
    setTimeout(() => setter(""), 4000);
  };

  const fetchAdmission = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_BASE}/admissions/${id}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });
      setAdmission(res.data);

      // Fetch lab requests for this patient filtered by admission
      const lrRes = await axios.get(`${API_BASE}/lab/requests/patient/${res.data.patient_id}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });
      const admissionLabRequests = (lrRes.data || []).filter(
        (lr) => lr.admission_id === parseInt(id)
      );
      setLabRequests(admissionLabRequests);
    } catch (err) {
      console.error("Error fetching admission:", err);
      setError("Failed to load admission data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAdmission();

    const loadLabTests = async () => {
      try {
        const response = await axios.get(`${API_BASE}/lab/tests/available`, {
          headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
        });
        const allTests = Object.values(response.data).flat();
        setAvailableTests(allTests);
      } catch (err) {
        console.error("Error loading lab tests:", err);
      }
    };
    loadLabTests();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const handleAddEntry = async (e) => {
    e.preventDefault();
    setSavingEntry(true);
    try {
      await axios.post(`${API_BASE}/admissions/${id}/entries`, entryForm, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });
      flashMessage(setSuccess, "Entry recorded successfully.");
      setEntryForm({ bp: "", pulse: "", temp: "", spo2: "", note: "", recorded_at: "" });
      setShowEntryForm(false);
      await fetchAdmission();
    } catch (err) {
      flashMessage(setError, err.response?.data?.message || "Failed to save entry.");
    } finally {
      setSavingEntry(false);
    }
  };

  const handleDischarge = async () => {
    setDischarging(true);
    try {
      await axios.post(
        `${API_BASE}/admissions/${id}/discharge`,
        { discharge_note: dischargeNote },
        { headers: { Authorization: `Bearer ${localStorage.getItem("token")}` } }
      );
      flashMessage(setSuccess, "Patient discharged successfully.");
      setShowDischargeModal(false);
      await fetchAdmission();
    } catch (err) {
      flashMessage(setError, err.response?.data?.message || "Failed to discharge patient.");
    } finally {
      setDischarging(false);
    }
  };

  const handleDeletePrescription = async (prescriptionId) => {
    if (!window.confirm("Are you sure you want to delete this prescription? This action cannot be undone.")) return;
    try {
      await axios.delete(`${API_BASE}/prescriptions/${prescriptionId}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });
      flashMessage(setSuccess, "Prescription deleted successfully.");
      fetchAdmission();
    } catch (err) {
      flashMessage(setError, err.response?.data?.message || "Failed to delete prescription.");
    }
  };

  const handleAddLabTest = async (e) => {
    e.preventDefault();
    if (selectedTests.length === 0) { flashMessage(setError, "Please select at least one test."); return; }

    setSubmittingLabRequest(true);
    try {
      const payload = {
        patient_id: admission.patient_id,
        admission_id: admission.id,
        priority: labPriority,
        clinical_notes: `Inpatient Request - ${admission.ward} Ward`,
        test_ids: selectedTests,
      };
      if (admission.doctor_id) payload.doctor_id = admission.doctor_id;

      await axios.post(`${API_BASE}/lab/requests`, payload, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });

      flashMessage(setSuccess, "Lab tests requested successfully.");
      setShowLabTestModal(false);
      setSelectedTests([]);
      setLabPriority("routine");
      await fetchAdmission();
    } catch (err) {
      flashMessage(setError, err.response?.data?.message || "Failed to request lab tests.");
    } finally {
      setSubmittingLabRequest(false);
    }
  };

  const toggleTest = (testId) => {
    setSelectedTests((prev) =>
      prev.includes(testId) ? prev.filter((t) => t !== testId) : [...prev, testId]
    );
  };

  const formatDateTime = (dt) => {
    if (!dt) return "—";
    return new Date(dt).toLocaleString("en-GB", {
      day: "2-digit", month: "short", year: "numeric",
      hour: "2-digit", minute: "2-digit",
    });
  };

  const statusBadge = (status) => {
    const map = {
      active: "bg-green-100 text-green-700 border border-green-300",
      discharged: "bg-gray-100 text-gray-600 border border-gray-300",
      transferred: "bg-blue-100 text-blue-700 border border-blue-300",
    };
    return map[status] || "bg-gray-100 text-gray-600";
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex justify-center items-center h-screen">
          <Loader className="animate-spin h-10 w-10 text-indigo-500" />
          <p className="ml-3 text-lg text-gray-600">Loading admission...</p>
        </div>
      </DashboardLayout>
    );
  }

  if (!admission) {
    return (
      <DashboardLayout>
        <div className="text-center py-20">
          <AlertCircle className="mx-auto h-12 w-12 text-red-500" />
          <p className="mt-4 text-gray-600">{error || "Admission not found."}</p>
        </div>
      </DashboardLayout>
    );
  }

  const patient = admission.patient;
  const doctor = admission.doctor;
  const entries = admission.entries || [];
  const prescriptions = admission.prescriptions || [];
  const isActive = admission.status === "active";
  const canDischarge = isActive && ["admin", "doctor", "reception"].includes(user?.role);

  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gray-50 pt-6">
        <div className="w-full">
          <div className="bg-white rounded-2xl shadow-xl overflow-hidden w-full">
            <div className="p-6 sm:p-8">

              {/* NOTIFICATIONS */}
              {error && (
                <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg flex items-center shadow-md">
                  <AlertCircle className="w-6 h-6 mr-3" />
                  <div><p className="font-bold">Error</p><p>{error}</p></div>
                </div>
              )}
              {success && (
                <div className="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg flex items-center shadow-md">
                  <CheckCircle className="w-6 h-6 mr-3" />
                  <div><p className="font-bold">Success</p><p>{success}</p></div>
                </div>
              )}

              {/* HEADER */}
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6 pb-4 border-b border-gray-200">
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => navigate(`/admissions`)}
                    className="p-2 rounded-full hover:bg-gray-200 transition-colors"
                  >
                    <ChevronLeft className="w-6 h-6 text-gray-600" />
                  </button>
                  <div>
                    <div className="flex items-center gap-2">
                      <BedDouble className="w-5 h-5 text-indigo-600" />
                      <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">
                        {patient?.first_name} {patient?.last_name}
                      </h1>
                    </div>
                    <p className="text-sm text-gray-500 ml-7">
                      UPID: {patient?.upid} &bull; {patient?.gender} &bull; Age {patient?.age}
                    </p>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-3">
                  <span className={`px-3 py-1 rounded-full text-sm font-semibold uppercase ${statusBadge(admission.status)}`}>
                    {admission.status === "active" ? "🏥 Active Inpatient" : admission.status.replace("_", " ")}
                  </span>

                  {admission.bill && (
                    <button
                      onClick={() => navigate(`/bills/${admission.bill.id}`)}
                      className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all text-sm font-medium shadow-sm"
                    >
                      <CreditCard size={15} className="mr-1.5" /> View Bill
                    </button>
                  )}

                  {canDischarge && (
                    <button
                      onClick={() => setShowDischargeModal(true)}
                      className="flex items-center px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-all text-sm font-medium shadow-sm"
                    >
                      <LogOut size={15} className="mr-1.5" /> Discharge
                    </button>
                  )}
                </div>
              </div>

              {/* TABS */}
              <div className="flex gap-1 border-b border-gray-200 mb-6 overflow-x-auto whitespace-nowrap">
                {[
                  { key: "summary", label: "Admission Summary", icon: <ClipboardList size={14} /> },
                  { key: "cardex", label: `Cardex / Timeline (${entries.length})`, icon: <Activity size={14} /> },
                  { key: "prescriptions", label: `Prescriptions (${prescriptions.length})`, icon: <Pill size={14} /> },
                  { key: "lab_tests", label: `Lab Tests (${labRequests.length})`, icon: <Microscope size={14} /> },
                ].map((tab) => (
                  <button
                    key={tab.key}
                    onClick={() => setActiveTab(tab.key)}
                    className={`flex items-center gap-1.5 px-5 py-3 text-sm font-medium border-b-2 transition-colors ${activeTab === tab.key
                      ? "border-indigo-600 text-indigo-600"
                      : "border-transparent text-gray-500 hover:text-gray-700"
                    }`}
                  >
                    {tab.icon} {tab.label}
                  </button>
                ))}
              </div>

              {/* ===== SUMMARY TAB ===== */}
              {activeTab === "summary" && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-indigo-50 rounded-xl p-5 border border-indigo-100">
                    <h3 className="text-base font-semibold text-indigo-800 mb-4 flex items-center gap-2">
                      <BedDouble size={16} /> Admission Details
                    </h3>
                    <dl className="space-y-2.5 text-sm">
                      {[
                        { label: "Ward", value: admission.ward },
                        { label: "Bed / Room", value: admission.bed || "—" },
                        { label: "Type", value: <span className="capitalize">{admission.admission_type}</span> },
                        { label: "Payment Type", value: <span className="capitalize">{admission.payment_type || "—"}</span> },
                        { label: "Admitted At", value: formatDateTime(admission.admitted_at) },
                        admission.discharged_at ? { label: "Discharged At", value: formatDateTime(admission.discharged_at) } : null,
                      ].filter(Boolean).map(({ label, value }) => (
                        <div key={label} className="flex justify-between">
                          <dt className="text-gray-500">{label}</dt>
                          <dd className="font-medium text-gray-800">{value}</dd>
                        </div>
                      ))}
                    </dl>
                  </div>

                  <div className="bg-gray-50 rounded-xl p-5 border border-gray-200">
                    <h3 className="text-base font-semibold text-gray-800 mb-4 flex items-center gap-2">
                      <Stethoscope size={16} /> Clinical
                    </h3>
                    <dl className="space-y-2.5 text-sm">
                      <div className="flex justify-between">
                        <dt className="text-gray-500">Admitting Doctor</dt>
                        <dd className="font-medium text-gray-800">
                          {doctor ? `Dr. ${doctor.first_name} ${doctor.last_name}` : "—"}
                        </dd>
                      </div>
                      <div className="flex flex-col gap-1">
                        <dt className="text-gray-500">Reason / Provisional Dx</dt>
                        <dd className="font-medium text-gray-800 bg-white rounded p-2 border border-gray-200 mt-1">
                          {admission.reason || <span className="italic text-gray-400">None recorded</span>}
                        </dd>
                      </div>
                      {admission.discharge_note && (
                        <div className="flex flex-col gap-1 mt-2">
                          <dt className="text-gray-500 font-medium text-orange-700">Discharge Note</dt>
                          <dd className="font-medium text-gray-800 bg-orange-50 rounded p-2 border border-orange-200 mt-1">
                            {admission.discharge_note}
                          </dd>
                        </div>
                      )}
                    </dl>
                  </div>
                </div>
              )}

              {/* ===== CARDEX TAB ===== */}
              {activeTab === "cardex" && (
                <div>
                  {isActive && (
                    <div className="mb-5 flex flex-wrap gap-3">
                      <button
                        onClick={() => {
                          if (!showEntryForm) {
                            const now = new Date();
                            const localISOTime = new Date(now - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
                            setEntryForm((prev) => ({ ...prev, recorded_at: localISOTime }));
                          }
                          setShowEntryForm((v) => !v);
                        }}
                        className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-all font-medium shadow-sm"
                      >
                        <PlusCircle size={16} />
                        {showEntryForm ? "Cancel" : "Add Cardex Entry"}
                      </button>
                      <button
                        onClick={() => setShowPrescriptionModal(true)}
                        className="flex items-center gap-2 px-4 py-2.5 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-all font-medium shadow-sm"
                      >
                        <Pill size={16} /> Add Prescription
                      </button>
                    </div>
                  )}

                  {showEntryForm && (
                    <form onSubmit={handleAddEntry} className="bg-indigo-50 border border-indigo-200 rounded-xl p-5 mb-6">
                      <h4 className="text-sm font-semibold text-indigo-800 mb-4">New Cardex Entry</h4>
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                        {[
                          { name: "bp", label: "Blood Pressure", placeholder: "120/80" },
                          { name: "pulse", label: "Pulse", placeholder: "72 bpm" },
                          { name: "temp", label: "Temperature", placeholder: "36.6°C" },
                          { name: "spo2", label: "SpO₂", placeholder: "98%" },
                        ].map(({ name, label, placeholder }) => (
                          <div key={name}>
                            <label className="block text-xs font-medium text-gray-600 mb-1">{label}</label>
                            <input
                              type="text"
                              name={name}
                              placeholder={placeholder}
                              value={entryForm[name]}
                              onChange={(e) => setEntryForm((prev) => ({ ...prev, [name]: e.target.value }))}
                              className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-400"
                            />
                          </div>
                        ))}
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div>
                          <label className="block text-xs font-medium text-gray-600 mb-1">Recorded At (optional)</label>
                          <input
                            type="datetime-local"
                            name="recorded_at"
                            value={entryForm.recorded_at}
                            onChange={(e) => setEntryForm((prev) => ({ ...prev, recorded_at: e.target.value }))}
                            className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-400"
                          />
                        </div>
                      </div>
                      <div className="mb-4">
                        <label className="block text-xs font-medium text-gray-600 mb-1">Nursing Note / Observation</label>
                        <textarea
                          name="note"
                          rows={3}
                          placeholder="Patient observation, nursing notes, condition update..."
                          value={entryForm.note}
                          onChange={(e) => setEntryForm((prev) => ({ ...prev, note: e.target.value }))}
                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-400 resize-none"
                        />
                      </div>
                      <div className="flex justify-end gap-3">
                        <button type="button" onClick={() => setShowEntryForm(false)} className="px-4 py-2 text-sm text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50">
                          Cancel
                        </button>
                        <button type="submit" disabled={savingEntry} className="px-4 py-2 text-sm bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 font-medium">
                          {savingEntry ? "Saving..." : "Save Entry"}
                        </button>
                      </div>
                    </form>
                  )}

                  {entries.length === 0 ? (
                    <div className="text-center py-12 text-gray-400">
                      <Activity className="mx-auto h-12 w-12 mb-3 text-gray-300" />
                      <p className="font-medium">No entries yet.</p>
                      <p className="text-sm">Add a Cardex entry to start the inpatient timeline.</p>
                    </div>
                  ) : (
                    <div className="relative">
                      <div className="absolute left-4 top-0 bottom-0 w-0.5 bg-indigo-100" />
                      <div className="space-y-4 pl-10">
                        {entries.map((entry) => (
                          <div key={entry.id} className="bg-white rounded-xl border border-gray-200 shadow-sm p-4 relative">
                            <div className="absolute -left-6 top-4 w-3 h-3 rounded-full bg-indigo-500 border-2 border-white shadow" />
                            <div className="flex items-center justify-between mb-3">
                              <div className="flex items-center gap-2 text-xs text-gray-500">
                                <Clock size={12} />
                                <span className="font-medium text-gray-700">{formatDateTime(entry.recorded_at)}</span>
                              </div>
                              {entry.user && (
                                <div className="text-xs font-medium text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded-full">
                                  {entry.user.name}
                                </div>
                              )}
                            </div>
                            {(entry.bp || entry.pulse || entry.temp || entry.spo2) && (
                              <div className="flex flex-wrap gap-3 mb-3">
                                {entry.bp && <span className="bg-red-50 text-red-700 px-2.5 py-1 rounded-lg text-xs font-medium border border-red-100">❤️ BP: {entry.bp}</span>}
                                {entry.pulse && <span className="bg-pink-50 text-pink-700 px-2.5 py-1 rounded-lg text-xs font-medium border border-pink-100">💓 Pulse: {entry.pulse}</span>}
                                {entry.temp && <span className="bg-orange-50 text-orange-700 px-2.5 py-1 rounded-lg text-xs font-medium border border-orange-100">🌡️ Temp: {entry.temp}</span>}
                                {entry.spo2 && <span className="bg-blue-50 text-blue-700 px-2.5 py-1 rounded-lg text-xs font-medium border border-blue-100">🫁 SpO₂: {entry.spo2}</span>}
                              </div>
                            )}
                            {entry.note && <p className="text-sm text-gray-700 leading-relaxed">{entry.note}</p>}
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* ===== PRESCRIPTIONS TAB ===== */}
              {activeTab === "prescriptions" && (
                <div>
                  {isActive && (
                    <div className="mb-5">
                      <button
                        onClick={() => setShowPrescriptionModal(true)}
                        className="flex items-center gap-2 px-4 py-2.5 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium shadow-sm"
                      >
                        <Pill size={16} /> Add Prescription
                      </button>
                    </div>
                  )}
                  {prescriptions.length === 0 ? (
                    <div className="text-center py-12 text-gray-400">
                      <Pill className="mx-auto h-12 w-12 mb-3 text-gray-300" />
                      <p className="font-medium">No prescriptions yet.</p>
                      <p className="text-sm">Prescribe medications for this inpatient admission here.</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {prescriptions.map((p) => (
                        <div key={p.id} className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
                          <div className="flex justify-between items-center mb-3">
                            <div className="flex items-center gap-2">
                              <div className="bg-indigo-100 p-2 rounded-lg"><Pill size={18} className="text-indigo-600" /></div>
                              <div>
                                <p className="font-semibold text-gray-800">Prescription #{p.id}</p>
                                <p className="text-xs text-gray-500">{formatDateTime(p.created_at)}</p>
                              </div>
                            </div>
                            <div className="flex items-center gap-3">
                              <span className="text-xs font-medium bg-gray-100 px-2.5 py-1 rounded-md text-gray-700">{p.items?.length || 0} items</span>
                              {p.pharmacy_status !== "dispensed" && (
                                <button
                                  onClick={() => handleDeletePrescription(p.id)}
                                  className="p-1.5 text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                  title="Delete Prescription"
                                >
                                  <Trash2 size={16} />
                                </button>
                              )}
                            </div>
                          </div>
                          {expandedPrescriptions[p.id] ? (
                            <div className="space-y-3 mt-4 text-sm bg-gray-50 rounded-lg p-3 border border-gray-100">
                              {p.items?.map((item, idx) => (
                                <div key={idx} className="border-l-4 border-indigo-300 bg-indigo-50 p-3 rounded">
                                  <p className="font-semibold text-indigo-900">{item.drug_name_text || item.name}</p>
                                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs mt-1">
                                    {item.dosage_text && <div><span className="text-gray-500 block">Dosage</span><span>{item.dosage_text}</span></div>}
                                    {item.frequency_text && <div><span className="text-gray-500 block">Frequency</span><span>{item.frequency_text}</span></div>}
                                    {item.duration_text && <div><span className="text-gray-500 block">Duration</span><span>{item.duration_text}</span></div>}
                                  </div>
                                </div>
                              ))}
                              <div className="flex justify-end">
                                <button onClick={() => setExpandedPrescriptions((prev) => ({ ...prev, [p.id]: false }))} className="text-xs font-semibold text-indigo-600 hover:text-indigo-800">
                                  Hide Contents ↑
                                </button>
                              </div>
                            </div>
                          ) : (
                            <div className="flex justify-end border-t border-gray-100 pt-3 mt-3">
                              <button onClick={() => setExpandedPrescriptions((prev) => ({ ...prev, [p.id]: true }))} className="text-xs font-semibold text-indigo-600 hover:text-indigo-800">
                                View {p.items?.length} Items ↓
                              </button>
                            </div>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* ===== LAB TESTS TAB ===== */}
              {activeTab === "lab_tests" && (
                <div>
                  {isActive && (
                    <div className="mb-5">
                      <button
                        onClick={() => setShowLabTestModal(true)}
                        className="flex items-center gap-2 px-4 py-2.5 bg-teal-600 text-white rounded-lg hover:bg-teal-700 font-medium shadow-sm"
                      >
                        <Microscope size={16} /> Request Lab Test
                      </button>
                    </div>
                  )}

                  {showLabTestModal && (
                    <div className="bg-teal-50 border border-teal-200 rounded-xl p-5 mb-6">
                      <div className="flex justify-between items-center mb-4">
                        <h4 className="text-sm font-semibold text-teal-800 flex items-center gap-2">
                          <Microscope size={16} /> New Lab Request
                        </h4>
                        <button onClick={() => setShowLabTestModal(false)} className="text-gray-500 hover:text-gray-700">
                          <X size={18} />
                        </button>
                      </div>
                      <form onSubmit={handleAddLabTest}>
                        <div className="mb-4">
                          <label className="block text-sm font-medium text-gray-700 mb-2">Select Tests</label>
                          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-h-60 overflow-y-auto p-3 border border-gray-200 rounded-lg bg-white">
                            {availableTests.map((test) => (
                              <label
                                key={test.id}
                                className={`flex items-start gap-3 p-3 rounded-lg border cursor-pointer transition-all ${selectedTests.includes(test.id)
                                  ? "border-teal-500 bg-teal-50/50"
                                  : "border-gray-200 bg-white hover:border-teal-300"
                                }`}
                              >
                                <input
                                  type="checkbox"
                                  checked={selectedTests.includes(test.id)}
                                  onChange={() => toggleTest(test.id)}
                                  className="mt-0.5"
                                />
                                <div>
                                  <p className="text-sm font-medium text-gray-800">{test.name}</p>
                                  {test.price > 0 && <p className="text-xs text-gray-500">KES {test.price}</p>}
                                </div>
                              </label>
                            ))}
                          </div>
                        </div>
                        <div className="mb-4">
                          <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
                          <select
                            value={labPriority}
                            onChange={(e) => setLabPriority(e.target.value)}
                            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-teal-200"
                          >
                            <option value="routine">Routine</option>
                            <option value="urgent">Urgent</option>
                            <option value="stat">STAT</option>
                          </select>
                        </div>
                        <div className="flex justify-end gap-3">
                          <button type="button" onClick={() => setShowLabTestModal(false)} className="px-4 py-2 text-sm text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50">
                            Cancel
                          </button>
                          <button type="submit" disabled={submittingLabRequest || selectedTests.length === 0} className="px-4 py-2 text-sm bg-teal-600 text-white rounded-lg hover:bg-teal-700 disabled:opacity-50 font-medium">
                            {submittingLabRequest ? "Submitting..." : `Request ${selectedTests.length} Test${selectedTests.length !== 1 ? "s" : ""}`}
                          </button>
                        </div>
                      </form>
                    </div>
                  )}

                  {labRequests.length === 0 ? (
                    <div className="text-center py-12 text-gray-400">
                      <Microscope className="mx-auto h-12 w-12 mb-3 text-gray-300" />
                      <p className="font-medium">No lab tests requested yet.</p>
                      <p className="text-sm">Request lab tests for this admission using the button above.</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {labRequests.map((lr) => (
                        <div key={lr.id} className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
                          <div className="flex justify-between items-center mb-2">
                            <div>
                              <p className="font-semibold text-gray-800">{lr.request_number}</p>
                              <p className="text-xs text-gray-500">{formatDateTime(lr.request_date || lr.created_at)}</p>
                            </div>
                            <span className={`px-2.5 py-1 rounded-full text-xs font-semibold capitalize ${lr.status === "completed"
                              ? "bg-green-100 text-green-800"
                              : lr.status === "processing"
                              ? "bg-blue-100 text-blue-800"
                              : "bg-yellow-100 text-yellow-800"
                            }`}>{lr.status}</span>
                          </div>
                          {expandedLabRequests[lr.id] ? (
                            <div>
                              <div className="space-y-2 mt-3">
                                {lr.tests?.map((t) => (
                                  <div key={t.id} className="flex justify-between text-sm bg-gray-50 rounded-lg p-2">
                                    <span className="text-gray-700">{t.template?.name || "Unknown Test"}</span>
                                    <span className={`text-xs font-medium capitalize ${t.status === "completed" ? "text-green-600" : "text-gray-500"}`}>{t.status}</span>
                                  </div>
                                ))}
                              </div>
                              <button onClick={() => setExpandedLabRequests((prev) => ({ ...prev, [lr.id]: false }))} className="mt-3 text-xs font-semibold text-teal-600 hover:text-teal-800">
                                Hide Tests ↑
                              </button>
                            </div>
                          ) : (
                            <button onClick={() => setExpandedLabRequests((prev) => ({ ...prev, [lr.id]: true }))} className="text-xs font-semibold text-teal-600 hover:text-teal-800">
                              View {lr.tests?.length} Test{lr.tests?.length !== 1 ? "s" : ""} ↓
                            </button>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

            </div>
          </div>
        </div>
      </div>

      {/* PRESCRIPTION MODAL */}
      {showPrescriptionModal && (
        <AddPrescriptionModal
          patientId={admission.patient_id}
          admissionId={admission.id}
          onClose={() => setShowPrescriptionModal(false)}
          onSuccess={() => { setShowPrescriptionModal(false); fetchAdmission(); flashMessage(setSuccess, "Prescription added successfully."); }}
        />
      )}

      {/* DISCHARGE MODAL */}
      {showDischargeModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-bold text-gray-800">Discharge Patient</h2>
              <button onClick={() => setShowDischargeModal(false)} className="p-2 rounded-full hover:bg-gray-100">
                <X className="w-5 h-5 text-gray-500" />
              </button>
            </div>
            <p className="text-sm text-gray-600 mb-4">
              Discharging <strong>{patient?.first_name} {patient?.last_name}</strong> from {admission.ward} Ward.
            </p>
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Discharge Note (optional)</label>
              <textarea
                value={dischargeNote}
                onChange={(e) => setDischargeNote(e.target.value)}
                rows={4}
                placeholder="Discharge summary, follow-up instructions..."
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-orange-200 resize-none"
              />
            </div>
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setShowDischargeModal(false)}
                className="px-4 py-2 text-sm text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={handleDischarge}
                disabled={discharging}
                className="px-5 py-2 text-sm bg-orange-600 text-white rounded-lg hover:bg-orange-700 disabled:opacity-50 font-medium"
              >
                {discharging ? "Discharging..." : "Confirm Discharge"}
              </button>
            </div>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
};

export default InpatientDetails;
