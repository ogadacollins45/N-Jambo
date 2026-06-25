import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import {
    Printer,
    ChevronLeft,
    Loader,
    AlertCircle,
    Microscope,
    MapPin,
    Phone,
    Mail,
    CheckCircle2,
    FlaskConical
} from "lucide-react";
import logo from "../assets/logo.jpeg";

const LabReportPrint = () => {
    const { id } = useParams();
    const navigate = useNavigate();

    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [labRequest, setLabRequest] = useState(null);

    const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

    useEffect(() => {
        const fetchLabRequest = async () => {
            setLoading(true);
            setError("");

            const token = localStorage.getItem('token');
            const config = { headers: { Authorization: `Bearer ${token}` } };

            try {
                const res = await axios.get(`${API_BASE_URL}/lab/requests/${id}`, config);
                setLabRequest(res.data);
            } catch (err) {
                const status = err.response?.status;
                const serverMsg = err.response?.data?.message || err.message;
                setError(`Failed to fetch lab report: [${status}] ${serverMsg}`);
            } finally {
                setLoading(false);
            }
        };

        fetchLabRequest();
    }, [id]);

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50">
                <div className="text-center">
                    <Loader className="w-8 h-8 animate-spin text-indigo-600 mx-auto mb-2" />
                    <p className="text-gray-600">Loading lab report...</p>
                </div>
            </div>
        );
    }

    if (error || !labRequest) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
                <div className="max-w-2xl w-full">
                    <div className="bg-white border border-red-300 rounded-xl shadow-md p-6 text-center">
                        <AlertCircle className="w-12 h-12 text-red-600 mx-auto mb-4" />
                        <h2 className="text-xl font-bold text-red-700 mb-2">Error Loading Report</h2>
                        <p className="text-gray-600 mb-6">{error || "The requested lab report could not be found."}</p>
                        <button
                            onClick={() => navigate(-1)}
                            className="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium"
                        >
                            Go Back
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    const { patient, doctor, tests, labTechnician } = labRequest;

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
                            Print Lab Report
                        </h1>
                    </div>
                    <button
                        onClick={() => window.print()}
                        className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors shadow-sm font-medium"
                    >
                        <Printer size={18} />
                        Print Report
                    </button>
                </div>
            </div>

            {/* Printable Content */}
            <div className="max-w-4xl mx-auto p-6 md:p-8 print:p-0 print:max-w-none">
                <div className="bg-white shadow-lg rounded-xl overflow-hidden print:shadow-none print:rounded-none">

                    {/* Pro Letterhead */}
                    <div className="p-6 border-b-4 border-indigo-600 relative overflow-hidden print:p-4">
                        <div className="flex justify-between items-center relative z-10">
                            <div className="flex items-center gap-4">
                                <img src={logo} alt="Logo" className="w-16 h-16 rounded-xl object-cover shadow-lg border border-indigo-100" />
                                <div>
                                    <h1 className="text-3xl font-sans font-black text-indigo-900 tracking-tight uppercase leading-none mb-1">
                                        Naitiri Jambo
                                    </h1>
                                    <h2 className="text-xl font-sans font-bold text-gray-600 tracking-wide uppercase">
                                        Healthcare HMIS
                                    </h2>
                                    <p className="text-xs text-indigo-800 mt-2 font-semibold tracking-widest uppercase">Excellence in Diagnostics</p>
                                </div>
                            </div>
                            <div className="text-right space-y-1">
                                <div className="flex items-center justify-end gap-2 text-gray-600 text-sm">
                                    <span>Tongaren, Bungoma</span>
                                    <div className="p-1 bg-indigo-50 rounded-full"><MapPin size={14} className="text-indigo-600" /></div>
                                </div>
                                <div className="flex items-center justify-end gap-2 text-gray-600 text-sm">
                                    <span>+254 792 100336</span>
                                    <div className="p-1 bg-indigo-50 rounded-full"><Phone size={14} className="text-indigo-600" /></div>
                                </div>
                                <div className="flex items-center justify-end gap-2 text-gray-600 text-sm">
                                    <span>info@naitirijambo.com</span>
                                    <div className="p-1 bg-indigo-50 rounded-full"><Mail size={14} className="text-indigo-600" /></div>
                                </div>
                            </div>
                        </div>
                        {/* Decorative background element */}
                        <div className="absolute -top-10 -right-10 w-40 h-40 bg-indigo-50 rounded-full opacity-50 z-0"></div>
                    </div>

                    {/* Document Title Bar */}
                    <div className="bg-gray-50 border-b border-gray-200 px-6 py-2 flex justify-between items-center print:bg-gray-100 print:px-4 print:py-1">
                        <h3 className="text-base font-bold text-gray-800 uppercase tracking-wide">Laboratory Report</h3>
                        <span className="text-xs font-mono text-gray-500">LAB NO: {labRequest.request_number}</span>
                    </div>

                    {/* Patient & Request Info Grid */}
                    <div className="p-6 border-b border-gray-200 print:p-4">
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm mb-4">
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Patient Name</p>
                                <p className="font-bold text-gray-900 text-sm">{patient?.first_name} {patient?.last_name}</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Patient ID (UPID)</p>
                                <p className="font-medium text-gray-800 font-mono text-sm">{patient?.upid || "N/A"}</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Gender / Age</p>
                                <p className="font-medium text-gray-800 text-sm">{patient?.gender}, {patient?.age || "?"} yrs</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Request Date</p>
                                <p className="font-medium text-gray-800 text-sm">{new Date(labRequest.request_date).toLocaleString()}</p>
                            </div>
                        </div>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm pt-3 border-t border-gray-100">
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Requested By</p>
                                <p className="font-medium text-gray-800 text-sm">Dr. {doctor?.first_name} {doctor?.last_name}</p>
                            </div>
                            <div className="space-y-0.5">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Lab Technician</p>
                                <p className="font-medium text-gray-800 text-sm">{labTechnician ? `${labTechnician.first_name} ${labTechnician.last_name}` : "Pending"}</p>
                            </div>
                            <div className="space-y-0.5 md:col-span-2">
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Clinical Notes</p>
                                <p className="text-xs text-gray-600 italic line-clamp-2">{labRequest.clinical_notes || "None provided"}</p>
                            </div>
                        </div>
                    </div>

                    {/* Test Results */}
                    <div className="p-6 space-y-6 print:p-4 print:space-y-4">
                        {tests && tests.map((test, index) => (
                            <div key={test.id} className="border border-gray-200 rounded-lg overflow-hidden page-break-inside-avoid">
                                <div className="bg-gray-50 border-b border-gray-200 px-4 py-2 flex justify-between items-center print:bg-gray-100">
                                    <h4 className="font-bold text-gray-800 flex items-center gap-2">
                                        <FlaskConical size={16} className="text-indigo-600" />
                                        {test.template?.name}
                                    </h4>
                                    <span className="text-xs font-mono px-2 py-0.5 bg-white border border-gray-200 rounded text-gray-600 uppercase">
                                        Status: {test.status}
                                    </span>
                                </div>
                                
                                <div className="p-4">
                                    {test.status === 'completed' && test.result ? (
                                        <div className="overflow-x-auto">
                                            <table className="w-full text-sm">
                                                <thead>
                                                    <tr className="text-left text-xs font-bold text-gray-500 uppercase tracking-wider border-b border-gray-200">
                                                        <th className="pb-2 pl-2">Parameter</th>
                                                        <th className="pb-2">Result</th>
                                                        <th className="pb-2">Reference Range</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-gray-100">
                                                    {test.result.parameters?.map((paramResult) => {
                                                        const p = paramResult.parameter;
                                                        const isNumeric = p?.result_type === 'range';
                                                        const val = paramResult.value;
                                                        
                                                        // Check if out of range for highlight
                                                        const isOutOfRange = paramResult.is_abnormal;

                                                        return (
                                                            <tr key={paramResult.id}>
                                                                <td className="py-2 pl-2 font-medium text-gray-800">{p?.name || "Unknown Parameter"}</td>
                                                                <td className="py-2">
                                                                    <span className={`font-bold ${isOutOfRange ? 'text-red-600 bg-red-50 px-2 py-0.5 rounded' : 'text-gray-900'}`}>
                                                                        {val} {p?.unit || ''}
                                                                        {isOutOfRange && <AlertCircle size={12} className="inline ml-1" />}
                                                                    </span>
                                                                </td>
                                                                <td className="py-2 text-xs text-gray-500">
                                                                    {isNumeric 
                                                                        ? `${p?.normal_range_min || ''} - ${p?.normal_range_max || ''} ${p?.unit || ''}`
                                                                        : 'Negative'
                                                                    }
                                                                </td>
                                                            </tr>
                                                        );
                                                    })}
                                                </tbody>
                                            </table>
                                            
                                            {test.result.remarks && (
                                                <div className="mt-4 p-3 bg-gray-50 rounded-lg text-sm border border-gray-100">
                                                    <span className="font-bold text-gray-700 uppercase text-[10px] block mb-1">Technician Remarks:</span>
                                                    <span className="text-gray-700 italic">{test.result.remarks}</span>
                                                </div>
                                            )}
                                        </div>
                                    ) : (
                                        <div className="text-center py-6 text-gray-500 text-sm italic">
                                            Results pending or not yet published.
                                        </div>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Pro Footer */}
                    <div className="p-4 mt-auto border-t-2 border-indigo-900 flex flex-col items-center mb-0 print:mb-0">
                        <div className="flex justify-between w-full mb-4 px-8 print:mb-8">
                            <div className="text-center w-48 border-t border-gray-400 pt-1 mt-8">
                                <p className="text-xs font-bold text-gray-800 uppercase">Pathologist / Lab Tech</p>
                                <p className="text-[10px] text-gray-500">Sign & Stamp</p>
                            </div>
                            <div className="text-center w-48 border-t border-gray-400 pt-1 mt-8">
                                <p className="text-xs font-bold text-gray-800 uppercase">Reviewing Doctor</p>
                                <p className="text-[10px] text-gray-500">Sign & Stamp</p>
                            </div>
                        </div>
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

export default LabReportPrint;
