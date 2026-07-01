import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import {
    Printer,
    ChevronLeft,
    Loader,
    AlertCircle,
    Activity,
    Stethoscope,
    ClipboardPlus,
    Pill,
    Microscope,
    MapPin,
    Phone,
    Mail
} from "lucide-react";
import logo from "../assets/logo.jpeg";

const TreatmentPrint = () => {
    const { id, treatmentId } = useParams(); // id is patientId
    const navigate = useNavigate();

    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    const [patient, setPatient] = useState(null);
    const [treatment, setTreatment] = useState(null);
    const [prescriptions, setPrescriptions] = useState([]);
    const [labRequests, setLabRequests] = useState([]);
    const [triage, setTriage] = useState(null);

    const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            setError("");

            const token = localStorage.getItem('token');
            const config = { headers: { Authorization: `Bearer ${token}` } };

            // --- Step 1: Fetch patient (critical) ---
            const patientUrl = `${API_BASE_URL}/patients/${id}`;
            let patientData = null;
            try {
                const pRes = await axios.get(patientUrl, config);
                patientData = pRes.data;
                setPatient(patientData);
            } catch (err) {
                const status = err.response?.status;
                const serverMsg = err.response?.data?.message || err.response?.data?.error || '';
                const detail = `[${status || 'NETWORK_ERR'}] GET ${patientUrl} — ${serverMsg || err.message}`;
                console.error('TreatmentPrint: patient fetch failed:', detail, err);
                setError(`PATIENT FETCH FAILED\n${detail}\n\nServer: ${JSON.stringify(err.response?.data)}\nToken: ${token ? 'present' : 'MISSING'}\nAPI: ${API_BASE_URL}`);
                setLoading(false);
                return;
            }

            // --- Step 2: Find the specific treatment from eager-loaded data ---
            const treatments = patientData.treatments || [];
            const specificTreatment = treatments.find(t => t.id === parseInt(treatmentId));

            if (!specificTreatment) {
                const msg = `Treatment #${treatmentId} not found in patient #${id}'s records.\nPatient has ${treatments.length} treatment(s): [${treatments.map(t => t.id).join(', ')}]`;
                console.error('TreatmentPrint:', msg);
                setError(msg);
                setLoading(false);
                return;
            }

            setTreatment(specificTreatment);
            setPrescriptions(specificTreatment.prescriptions || []);

            // --- Step 3: Fetch lab requests (non-critical) ---
            const labUrl = `${API_BASE_URL}/lab/requests/patient/${id}`;
            try {
                const labRes = await axios.get(labUrl, config);
                setLabRequests(
                    (labRes.data || []).filter(lr => lr.treatment_id === parseInt(treatmentId))
                );
            } catch (err) {
                const status = err.response?.status;
                console.warn(`TreatmentPrint: lab fetch failed [${status}] ${labUrl} — ${err.response?.data?.message || err.message}`);
                setLabRequests([]);
            }

            // --- Step 4: Fetch triages (non-critical) ---
            const triageUrl = `${API_BASE_URL}/triages/patient/${id}`;
            try {
                const triagesRes = await axios.get(triageUrl, config);
                const visitDate = specificTreatment.visit_date.split('T')[0];
                const matchingTriage = (triagesRes.data || []).find(t => t.created_at.startsWith(visitDate));
                if (matchingTriage) setTriage(matchingTriage);
            } catch (err) {
                console.warn(`TreatmentPrint: triage fetch failed — ${err.response?.status} ${err.message}`);
            }

            setLoading(false);
        };

        fetchData();
    }, [id, treatmentId]);

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50">
                <div className="text-center">
                    <Loader className="w-8 h-8 animate-spin text-blue-600 mx-auto mb-2" />
                    <p className="text-gray-600">Loading treatment details...</p>
                </div>
            </div>
        );
    }

    if (error || !treatment || !patient) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
                <div className="max-w-2xl w-full">
                    <div className="bg-white border border-red-300 rounded-xl shadow-md p-6">
                        <div className="flex items-center gap-3 mb-4">
                            <AlertCircle className="w-8 h-8 text-red-600 flex-shrink-0" />
                            <h2 className="text-lg font-bold text-red-700">
                                {error ? 'Error Loading Record' : 'Record Not Found'}
                            </h2>
                        </div>

                        {error ? (
                            <div className="bg-gray-950 text-green-400 rounded-lg p-4 text-xs font-mono overflow-auto whitespace-pre-wrap leading-relaxed mb-4">
                                {error}
                            </div>
                        ) : (
                            <p className="text-gray-600 mb-4">The requested patient or treatment could not be found.</p>
                        )}

                        <div className="bg-gray-100 rounded-lg p-3 text-xs font-mono text-gray-600 space-y-1 mb-4">
                            <div><span className="text-gray-400">Patient ID: </span>{id}</div>
                            <div><span className="text-gray-400">Treatment ID: </span>{treatmentId}</div>
                            <div><span className="text-gray-400">API: </span>{API_BASE_URL}</div>
                            <div><span className="text-gray-400">Token: </span>{localStorage.getItem('token') ? 'present' : 'MISSING — not logged in!'}</div>
                            <div><span className="text-gray-400">Time: </span>{new Date().toISOString()}</div>
                        </div>

                        <div className="flex gap-3">
                            <button
                                onClick={() => window.location.reload()}
                                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium"
                            >
                                Retry
                            </button>
                            <button
                                onClick={() => navigate(-1)}
                                className="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors text-sm"
                            >
                                Go Back
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-100 font-sans print:bg-white">
            {/* Navbar / Controls - Hidden on Print */}
            <div className="bg-white border-b border-gray-200 p-4 shadow-sm sticky top-0 z-20 print:hidden">
                <div className="max-w-4xl mx-auto flex justify-between items-center">
                    <div className="flex items-center gap-3">
                        <button
                            onClick={() => navigate(-1)}
                            className="p-2 rounded-full hover:bg-gray-100 transition-colors"
                            title="Back"
                        >
                            <ChevronLeft className="w-5 h-5 text-gray-600" />
                        </button>
                        <h1 className="text-lg font-semibold text-gray-800">
                            Print Treatment Details
                        </h1>
                    </div>
                    <button
                        onClick={() => window.print()}
                        className="flex items-center gap-2 px-4 py-2 bg-blue-900 text-white rounded-lg hover:bg-blue-800 transition-colors shadow-sm font-medium"
                    >
                        <Printer size={18} />
                        Print Record
                    </button>
                </div>
            </div>

            {/* Printable Content */}
            <div className="max-w-4xl mx-auto p-6 md:p-8 print:p-0 print:max-w-none">
                <div className="bg-white shadow-lg rounded-xl overflow-hidden print:shadow-none print:rounded-none">

                    {/* Pro Letterhead */}
                    <div className="p-6 border-b-4 border-blue-900 relative overflow-hidden print:p-4">
                        <div className="flex justify-between items-center relative z-10">
                            <div className="flex items-center gap-4">
                                <img src={logo} alt="Logo" className="w-16 h-16 rounded-xl object-cover shadow-lg border border-blue-100" />
                                <div>
                                    <h1 className="text-3xl font-sans font-black text-blue-900 tracking-tight uppercase leading-none mb-1">
                                        Naitiri Jambo
                                    </h1>
                                    <h2 className="text-xl font-sans font-bold text-gray-600 tracking-wide uppercase">
                                        Healthcare HMIS
                                    </h2>
                                    <p className="text-xs text-blue-800 mt-2 font-semibold tracking-widest uppercase">Excellence in Care</p>
                                </div>
                            </div>
                            <div className="text-right space-y-1">
                                <div className="flex items-center justify-end gap-2 text-gray-600 text-sm">
                                    <span>Tongaren, Bungoma</span>
                                    <div className="p-1 bg-blue-50 rounded-full"><MapPin size={14} className="text-blue-900" /></div>
                                </div>
                                <div className="flex items-center justify-end gap-2 text-gray-600 text-sm">
                                    <span>+254 792 100336</span>
                                    <div className="p-1 bg-blue-50 rounded-full"><Phone size={14} className="text-blue-900" /></div>
                                </div>
                                <div className="flex items-center justify-end gap-2 text-gray-600 text-sm">
                                    <span>info@naitirijambo.com</span>
                                    <div className="p-1 bg-blue-50 rounded-full"><Mail size={14} className="text-blue-900" /></div>
                                </div>
                            </div>
                        </div>
                        {/* Decorative background element */}
                        <div className="absolute -top-10 -right-10 w-40 h-40 bg-blue-50 rounded-full opacity-50 z-0"></div>
                    </div>

                    {/* Document Title Bar */}
                    <div className="bg-gray-50 border-b border-gray-200 px-6 py-2 flex justify-between items-center print:bg-gray-100 print:px-4 print:py-1">
                        <h3 className="text-base font-bold text-gray-800 uppercase tracking-wide">Medical Treatment Record</h3>
                        <span className="text-xs font-mono text-gray-500">REF: {treatment.id.toString().padStart(6, '0')}</span>
                    </div>

                    {/* Patient Info Grid */}
                    <div className="p-6 border-b border-gray-200 print:p-4">
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Patient Name</p>
                                <p className="font-bold text-gray-900 text-sm">{patient.first_name} {patient.last_name}</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Patient ID (UPID)</p>
                                <p className="font-medium text-gray-800 font-mono text-sm">{patient.upid || "N/A"}</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Gender / Age</p>
                                <p className="font-medium text-gray-800 text-sm">{patient.gender}, {patient.age || "?"} yrs</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Contact</p>
                                <p className="font-medium text-gray-800 text-sm">{patient.phone || "N/A"}</p>
                            </div>
                        </div>
                    </div>

                    {/* Treatment Details Body */}
                    <div className="p-6 space-y-4 print:p-4 print:space-y-4">

                        {/* Visit Metadata & Vitals - Compressed */}
                        <div className="border-b border-gray-200 pb-2 mb-2">
                            <div className="flex justify-between items-end mb-1">
                                <div className="text-xs text-gray-500">
                                    <span className="mr-4"><span className="font-bold uppercase tracking-wider text-gray-400">Date:</span> {new Date(treatment.visit_date).toLocaleDateString()}</span>
                                    <span><span className="font-bold uppercase tracking-wider text-gray-400">Time:</span> {new Date(treatment.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                                </div>
                                <div className="text-xs text-gray-500">
                                    <span className="font-bold uppercase tracking-wider text-gray-400">Physician:</span> {treatment.doctor ? `Dr. ${treatment.doctor.first_name} ${treatment.doctor.last_name}` : (treatment.attending_doctor || "Unknown")}
                                </div>
                            </div>

                            {triage && (
                                <div className="flex flex-wrap gap-x-3 gap-y-1 text-[10px] text-gray-500 items-center">
                                    <span className="font-bold uppercase tracking-wider text-gray-400"><Activity size={10} className="inline mr-1" /> Vitals:</span>
                                    {triage.blood_pressure_systolic && <span className="bg-gray-50 px-1.5 py-0.5 rounded border border-gray-100">BP: <strong className="text-gray-700">{triage.blood_pressure_systolic}/{triage.blood_pressure_diastolic}</strong></span>}
                                    {triage.temperature && <span className="bg-gray-50 px-1.5 py-0.5 rounded border border-gray-100">Temp: <strong className="text-gray-700">{triage.temperature}°C</strong></span>}
                                    {triage.pulse_rate && <span className="bg-gray-50 px-1.5 py-0.5 rounded border border-gray-100">Pulse: <strong className="text-gray-700">{triage.pulse_rate}</strong></span>}
                                    {triage.respiratory_rate && <span className="bg-gray-50 px-1.5 py-0.5 rounded border border-gray-100">Resp: <strong className="text-gray-700">{triage.respiratory_rate}</strong></span>}
                                    {triage.weight && <span className="bg-gray-50 px-1.5 py-0.5 rounded border border-gray-100">Wt: <strong className="text-gray-700">{triage.weight} kg</strong></span>}
                                    {triage.oxygen_saturation && <span className="bg-gray-50 px-1.5 py-0.5 rounded border border-gray-100">SpO2: <strong className="text-gray-700">{triage.oxygen_saturation}%</strong></span>}
                                </div>
                            )}
                        </div>

                        {/* Clinical Assessment Grid */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            {/* Column 1: Notes (Expanded) */}
                            <div className="md:col-span-2 space-y-4">
                                <div>
                                    <h4 className="text-xs font-bold text-blue-900 uppercase tracking-widest mb-2 flex items-center gap-2 border-b border-gray-200 pb-1">
                                        <Stethoscope size={14} /> Clinical Notes
                                    </h4>
                                    <div className="space-y-3">
                                        {[
                                            { label: 'Chief Complaint', value: treatment.chief_complaint },
                                            { label: 'History of Presenting Illness', value: treatment.history_presenting_illness },
                                            { label: 'Systemic Review', value: treatment.systemic_review },
                                            { label: 'Past Medical and Surgical History', value: treatment.past_medical_history },
                                            { label: 'Premedication', value: treatment.premedication },
                                            { label: 'General and Systemic examination', value: treatment.general_systemic_examination },
                                            { label: 'Impression', value: treatment.impression },
                                        ].map((item, idx) => (
                                            <div key={idx} className="block">
                                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-0.5">{item.label}</p>
                                                <div className={`text-sm ${item.value ? 'text-gray-900 font-medium' : 'text-gray-400 italic'}`}>
                                                    {item.value || "—"}
                                                </div>
                                            </div>
                                        ))}
                                        {treatment.treatment_notes && (
                                            <div className="block pt-1">
                                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-0.5">Treatment Plan / Notes</p>
                                                <div className="text-sm text-gray-900 font-medium whitespace-pre-wrap leading-relaxed">
                                                    {treatment.treatment_notes}
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>

                            {/* Column 2: Diagnosis */}
                            <div className="space-y-4">
                                <div>
                                    <h4 className="text-xs font-bold text-blue-900 uppercase tracking-widest mb-2 flex items-center gap-2 border-b border-gray-200 pb-1">
                                        <ClipboardPlus size={14} /> Diagnosis
                                    </h4>
                                    <div className="bg-blue-50/50 p-3 rounded-lg border border-blue-100">
                                        <p className="text-[10px] font-bold text-gray-400 uppercase mb-1">Primary Diagnosis</p>
                                        <p className="text-base font-bold text-blue-900 leading-tight mb-2">{treatment.diagnosis || "Pending Evaluation"}</p>
                                        {treatment.diagnosis_status && (
                                            <span className="text-[10px] font-mono bg-white px-2 py-0.5 rounded border border-blue-100 text-blue-800">
                                                {treatment.diagnosis_status.toUpperCase()}
                                            </span>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Prescriptions Table */}
                        {prescriptions.length > 0 && (
                            <div className="mt-4">
                                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 flex items-center gap-2 border-b border-gray-200 pb-1">
                                    <Pill size={14} className="text-blue-900" /> Prescribed Medication
                                </h4>
                                <table className="w-full text-xs text-left border-collapse">
                                    <thead>
                                        <tr className="text-gray-500 border-b border-gray-300">
                                            <th className="py-1 pr-4 font-semibold uppercase">Drug Name / Item</th>
                                            <th className="py-1 px-4 font-semibold uppercase">Dosage</th>
                                            <th className="py-1 px-4 font-semibold uppercase">Freq.</th>
                                            <th className="py-1 px-4 font-semibold uppercase">Dur.</th>
                                            <th className="py-1 pl-4 text-right font-semibold uppercase">Qty</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100">
                                        {prescriptions.map(pres => (
                                            (pres.items || []).map((item, idx) => (
                                                <tr key={`${pres.id}-${idx}`} className="group">
                                                    <td className="py-2 pr-4 font-bold text-gray-900">{item.name}</td>
                                                    <td className="py-2 px-4 text-gray-700">{item.dosage || "—"}</td>
                                                    <td className="py-2 px-4 text-gray-700">{item.frequency || "—"}</td>
                                                    <td className="py-2 px-4 text-gray-700">{item.duration || "—"}</td>
                                                    <td className="py-2 pl-4 text-right font-mono font-medium text-gray-900">{item.quantity}</td>
                                                </tr>
                                            ))
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}

                        {/* Lab Results */}
                        {labRequests.length > 0 && (
                            <div className="mt-4 page-break-inside-avoid">
                                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 flex items-center gap-2 border-b border-gray-200 pb-1">
                                    <Microscope size={14} className="text-blue-900" /> Laboratory Orders & Results
                                </h4>
                                <div className="grid grid-cols-1 gap-2">
                                    {labRequests.map(req => (
                                        <div key={req.id} className="border border-gray-200 rounded-lg overflow-hidden flex flex-col md:flex-row print:flex-row print:border-gray-300 text-xs">
                                            <div className="bg-gray-50 p-2 min-w-[120px] border-r border-gray-200 flex flex-col justify-center print:bg-white">
                                                <span className="font-bold text-gray-800">REQ #{req.request_number}</span>
                                                <span className="text-[10px] text-gray-500 mt-0.5">{new Date(req.request_date).toLocaleDateString()}</span>
                                            </div>
                                            <div className="p-2 flex-1 bg-white">
                                                {req.tests && req.tests.map((test, tIdx) => (
                                                    <div key={tIdx} className="mb-1 last:mb-0 border-b border-gray-100 last:border-0 pb-1 last:pb-0">
                                                        <div className="flex justify-between items-start">
                                                            <p className="font-semibold text-gray-900">{test.template?.name || "Test"}</p>
                                                            {!test.result && <span className="text-[9px] font-bold bg-gray-100 text-gray-500 px-1.5 py-0.5 rounded uppercase">Pending</span>}
                                                        </div>
                                                        {test.result && (
                                                            <div className="mt-0.5 bg-blue-50/50 p-1.5 rounded text-xs print:bg-transparent print:p-0">
                                                                <div className="flex flex-col gap-1">
                                                                    {test.result.parameters && test.result.parameters.map((paramResult, pIdx) => (
                                                                        <div key={pIdx} className="flex gap-2">
                                                                            <span className="font-semibold text-gray-700">{paramResult.parameter?.name || "Parameter"}:</span>
                                                                            <span className={`font-bold ${paramResult.is_abnormal ? 'text-red-600' : 'text-gray-900'}`}>
                                                                                {paramResult.value} {paramResult.unit || ''}
                                                                            </span>
                                                                        </div>
                                                                    ))}
                                                                </div>
                                                                {test.result.overall_comment && (
                                                                    <div className="flex gap-2 mt-1 pt-1 border-t border-gray-150">
                                                                        <span className="font-bold text-gray-400 text-[10px] uppercase w-10">Note:</span>
                                                                        <span className="italic text-gray-600 text-[10px]">{test.result.overall_comment}</span>
                                                                    </div>
                                                                )}
                                                            </div>
                                                        )}
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Pro Footer */}
                    <div className="p-4 mt-auto border-t-2 border-gray-800 flex flex-col items-center mb-0 print:mb-0">
                        <p className="text-[10px] font-bold text-gray-900 uppercase tracking-widest mb-0.5">Confidential Medical Record</p>
                        <div className="text-[9px] text-gray-500 flex gap-4">
                            <span>Generated: {new Date().toLocaleString()}</span>
                            <span>•</span>
                            <span>Naitiri Jambo Healthcare HMIS</span>
                            <span>•</span>
                            <span>Page 1 of 1</span>
                        </div>
                    </div>
                </div>
            </div>

            <style>{`
        @media print {
          @page { margin: 0.5cm; size: A4; }
          body { -webkit-print-color-adjust: exact; print-color-adjust: exact; background: white; font-size: 12px; }
          .page-break-inside-avoid { break-inside: avoid; }
        }
      `}</style>
        </div>
    );
};

export default TreatmentPrint;
