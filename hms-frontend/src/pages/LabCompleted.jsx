import React, { useState, useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import DashboardLayout from '../layout/DashboardLayout';
import { AuthContext } from '../context/AuthContext';
import { useLabNotification } from '../context/LabNotificationContext';
import {
    Microscope,
    CheckCircle2,
    User,
    Clock,
    ChevronRight,
    Eye,
    AlertTriangle,
} from 'lucide-react';

const LabCompleted = () => {
    const navigate = useNavigate();
    const { user } = useContext(AuthContext);
    const { refreshLabCount } = useLabNotification();

    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);
    const [reviewingId, setReviewingId] = useState(null);
    const [page, setPage] = useState(1);
    const [meta, setMeta] = useState({ current_page: 1, last_page: 1, total: 0 });

    const API_BASE = `${import.meta.env.VITE_API_BASE_URL}/api`;
    const token = localStorage.getItem('token');

    const loadCompleted = async (p = 1) => {
        setLoading(true);
        try {
            const res = await axios.get(`${API_BASE}/lab/requests`, {
                headers: { Authorization: `Bearer ${token}` },
                params: {
                    status: 'completed',
                    page: p,
                    per_page: 20,
                },
            });

            const allData = res.data?.data ?? res.data ?? [];
            // Only show unreviewed items (reviewed_at == null)
            const unreviewed = Array.isArray(allData)
                ? allData.filter(r => !r.reviewed_at)
                : [];

            setRequests(unreviewed);
            if (res.data?.current_page) {
                setMeta({
                    current_page: res.data.current_page,
                    last_page: res.data.last_page,
                    total: res.data.total,
                });
            }
        } catch (err) {
            console.error('Error loading completed lab requests:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadCompleted(1);
        // Refresh badge count whenever this page is opened
        refreshLabCount();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const handleMarkReviewed = async (requestId) => {
        setReviewingId(requestId);
        try {
            await axios.post(
                `${API_BASE}/lab/requests/${requestId}/review`,
                {},
                { headers: { Authorization: `Bearer ${token}` } }
            );
            // Remove it from the list immediately
            setRequests(prev => prev.filter(r => r.id !== requestId));
            // Refresh the sidebar badge count
            refreshLabCount();
        } catch (err) {
            console.error('Error marking as reviewed:', err);
            alert(err.response?.data?.message || 'Failed to mark as reviewed');
        } finally {
            setReviewingId(null);
        }
    };

    const getPriorityStyle = (priority) => {
        if (priority === 'stat') return 'bg-red-100 text-red-700 border-red-300';
        if (priority === 'urgent') return 'bg-orange-100 text-orange-700 border-orange-300';
        return 'bg-blue-100 text-blue-700 border-blue-300';
    };

    return (
        <DashboardLayout>
            <div className="min-h-screen bg-gray-50 pt-24 p-6">
                {/* Header */}
                <div className="mb-6">
                    <h1 className="text-3xl font-bold text-gray-800 flex items-center gap-3">
                        <Microscope className="w-8 h-8 text-green-600" />
                        Completed Lab Results
                    </h1>
                    <p className="text-gray-600 mt-1">
                        Lab requests completed and awaiting review. Mark as reviewed to dismiss.
                    </p>
                </div>

                {/* Table */}
                <div className="bg-white rounded-xl shadow-md">
                    <div className="p-6">
                        {loading ? (
                            <div className="text-center py-16">
                                <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-green-600" />
                                <p className="text-gray-500 mt-3">Loading results...</p>
                            </div>
                        ) : requests.length === 0 ? (
                            <div className="text-center py-16">
                                <CheckCircle2 className="w-16 h-16 text-green-300 mx-auto mb-4" />
                                <p className="text-gray-600 font-medium text-lg">All caught up!</p>
                                <p className="text-gray-400 text-sm mt-1">No unreviewed completed lab results.</p>
                            </div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead className="bg-gray-50 border-b border-gray-200">
                                        <tr>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Request #</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Patient</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">UPID</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Doctor</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Tests</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Priority</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Completed</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100">
                                        {requests.map((req) => (
                                            <tr key={req.id} className="hover:bg-gray-50 transition-colors">
                                                <td className="px-4 py-3 font-mono text-gray-800 font-medium">
                                                    {req.request_number}
                                                </td>
                                                <td className="px-4 py-3 font-medium text-gray-800">
                                                    {req.patient?.first_name} {req.patient?.last_name}
                                                </td>
                                                <td className="px-4 py-3 text-gray-600">
                                                    {req.patient?.upid || '—'}
                                                </td>
                                                <td className="px-4 py-3 text-gray-600">
                                                    Dr. {req.doctor?.first_name || 'N/A'}
                                                </td>
                                                <td className="px-4 py-3 text-gray-600">
                                                    {req.tests?.length || 0} test(s)
                                                    <div className="text-xs text-gray-400 mt-0.5 space-y-0.5">
                                                        {req.tests?.slice(0, 2).map((t, i) => (
                                                            <div key={i}>{t.template?.name}</div>
                                                        ))}
                                                        {req.tests?.length > 2 && <div>+{req.tests.length - 2} more</div>}
                                                    </div>
                                                </td>
                                                <td className="px-4 py-3">
                                                    <span className={`px-2 py-1 text-xs rounded-full border font-medium ${getPriorityStyle(req.priority)}`}>
                                                        {req.priority?.toUpperCase()}
                                                    </span>
                                                </td>
                                                <td className="px-4 py-3 text-gray-500 text-xs">
                                                    <div className="flex items-center gap-1">
                                                        <Clock className="w-3.5 h-3.5" />
                                                        {new Date(req.updated_at).toLocaleString()}
                                                    </div>
                                                </td>
                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-2">
                                                        {/* View Patient */}
                                                        <button
                                                            onClick={() => navigate(`/patients/${req.patient_id}`)}
                                                            className="flex items-center gap-1 bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                                        >
                                                            <User className="w-3.5 h-3.5" />
                                                            View Patient
                                                        </button>
                                                        {/* Mark Reviewed */}
                                                        <button
                                                            onClick={() => handleMarkReviewed(req.id)}
                                                            disabled={reviewingId === req.id}
                                                            className="flex items-center gap-1 bg-green-600 hover:bg-green-700 disabled:bg-green-300 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                                        >
                                                            <CheckCircle2 className="w-3.5 h-3.5" />
                                                            {reviewingId === req.id ? 'Reviewing...' : 'Mark Reviewed'}
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>

                    {/* Pagination */}
                    {meta.last_page > 1 && (
                        <div className="px-6 py-4 border-t bg-gray-50 flex items-center justify-between">
                            <p className="text-sm text-gray-600">
                                Page {meta.current_page} of {meta.last_page}
                            </p>
                            <div className="flex gap-2">
                                <button
                                    onClick={() => { setPage(p => p - 1); loadCompleted(page - 1); }}
                                    disabled={meta.current_page === 1}
                                    className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    Previous
                                </button>
                                <button
                                    onClick={() => { setPage(p => p + 1); loadCompleted(page + 1); }}
                                    disabled={meta.current_page === meta.last_page}
                                    className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    Next
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </DashboardLayout>
    );
};

export default LabCompleted;
