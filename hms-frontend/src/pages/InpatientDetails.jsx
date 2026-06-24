import React, { useEffect, useState, useContext } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import DashboardLayout from "../layout/DashboardLayout";
import { AuthContext } from "../context/AuthContext";
import AddPrescriptionModal from "../components/AddPrescriptionModal";
import SearchableDiagnosisDropdown from "../components/SearchableDiagnosisDropdown";
import {
  ChevronLeft, Loader, AlertCircle, CheckCircle, X,
  BedDouble, User, Clock, Stethoscope, Activity, FileText,
  PlusCircle, ClipboardList, LogOut, CreditCard, Pill, Trash2, Microscope, Pencil,
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
  const [editingEntryId, setEditingEntryId] = useState(null);
  const [savingEntry, setSavingEntry] = useState(false);

  // Clinical Notes form
  const [showClinicalNoteForm, setShowClinicalNoteForm] = useState(false);
  const [clinicalNoteForm, setClinicalNoteForm] = useState({
      chief_complaint: "", general_exam: "", systemic_exam: "", diagnosis: "", plan_notes: ""
  });
  const [savingClinicalNote, setSavingClinicalNote] = useState(false);
  const [otherDiagnosis, setOtherDiagnosis] = useState(""); // Used if "All Other Diseases"

  // Treatment Notes form
  const [showTreatmentNoteForm, setShowTreatmentNoteForm] = useState(false);
  const [treatmentNoteForm, setTreatmentNoteForm] = useState({
      type: "", medication: "", dosage: "", route: "", directions: "", frequency: ""
  });
  const [savingTreatmentNote, setSavingTreatmentNote] = useState(false);

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
      if (editingEntryId) {
        await axios.put(`${API_BASE}/admissions/${id}/entries/${editingEntryId}`, entryForm, {
          headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
        });
      } else {
        await axios.post(`${API_BASE}/admissions/${id}/entries`, entryForm, {
          headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
        });
      }
      flashMessage(setSuccess, editingEntryId ? "Entry updated successfully." : "Entry recorded successfully.");
      setEntryForm({ bp: "", pulse: "", temp: "", spo2: "", note: "", recorded_at: "" });
      setEditingEntryId(null);
      setShowEntryForm(false);
      await fetchAdmission();
    } catch (err) {
      flashMessage(setError, err.response?.data?.message || "Failed to save entry.");
    } finally {
      setSavingEntry(false);
    }
  };

  const resetEntryForm = () => {
    setEntryForm({ bp: "", pulse: "", temp: "", spo2: "", note: "", recorded_at: "" });
    setEditingEntryId(null);
    setShowEntryForm(false);
  };

  const toDateTimeLocal = (value) => {
    if (!value) return "";
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return "";
    return new Date(date.getTime() - date.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
  };

  const openNewEntryForm = () => {
    const now = new Date();
    const localISOTime = new Date(now - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
    setEditingEntryId(null);
    setEntryForm({ bp: "", pulse: "", temp: "", spo2: "", note: "", recorded_at: localISOTime });
    setShowEntryForm(true);
  };

  const handleEditEntry = (entry) => {
    setEditingEntryId(entry.id);
    setEntryForm({
      bp: entry.bp || "",
      pulse: entry.pulse || "",
      temp: entry.temp || "",
      spo2: entry.spo2 || "",
      note: entry.note || "",
      recorded_at: toDateTimeLocal(entry.recorded_at),
    });
    setShowEntryForm(true);
  };

  const handleClinicalNoteChange = (e) => {
      const { name, value } = e.target;
      setClinicalNoteForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleAddClinicalNote = async (e) => {
      e.preventDefault();
      setSavingClinicalNote(true);
      try {
          let finalDiagnosis = clinicalNoteForm.diagnosis;
          if (clinicalNoteForm.diagnosis === "All Other Diseases") {
              finalDiagnosis = otherDiagnosis;
              if (!finalDiagnosis) {
                  flashMessage(setError, "Please specify the other disease.");
                  setSavingClinicalNote(false);
                  return;
              }
          } else if (otherDiagnosis.trim()) {
              finalDiagnosis = `${clinicalNoteForm.diagnosis} - ${otherDiagnosis.trim()}`;
          }
          
          if (!finalDiagnosis) {
              flashMessage(setError, "Please select a diagnosis from the list.");
              setSavingClinicalNote(false);
              return;
          }

          const payload = { ...clinicalNoteForm, diagnosis: finalDiagnosis };

          await axios.post(
              `${API_BASE}/admissions/${id}/clinical-notes`,
              payload,
              { headers: { Authorization: `Bearer ${localStorage.getItem("token")}` } }
          );
          flashMessage(setSuccess, "Clinical note added successfully.");
          setClinicalNoteForm({ chief_complaint: "", general_exam: "", systemic_exam: "", diagnosis: "", plan_notes: "" });
          setOtherDiagnosis("");
          setShowClinicalNoteForm(false);
          await fetchAdmission();
      } catch (err) {
          flashMessage(setError, err.response?.data?.message || "Failed to save clinical note.");
      } finally {
          setSavingClinicalNote(false);
      }
  };

  const handleTreatmentNoteChange = (e) => {
      const { name, value } = e.target;
      setTreatmentNoteForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleAddTreatmentNote = async (e) => {
      e.preventDefault();
      setSavingTreatmentNote(true);
      try {
          await axios.post(
              `${API_BASE}/admissions/${id}/treatment-notes`,
              treatmentNoteForm,
              { headers: { Authorization: `Bearer ${localStorage.getItem("token")}` } }
          );
          flashMessage(setSuccess, "Treatment note added successfully.");
          setTreatmentNoteForm({ type: "", medication: "", dosage: "", route: "", directions: "", frequency: "" });
          setShowTreatmentNoteForm(false);
          await fetchAdmission();
      } catch (err) {
          flashMessage(setError, err.response?.data?.message || "Failed to save treatment note.");
      } finally {
          setSavingTreatmentNote(false);
      }
  };

  const handleUpdateTreatmentNoteStatus = async (noteId, status) => {
      if (!window.confirm(`Are you sure you want to mark this treatment as ${status}?`)) return;
      try {
          await axios.put(
              `${API_BASE}/admissions/${id}/treatment-notes/${noteId}/status`,
              { status },
              { headers: { Authorization: `Bearer ${localStorage.getItem("token")}` } }
          );
          flashMessage(setSuccess, `Treatment marked as ${status}.`);
          await fetchAdmission();
      } catch (err) {
          flashMessage(setError, err.response?.data?.message || "Failed to update status.");
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
    if (!window.confirm("Are you sure you want to delete this prescription?")) return;
    try {
      await axios.delete(`${API_BASE}/pharmacy/prescriptions/${prescriptionId}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });
      flashMessage(setSuccess, "Prescription deleted successfully.");
      fetchAdmission();
    } catch (err) {
      flashMessage(setError, err.response?.data?.message || "Failed to delete prescription.");
    }
  };

  const deleteLabTest = async (requestId, testId) => {
    if (!window.confirm('Are you sure you want to delete this test?')) return;
    try {
      await axios.delete(`${API_BASE}/lab/requests/${requestId}/tests/${testId}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      flashMessage(setSuccess, 'Test deleted successfully');
      fetchAdmission();
    } catch (error) {
      flashMessage(setError, error.response?.data?.message || 'Failed to delete test');
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
  const clinicalNotes = admission.clinicalNotes || admission.clinical_notes || [];
  const treatmentNotes = admission.treatmentNotes || admission.treatment_notes || [];
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
              <div className="flex gap-1 p-1.5 bg-gray-100/80 rounded-xl mb-8 overflow-x-auto whitespace-nowrap scrollbar-hide border border-gray-200/60 shadow-sm">
                {[
                  { key: "summary", label: "Admission Summary", icon: <ClipboardList size={15} /> },
                  { key: "cardex", label: `Cardex / Timeline (${entries.length})`, icon: <Activity size={15} /> },
                  { key: "clinical_notes", label: `Clinical Notes (${clinicalNotes.length})`, icon: <FileText size={15} /> },
                  { key: "treatment_notes", label: `Treatment Sheet (${treatmentNotes.length})`, icon: <ClipboardList size={15} /> },
                  { key: "prescriptions", label: `Prescriptions (${prescriptions.length})`, icon: <Pill size={15} /> },
                  { key: "lab_tests", label: `Lab Tests (${labRequests.length})`, icon: <Microscope size={15} /> },
                ].map((tab) => (
                  <button
                    key={tab.key}
                    onClick={() => setActiveTab(tab.key)}
                    className={`flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-lg transition-all duration-200 ${activeTab === tab.key
                      ? "bg-white text-indigo-700 shadow-sm ring-1 ring-gray-200/50"
                      : "text-gray-600 hover:text-gray-900 hover:bg-white/60"
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
                          if (showEntryForm) {
                            resetEntryForm();
                          } else {
                            openNewEntryForm();
                          }
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
                      <h4 className="text-sm font-semibold text-indigo-800 mb-4">
                        {editingEntryId ? "Edit Cardex Entry" : "New Cardex Entry"}
                      </h4>
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
                        <button type="button" onClick={resetEntryForm} className="px-4 py-2 text-sm text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50">
                          Cancel
                        </button>
                        <button type="submit" disabled={savingEntry} className="px-4 py-2 text-sm bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 font-medium">
                          {savingEntry ? "Saving..." : editingEntryId ? "Update Entry" : "Save Entry"}
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
                              <div className="flex items-center gap-2">
                                {entry.user && (
                                  <div className="text-xs font-medium text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded-full">
                                    {entry.user.name}
                                  </div>
                                )}
                                {isActive && (
                                  <button
                                    type="button"
                                    onClick={() => handleEditEntry(entry)}
                                    className="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-medium text-indigo-700 bg-indigo-50 border border-indigo-200 rounded-full hover:bg-indigo-100"
                                  >
                                    <Pencil size={12} />
                                    Edit
                                  </button>
                                )}
                              </div>
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

              {/* ========== TAB: CLINICAL NOTES ========== */}
              {activeTab === "clinical_notes" && (
                  <div className="animate-in fade-in duration-300">
                      {isActive && (user?.role === "admin" || user?.role === "doctor") && (
                          <div className="mb-5 flex flex-wrap gap-3">
                              <button
                                  onClick={() => setShowClinicalNoteForm(!showClinicalNoteForm)}
                                  className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all font-medium shadow-sm"
                              >
                                  <PlusCircle size={16} />
                                  {showClinicalNoteForm ? "Cancel" : "Add Clinical Note"}
                              </button>
                          </div>
                      )}

                      {showClinicalNoteForm && (
                          <form onSubmit={handleAddClinicalNote} className="bg-blue-50/50 border border-blue-100 rounded-xl p-5 mb-8 shadow-sm">
                              <h4 className="text-sm font-semibold text-blue-800 mb-4">New Clinical Note</h4>

                              <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Chief Complaint</label>
                                      <textarea
                                          name="chief_complaint"
                                          rows={2}
                                          placeholder="Patient's main reported symptoms..."
                                          value={clinicalNoteForm.chief_complaint}
                                          onChange={handleClinicalNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none shadow-sm"
                                      />
                                  </div>
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">General Exam</label>
                                      <textarea
                                          name="general_exam"
                                          rows={2}
                                          placeholder="General physical examination findings..."
                                          value={clinicalNoteForm.general_exam}
                                          onChange={handleClinicalNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none shadow-sm"
                                      />
                                  </div>
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Systemic Exam</label>
                                      <textarea
                                          name="systemic_exam"
                                          rows={2}
                                          placeholder="Specific system findings (e.g. CVS, RS, GIT)..."
                                          value={clinicalNoteForm.systemic_exam}
                                          onChange={handleClinicalNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none shadow-sm"
                                      />
                                  </div>
                                  <div className="relative" style={{zIndex: 50}}>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Diagnosis / Impression</label>
                                      <SearchableDiagnosisDropdown
                                          value={clinicalNoteForm.diagnosis}
                                          onChange={(val) => {
                                              setClinicalNoteForm(prev => ({ ...prev, diagnosis: val }));
                                              if (val !== "All Other Diseases") {
                                                  setOtherDiagnosis("");
                                              }
                                          }}
                                      />
                                  </div>

                                  {/* Optional detailed diagnosis - Clinical Note */}
                                  {clinicalNoteForm.diagnosis && (
                                      <div className="animate-in slide-in-from-top-2 duration-300 mt-1 md:col-span-2">
                                          <label className="block text-xs font-medium text-gray-700 mb-1.5">
                                              Specific details / Exact diagnosis {clinicalNoteForm.diagnosis === "All Other Diseases" ? <span className="text-red-500">*</span> : <span className="text-gray-400 font-normal">(Optional)</span>}
                                          </label>
                                          <input
                                              type="text"
                                              value={otherDiagnosis}
                                              onChange={(e) => setOtherDiagnosis(e.target.value)}
                                              placeholder={clinicalNoteForm.diagnosis === "All Other Diseases" ? "Enter diagnosis name manually..." : "e.g., Left arm, severe..."}
                                              className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all shadow-sm"
                                              required={clinicalNoteForm.diagnosis === "All Other Diseases"}
                                          />
                                      </div>
                                  )}
                              </div>

                              <div className="mb-5">
                                  <label className="block text-xs font-medium text-gray-700 mb-1.5">Plan Notes</label>
                                  <textarea
                                      name="plan_notes"
                                      rows={3}
                                      placeholder="Treatment plan, monitoring, further investigations..."
                                      value={clinicalNoteForm.plan_notes}
                                      onChange={handleClinicalNoteChange}
                                      className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none shadow-sm"
                                  />
                              </div>

                              <div className="flex justify-end gap-3 pt-2 border-t border-blue-100">
                                  <button
                                      type="button"
                                      onClick={() => setShowClinicalNoteForm(false)}
                                      className="px-4 py-2.5 text-sm font-medium text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 shadow-sm transition-colors"
                                  >
                                      Cancel
                                  </button>
                                  <button
                                      type="submit"
                                      disabled={savingClinicalNote}
                                      className="px-4 py-2.5 text-sm font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 shadow-sm transition-colors"
                                  >
                                      {savingClinicalNote ? "Saving..." : "Save Note"}
                                  </button>
                              </div>
                          </form>
                      )}

                      {/* Clinical Notes Timeline */}
                      {clinicalNotes.length === 0 ? (
                          <div className="text-center py-16 bg-white border border-gray-200 rounded-2xl shadow-sm">
                              <div className="bg-gray-50 h-16 w-16 rounded-full flex items-center justify-center mx-auto mb-4">
                                <FileText className="h-8 w-8 text-gray-400" />
                              </div>
                              <p className="font-semibold text-gray-700 text-base">No clinical notes yet.</p>
                              <p className="text-sm text-gray-500 mt-1">Doctor evaluations and notes will appear here.</p>
                          </div>
                      ) : (
                          <div className="relative mt-4">
                              {/* Timeline line */}
                              <div className="absolute left-5 top-4 bottom-4 w-0.5 bg-blue-200" />
                              <div className="space-y-6 pl-12">
                                  {clinicalNotes.map((note) => (
                                      <div key={note.id} className="bg-white rounded-xl border border-gray-200 shadow-sm p-5 relative hover:shadow-md transition-shadow">
                                          {/* Timeline dot */}
                                          <div className="absolute -left-8 top-6 w-3.5 h-3.5 rounded-full bg-blue-500 border-2 border-white shadow-sm ring-2 ring-blue-100" />

                                          {/* Header row */}
                                          <div className="flex flex-wrap items-center justify-between gap-3 mb-4 border-b border-gray-100 pb-3">
                                              <div className="flex items-center gap-2 text-xs text-gray-500 font-medium">
                                                  <Clock size={14} className="text-gray-400" />
                                                  <span className="text-gray-700">{formatDateTime(note.created_at)}</span>
                                              </div>
                                              {note.user && (
                                                  <div className="text-xs font-semibold text-blue-700 bg-blue-50 px-3 py-1 rounded-full flex items-center gap-1.5 border border-blue-100">
                                                      <Stethoscope size={13} />
                                                      {note.user.role ? (note.user.role.charAt(0).toUpperCase() + note.user.role.slice(1)) : 'Doctor'}: {note.user.name}
                                                  </div>
                                              )}
                                          </div>

                                          {/* Content Grid */}
                                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                              {note.chief_complaint && (
                                                  <div className="bg-gray-50 p-3.5 rounded-lg border border-gray-100">
                                                      <h5 className="text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1.5">Chief Complaint</h5>
                                                      <p className="text-sm text-gray-800 whitespace-pre-wrap">{note.chief_complaint}</p>
                                                  </div>
                                              )}
                                              {note.general_exam && (
                                                  <div className="bg-gray-50 p-3.5 rounded-lg border border-gray-100">
                                                      <h5 className="text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1.5">General Exam</h5>
                                                      <p className="text-sm text-gray-800 whitespace-pre-wrap">{note.general_exam}</p>
                                                  </div>
                                              )}
                                              {note.systemic_exam && (
                                                  <div className="bg-gray-50 p-3.5 rounded-lg border border-gray-100">
                                                      <h5 className="text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1.5">Systemic Exam</h5>
                                                      <p className="text-sm text-gray-800 whitespace-pre-wrap">{note.systemic_exam}</p>
                                                  </div>
                                              )}
                                              {note.diagnosis && (
                                                  <div className="bg-blue-50/30 p-3.5 rounded-lg border border-blue-100/50">
                                                      <h5 className="text-[11px] font-bold text-blue-600 uppercase tracking-wider mb-1.5">Diagnosis / Impression</h5>
                                                      <p className="text-sm text-gray-900 whitespace-pre-wrap font-medium">{note.diagnosis}</p>
                                                  </div>
                                              )}
                                          </div>

                                          {note.plan_notes && (
                                              <div className="mt-4 bg-indigo-50/50 p-4 rounded-lg border border-indigo-100">
                                                  <h5 className="text-[11px] font-bold text-indigo-600 uppercase tracking-wider mb-1.5">Plan / Next Steps</h5>
                                                  <p className="text-sm text-gray-800 whitespace-pre-wrap">{note.plan_notes}</p>
                                              </div>
                                          )}
                                      </div>
                                  ))}
                              </div>
                          </div>
                      )}
                  </div>
              )}

              {/* ========== TAB: TREATMENT NOTES ========== */}
              {activeTab === "treatment_notes" && (
                  <div className="animate-in fade-in duration-300">
                      {isActive && (user?.role === "admin" || user?.role === "doctor" || user?.role === "nurse" || user?.role === "reception") && (
                          <div className="mb-5 flex flex-wrap gap-3">
                              <button
                                  onClick={() => setShowTreatmentNoteForm(!showTreatmentNoteForm)}
                                  className="flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-all font-medium shadow-sm"
                              >
                                  <PlusCircle size={16} />
                                  {showTreatmentNoteForm ? "Cancel" : "Add Treatment Order"}
                              </button>
                          </div>
                      )}

                      {showTreatmentNoteForm && (
                          <form onSubmit={handleAddTreatmentNote} className="bg-purple-50/50 border border-purple-100 rounded-xl p-5 mb-8 shadow-sm">
                              <h4 className="text-sm font-semibold text-purple-800 mb-4">New Treatment Order / Care Direction</h4>

                              <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Treatment Type / Name</label>
                                      <input
                                          type="text"
                                          name="type"
                                          placeholder="e.g. Wound Dressing, Oxygen Therapy"
                                          value={treatmentNoteForm.type}
                                          onChange={handleTreatmentNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 shadow-sm"
                                          required
                                      />
                                  </div>
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Frequency</label>
                                      <input
                                          type="text"
                                          name="frequency"
                                          placeholder="e.g. Every 12 hours, Stat, PRN"
                                          value={treatmentNoteForm.frequency}
                                          onChange={handleTreatmentNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 shadow-sm"
                                      />
                                  </div>
                              </div>

                              <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-5 bg-white p-4 rounded-lg border border-gray-200 shadow-sm">
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Medication (Optional)</label>
                                      <input
                                          type="text"
                                          name="medication"
                                          placeholder="e.g. Paracetamol"
                                          value={treatmentNoteForm.medication}
                                          onChange={handleTreatmentNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                                      />
                                  </div>
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Dosage</label>
                                      <input
                                          type="text"
                                          name="dosage"
                                          placeholder="e.g. 500mg"
                                          value={treatmentNoteForm.dosage}
                                          onChange={handleTreatmentNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                                      />
                                  </div>
                                  <div>
                                      <label className="block text-xs font-medium text-gray-700 mb-1.5">Route</label>
                                      <input
                                          type="text"
                                          name="route"
                                          placeholder="e.g. Oral, IV"
                                          value={treatmentNoteForm.route}
                                          onChange={handleTreatmentNoteChange}
                                          className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                                      />
                                  </div>
                              </div>

                              <div className="mb-5">
                                  <label className="block text-xs font-medium text-gray-700 mb-1.5">Directions / Special Instructions</label>
                                  <textarea
                                      name="directions"
                                      rows={3}
                                      placeholder="Detailed instructions for the nursing staff..."
                                      value={treatmentNoteForm.directions}
                                      onChange={handleTreatmentNoteChange}
                                      className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 resize-none shadow-sm"
                                      required
                                  />
                              </div>

                              <div className="flex justify-end gap-3 pt-2 border-t border-purple-100">
                                  <button
                                      type="button"
                                      onClick={() => setShowTreatmentNoteForm(false)}
                                      className="px-4 py-2.5 text-sm font-medium text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 shadow-sm transition-colors"
                                  >
                                      Cancel
                                  </button>
                                  <button
                                      type="submit"
                                      disabled={savingTreatmentNote}
                                      className="px-4 py-2.5 text-sm font-medium bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50 shadow-sm transition-colors"
                                  >
                                      {savingTreatmentNote ? "Saving..." : "Save Order"}
                                  </button>
                              </div>
                          </form>
                      )}

                      {/* Treatment Notes List */}
                      {treatmentNotes.length === 0 ? (
                          <div className="text-center py-16 bg-white border border-gray-200 rounded-2xl shadow-sm">
                              <div className="bg-gray-50 h-16 w-16 rounded-full flex items-center justify-center mx-auto mb-4">
                                <ClipboardList className="h-8 w-8 text-gray-400" />
                              </div>
                              <p className="font-semibold text-gray-700 text-base">No treatment orders.</p>
                              <p className="text-sm text-gray-500 mt-1">Treatment and medication orders will appear here.</p>
                          </div>
                      ) : (
                          <div className="space-y-4">
                              {treatmentNotes.map((note) => (
                                  <div key={note.id} className={`bg-white rounded-xl border p-5 shadow-sm transition-all hover:shadow-md ${note.status === 'active' ? 'border-purple-200 ring-1 ring-purple-100' :
                                          note.status === 'completed' ? 'border-green-200 opacity-80' :
                                              'border-gray-200 opacity-70'
                                      }`}>
                                      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4 border-b border-gray-50 pb-3">
                                          <div className="flex items-center gap-3">
                                              <div className={`p-2.5 rounded-lg shadow-sm ${note.status === 'active' ? 'bg-purple-100 text-purple-700 border border-purple-200' :
                                                      note.status === 'completed' ? 'bg-green-100 text-green-700 border border-green-200' :
                                                          'bg-gray-100 text-gray-500 border border-gray-200'
                                                  }`}>
                                                  <ClipboardList size={20} />
                                              </div>
                                              <div>
                                                  <h5 className="font-bold text-gray-800 text-base tracking-tight">{note.type}</h5>
                                                  <div className="flex items-center gap-2 text-xs text-gray-500 mt-1 font-medium">
                                                      <Clock size={13} className="text-gray-400" />
                                                      <span>Ordered: {formatDateTime(note.created_at)}</span>
                                                      {note.user && <span className="ml-1 text-gray-600">• By {note.user.name}</span>}
                                                  </div>
                                              </div>
                                          </div>
                                          
                                          {isActive && (
                                              <div className="flex gap-2">
                                                  {note.status === 'active' && (
                                                      <>
                                                          <button
                                                              onClick={() => handleUpdateTreatmentNoteStatus(note.id, 'completed')}
                                                              className="px-3 py-1.5 text-xs font-semibold bg-white text-green-700 border border-green-300 rounded-md hover:bg-green-50 shadow-sm transition-colors flex items-center gap-1.5"
                                                          >
                                                              <CheckCircle size={14} /> Mark Complete
                                                          </button>
                                                          <button
                                                              onClick={() => handleUpdateTreatmentNoteStatus(note.id, 'discontinued')}
                                                              className="px-3 py-1.5 text-xs font-semibold bg-white text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 shadow-sm transition-colors flex items-center gap-1.5"
                                                          >
                                                              <X size={14} /> Discontinue
                                                          </button>
                                                      </>
                                                  )}
                                                  {note.status !== 'active' && (
                                                      <span className={`px-4 py-1.5 rounded-full text-[11px] font-bold uppercase tracking-wider shadow-sm border ${note.status === 'completed' ? 'bg-green-50 text-green-700 border-green-200' : 'bg-gray-50 text-gray-600 border-gray-200'
                                                          }`}>
                                                          {note.status}
                                                      </span>
                                                  )}
                                              </div>
                                          )}
                                      </div>

                                      <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mt-4">
                                          <div className="text-sm">
                                              <p className="text-[11px] text-gray-500 uppercase font-bold tracking-wider mb-2">Directions</p>
                                              <p className="text-gray-800 bg-gray-50 p-3 rounded-lg border border-gray-100 whitespace-pre-wrap">{note.directions}</p>
                                          </div>
                                          {(note.medication || note.frequency) && (
                                              <div className="bg-purple-50/50 p-4 rounded-lg border border-purple-100">
                                                  <p className="text-[11px] text-purple-700 uppercase font-bold tracking-wider mb-3">Details</p>
                                                  <div className="grid grid-cols-2 gap-y-3 gap-x-4 text-sm">
                                                      {note.medication && (
                                                          <div className="col-span-2 sm:col-span-1">
                                                              <span className="block text-gray-500 text-xs mb-0.5">Medication</span>
                                                              <span className="font-semibold text-gray-800">{note.medication}</span>
                                                          </div>
                                                      )}
                                                      {note.dosage && (
                                                          <div className="col-span-2 sm:col-span-1">
                                                              <span className="block text-gray-500 text-xs mb-0.5">Dosage</span>
                                                              <span className="font-semibold text-gray-800">{note.dosage}</span>
                                                          </div>
                                                      )}
                                                      {note.route && (
                                                          <div className="col-span-2 sm:col-span-1">
                                                              <span className="block text-gray-500 text-xs mb-0.5">Route</span>
                                                              <span className="font-semibold text-gray-800">{note.route}</span>
                                                          </div>
                                                      )}
                                                      {note.frequency && (
                                                          <div className="col-span-2 sm:col-span-1">
                                                              <span className="block text-gray-500 text-xs mb-0.5">Frequency</span>
                                                              <span className="font-semibold text-gray-800">{note.frequency}</span>
                                                          </div>
                                                      )}
                                                  </div>
                                              </div>
                                          )}
                                      </div>
                                  </div>
                              ))}
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
                                  <div key={t.id} className="flex justify-between items-center text-sm bg-gray-50 rounded-lg p-2">
                                    <span className="text-gray-700">{t.template?.name || "Unknown Test"}</span>
                                    <div className="flex items-center gap-2">
                                      <span className={`text-xs font-medium capitalize ${t.status === "completed" ? "text-green-600" : "text-gray-500"}`}>{t.status}</span>
                                      {t.status !== "completed" && (
                                        <button
                                          onClick={() => deleteLabTest(lr.id, t.id)}
                                          className="p-1 text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 rounded"
                                          title="Delete Test"
                                        >
                                          <Trash2 size={14} />
                                        </button>
                                      )}
                                    </div>
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
