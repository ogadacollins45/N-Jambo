import React, { useState, useEffect } from 'react';
import axios from 'axios';
import DashboardLayout from '../layout/DashboardLayout';
import { Microscope, Clock, AlertTriangle, ChevronRight, Search, Calendar, BarChart2, ClipboardList, Download } from 'lucide-react';

const LabQueue = () => {
    const [activeTab, setActiveTab] = useState('queue');

    // ─── Queue Tab State ───────────────────────────────────────────────────
    const [requests, setRequests] = useState({ data: [], current_page: 1, last_page: 1, total: 0, from: 0, to: 0 });
    const [loading, setLoading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [debouncedSearch, setDebouncedSearch] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [priorityFilter, setPriorityFilter] = useState('');
    const [showTodayOnly, setShowTodayOnly] = useState(false);
    const [pageJumpValue, setPageJumpValue] = useState('');

    // ─── Reports Tab State ─────────────────────────────────────────────────
    const [reports, setReports] = useState({ data: [], current_page: 1, last_page: 1, total: 0, from: 0, to: 0 });
    const [reportsLoading, setReportsLoading] = useState(false);
    const [reportSearch, setReportSearch] = useState('');
    const [debouncedReportSearch, setDebouncedReportSearch] = useState('');
    const [reportStatusFilter, setReportStatusFilter] = useState('');
    const [reportDateFrom, setReportDateFrom] = useState('');
    const [reportDateTo, setReportDateTo] = useState('');
    const [reportPageJump, setReportPageJump] = useState('');

    const API_BASE = `${import.meta.env.VITE_API_BASE_URL}/api`;
    const token = localStorage.getItem('token');

    // ─── Queue Debounce ────────────────────────────────────────────────────
    useEffect(() => {
        const timer = setTimeout(() => setDebouncedSearch(searchTerm), 500);
        return () => clearTimeout(timer);
    }, [searchTerm]);

    useEffect(() => {
        loadRequests(1);
    }, [debouncedSearch, statusFilter, priorityFilter, showTodayOnly]);

    // ─── Reports Debounce ──────────────────────────────────────────────────
    useEffect(() => {
        const timer = setTimeout(() => setDebouncedReportSearch(reportSearch), 500);
        return () => clearTimeout(timer);
    }, [reportSearch]);

    useEffect(() => {
        if (activeTab === 'reports') loadReports(1);
    }, [activeTab, debouncedReportSearch, reportStatusFilter, reportDateFrom, reportDateTo]);

    // ─── Data Loaders ──────────────────────────────────────────────────────
    const loadRequests = async (page = 1) => {
        setLoading(true);
        try {
            const response = await axios.get(`${API_BASE}/lab/processing/pending`, {
                headers: { Authorization: `Bearer ${token}` },
                params: { page, per_page: 20, search: debouncedSearch, status: statusFilter, priority: priorityFilter, today_only: showTodayOnly }
            });
            setRequests(response.data);
        } catch (err) {
            console.error('Error loading lab requests:', err);
        } finally {
            setLoading(false);
        }
    };

    const loadReports = async (page = 1) => {
        setReportsLoading(true);
        try {
            const params = { page, per_page: 25 };
            if (debouncedReportSearch) params.search = debouncedReportSearch;
            if (reportStatusFilter) params.status = reportStatusFilter;
            if (reportDateFrom) params.date_from = reportDateFrom;
            if (reportDateTo) params.date_to = reportDateTo;

            const response = await axios.get(`${API_BASE}/lab/requests`, {
                headers: { Authorization: `Bearer ${token}` },
                params
            });
            setReports(response.data);
        } catch (err) {
            console.error('Error loading lab reports:', err);
        } finally {
            setReportsLoading(false);
        }
    };

    // ─── Helpers ───────────────────────────────────────────────────────────
    const getPriorityBadge = (priority) => {
        const styles = { stat: 'bg-red-100 text-red-700 border-red-300', urgent: 'bg-orange-100 text-orange-700 border-orange-300', routine: 'bg-blue-100 text-blue-700 border-blue-300' };
        return styles[priority] || styles.routine;
    };

    const getStatusBadge = (status) => {
        const styles = {
            pending: 'bg-yellow-100 text-yellow-700',
            sample_collected: 'bg-blue-100 text-blue-700',
            processing: 'bg-purple-100 text-purple-700',
            completed: 'bg-green-100 text-green-700',
            cancelled: 'bg-red-100 text-red-700',
            rejected: 'bg-gray-100 text-gray-600',
        };
        return styles[status] || styles.pending;
    };

    const formatStatus = (status) => status?.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) || '—';

    const formatDate = (dateStr) => {
        if (!dateStr) return '—';
        return new Date(dateStr).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
    };

    const getResultSummary = (tests) => {
        if (!tests || tests.length === 0) return '—';
        const completed = tests.filter(t => t.status === 'completed');
        if (completed.length === 0) return 'Awaiting results';
        
        const resultParts = completed.map(t => {
            const resultData = t.result;
            if (!resultData) return t.template?.name;
            const params = resultData.parameters || [];
            if (params.length === 0) return t.template?.name;
            // Show first 2 parameter results
            return params.slice(0, 2).map(p => {
                const val = p.numeric_value ?? p.text_value ?? (p.is_positive ? 'Positive' : 'Negative');
                return `${p.parameter?.name ?? ''}: ${val} ${p.unit ?? ''}`.trim();
            }).join(', ');
        });

        return resultParts.join(' | ') || '—';
    };

    // ─── Pagination Helpers ────────────────────────────────────────────────
    const goToPage = (page) => { if (page >= 1 && page <= requests.last_page) { loadRequests(page); setPageJumpValue(''); } };
    const handlePageJump = (e) => { e.preventDefault(); const p = parseInt(pageJumpValue); if (!isNaN(p)) goToPage(p); };
    const goToReportPage = (page) => { if (page >= 1 && page <= reports.last_page) { loadReports(page); setReportPageJump(''); } };
    const handleReportPageJump = (e) => { e.preventDefault(); const p = parseInt(reportPageJump); if (!isNaN(p)) goToReportPage(p); };

    const getPageNumbers = (current, last) => {
        const pages = [];
        if (last <= 7) { for (let i = 1; i <= last; i++) pages.push(i); }
        else {
            pages.push(1);
            if (current > 3) pages.push('...');
            const start = Math.max(2, current - 1);
            const end = Math.min(last - 1, current + 1);
            for (let i = start; i <= end; i++) pages.push(i);
            if (current < last - 2) pages.push('...');
            pages.push(last);
        }
        return pages;
    };

    const PaginationBar = ({ data, onPage, jumpVal, setJumpVal, onJump }) => (
        data.last_page > 0 && (
            <div className="px-6 py-4 border-t bg-gray-50">
                <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
                    <div className="text-sm text-gray-600">
                        {data.total > 0 ? <>Showing <span className="font-medium">{data.from}</span> to <span className="font-medium">{data.to}</span> of <span className="font-medium">{data.total}</span> results</> : 'No results'}
                    </div>
                    {data.last_page > 1 && (
                        <div className="flex items-center gap-2">
                            <button onClick={() => onPage(1)} disabled={data.current_page === 1} className="px-3 py-2 text-sm font-medium border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">First</button>
                            <button onClick={() => onPage(data.current_page - 1)} disabled={data.current_page === 1} className="px-3 py-2 text-sm font-medium border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">Previous</button>
                            <div className="hidden md:flex items-center gap-1">
                                {getPageNumbers(data.current_page, data.last_page).map((page, index) => (
                                    page === '...' ? <span key={`ellipsis-${index}`} className="px-3 py-2 text-gray-500">...</span> :
                                    <button key={page} onClick={() => onPage(page)} className={`px-3 py-2 text-sm font-medium rounded-lg transition-colors ${data.current_page === page ? 'bg-indigo-600 text-white' : 'border border-gray-300 hover:bg-gray-100'}`}>{page}</button>
                                ))}
                            </div>
                            <div className="md:hidden px-3 py-2 text-sm font-medium text-gray-700">Page {data.current_page} of {data.last_page}</div>
                            <button onClick={() => onPage(data.current_page + 1)} disabled={data.current_page === data.last_page} className="px-3 py-2 text-sm font-medium border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">Next</button>
                            <button onClick={() => onPage(data.last_page)} disabled={data.current_page === data.last_page} className="px-3 py-2 text-sm font-medium border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">Last</button>
                            <form onSubmit={onJump} className="hidden lg:flex items-center gap-2 ml-4 pl-4 border-l border-gray-300">
                                <label className="text-sm text-gray-600">Jump to:</label>
                                <input type="number" min="1" max={data.last_page} value={jumpVal} onChange={(e) => setJumpVal(e.target.value)} placeholder={data.current_page.toString()} className="w-16 px-2 py-1 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500" />
                                <button type="submit" className="px-3 py-1 text-sm font-medium bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors">Go</button>
                            </form>
                        </div>
                    )}
                </div>
            </div>
        )
    );

    const filteredRequests = requests.data || [];
    const filteredReports = reports.data || [];

    return (
        <DashboardLayout>
            <div className="min-h-screen bg-gray-50 pt-24 p-6">
                {/* Header */}
                <div className="mb-6">
                    <h1 className="text-3xl font-bold text-gray-800 flex items-center">
                        <Microscope className="w-8 h-8 text-indigo-600 mr-3" />
                        Laboratory
                    </h1>
                    <p className="text-gray-600 mt-2">Manage lab requests and view reports</p>
                </div>

                {/* Tabs */}
                <div className="flex gap-1 bg-white border border-gray-200 rounded-xl p-1 mb-6 w-fit shadow-sm">
                    <button
                        onClick={() => setActiveTab('queue')}
                        className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-semibold transition-all duration-200 ${activeTab === 'queue' ? 'bg-indigo-600 text-white shadow-md' : 'text-gray-600 hover:bg-gray-100'}`}
                    >
                        <ClipboardList className="w-4 h-4" />
                        Lab Queue
                    </button>
                    <button
                        onClick={() => setActiveTab('reports')}
                        className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-semibold transition-all duration-200 ${activeTab === 'reports' ? 'bg-indigo-600 text-white shadow-md' : 'text-gray-600 hover:bg-gray-100'}`}
                    >
                        <BarChart2 className="w-4 h-4" />
                        Lab Reports
                    </button>
                </div>

                {/* ─── QUEUE TAB ─────────────────────────────────────────────── */}
                {activeTab === 'queue' && (
                    <>
                        {/* Filters */}
                        <div className="bg-white rounded-xl shadow-md p-6 mb-6">
                            <div className="mb-4 flex gap-2">
                                <button
                                    onClick={() => setShowTodayOnly(!showTodayOnly)}
                                    className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all ${showTodayOnly ? 'bg-indigo-600 text-white shadow-md' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                                >
                                    <Calendar className="w-4 h-4" />
                                    {showTodayOnly ? "Showing Today's Requests" : "Show Today Only"}
                                </button>
                                {showTodayOnly && (
                                    <button onClick={() => setShowTodayOnly(false)} className="px-4 py-2 text-sm text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-all">Clear</button>
                                )}
                            </div>
                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2"><Search className="w-4 h-4 inline mr-1" />Search</label>
                                    <input type="text" placeholder="Patient name, UPID, or request #" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                                    <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500">
                                        <option value="">All Statuses</option>
                                        <option value="pending">Pending</option>
                                        <option value="sample_collected">Sample Collected</option>
                                        <option value="processing">Processing</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">Priority</label>
                                    <select value={priorityFilter} onChange={(e) => setPriorityFilter(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500">
                                        <option value="">All Priorities</option>
                                        <option value="stat">STAT</option>
                                        <option value="urgent">Urgent</option>
                                        <option value="routine">Routine</option>
                                    </select>
                                </div>
                                <div className="flex items-end">
                                    <button onClick={() => loadRequests(1)} className="w-full bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition">Refresh</button>
                                </div>
                            </div>
                        </div>

                        {/* Queue Table */}
                        <div className="bg-white rounded-xl shadow-md">
                            <div className="p-6">
                                {loading ? (
                                    <div className="text-center py-12">
                                        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                                        <p className="text-gray-600 mt-2">Loading requests...</p>
                                    </div>
                                ) : filteredRequests?.length === 0 ? (
                                    <div className="text-center py-12">
                                        <Microscope className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                        <p className="text-gray-600">No pending lab requests</p>
                                    </div>
                                ) : (
                                    <div className="overflow-x-auto">
                                        <table className="w-full">
                                            <thead className="bg-gray-50">
                                                <tr>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Request #</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">UPID</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Patient</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Doctor</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Tests</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Priority</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Status</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Date</th>
                                                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Action</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-200">
                                                {filteredRequests?.map((request) => (
                                                    <tr key={request.id} className="hover:bg-gray-50">
                                                        <td className="px-4 py-3 text-sm font-mono text-gray-800">{request.request_number}</td>
                                                        <td className="px-4 py-3 text-sm font-medium text-gray-700">{request.patient?.upid || '-'}</td>
                                                        <td className="px-4 py-3 text-sm text-gray-800">{request.patient?.first_name} {request.patient?.last_name}</td>
                                                        <td className="px-4 py-3 text-sm text-gray-600">Dr. {request.doctor?.first_name || 'N/A'}</td>
                                                        <td className="px-4 py-3 text-sm text-gray-600">
                                                            {request.tests?.length || 0} test(s)
                                                            <div className="text-xs text-gray-500 mt-1 space-y-1">
                                                                {request.tests?.slice(0, 2).map((t, idx) => (
                                                                    <div key={idx} className="flex items-center gap-1">
                                                                        <span>{t.template?.name}</span>
                                                                        {t.template?.parameters?.some(p => p.result_type === 'binary') && (
                                                                            <span className="px-1.5 py-0.5 bg-purple-100 text-purple-700 rounded text-[10px]">Pos/Neg</span>
                                                                        )}
                                                                    </div>
                                                                ))}
                                                                {request.tests?.length > 2 && <div>...</div>}
                                                            </div>
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <span className={`px-2 py-1 text-xs rounded-full border ${getPriorityBadge(request.priority)}`}>{request.priority?.toUpperCase()}</span>
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <span className={`px-2 py-1 text-xs rounded-full ${getStatusBadge(request.status)}`}>{request.status?.replace('_', ' ')}</span>
                                                        </td>
                                                        <td className="px-4 py-3 text-sm text-gray-600">
                                                            <div className="flex items-center"><Clock className="w-4 h-4 mr-1" />{new Date(request.request_date).toLocaleString()}</div>
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <button onClick={() => window.location.href = `/lab/processing/${request.id}`} className="bg-indigo-600 text-white px-3 py-1 rounded-lg hover:bg-indigo-700 transition flex items-center text-sm">
                                                                Process<ChevronRight className="w-4 h-4 ml-1" />
                                                            </button>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                )}
                            </div>
                            <PaginationBar data={requests} onPage={goToPage} jumpVal={pageJumpValue} setJumpVal={setPageJumpValue} onJump={handlePageJump} />
                        </div>
                    </>
                )}

                {/* ─── REPORTS TAB ────────────────────────────────────────────── */}
                {activeTab === 'reports' && (
                    <>
                        {/* Reports Filters */}
                        <div className="bg-white rounded-xl shadow-md p-6 mb-6">
                            <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2"><Search className="w-4 h-4 inline mr-1" />Search</label>
                                    <input type="text" placeholder="Patient name or Lab No." value={reportSearch} onChange={(e) => setReportSearch(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                                    <select value={reportStatusFilter} onChange={(e) => setReportStatusFilter(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500">
                                        <option value="">All Statuses</option>
                                        <option value="pending">Pending</option>
                                        <option value="sample_collected">Sample Collected</option>
                                        <option value="processing">Processing</option>
                                        <option value="completed">Completed</option>
                                        <option value="cancelled">Cancelled</option>
                                        <option value="rejected">Rejected</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2"><Calendar className="w-4 h-4 inline mr-1" />Date From</label>
                                    <input type="date" value={reportDateFrom} onChange={(e) => setReportDateFrom(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2"><Calendar className="w-4 h-4 inline mr-1" />Date To</label>
                                    <input type="date" value={reportDateTo} onChange={(e) => setReportDateTo(e.target.value)} className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500" />
                                </div>
                                <div className="flex items-end gap-2">
                                    <button onClick={() => loadReports(1)} className="flex-1 bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition">Refresh</button>
                                    <button
                                        onClick={() => { setReportSearch(''); setDebouncedReportSearch(''); setReportStatusFilter(''); setReportDateFrom(''); setReportDateTo(''); }}
                                        className="px-4 py-2 text-sm border border-gray-300 text-gray-600 rounded-lg hover:bg-gray-100 transition"
                                    >
                                        Clear
                                    </button>
                                </div>
                            </div>
                        </div>

                        {/* Reports Table */}
                        <div className="bg-white rounded-xl shadow-md">
                            <div className="p-6">
                                {reportsLoading ? (
                                    <div className="text-center py-12">
                                        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                                        <p className="text-gray-600 mt-2">Loading reports...</p>
                                    </div>
                                ) : filteredReports?.length === 0 ? (
                                    <div className="text-center py-12">
                                        <BarChart2 className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                        <p className="text-gray-500 font-medium">No lab records found</p>
                                        <p className="text-sm text-gray-400 mt-1">Try adjusting your filters</p>
                                    </div>
                                ) : (
                                    <div className="overflow-x-auto">
                                        <table className="w-full text-sm">
                                            <thead className="bg-gray-50">
                                                <tr>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Date</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Lab No.</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Name of Patient</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Age</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Gender</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Tests</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide min-w-[200px]">Results</th>
                                                    <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Status</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-100">
                                                {filteredReports.map((req) => (
                                                    <tr key={req.id} className="hover:bg-gray-50 transition-colors">
                                                        <td className="px-4 py-3 text-gray-700 whitespace-nowrap">{formatDate(req.request_date || req.created_at)}</td>
                                                        <td className="px-4 py-3">
                                                            <span className="font-mono text-indigo-700 text-xs bg-indigo-50 px-2 py-1 rounded">{req.request_number}</span>
                                                        </td>
                                                        <td className="px-4 py-3 font-medium text-gray-800 whitespace-nowrap">
                                                            {req.patient?.first_name} {req.patient?.last_name}
                                                            {req.patient?.upid && <div className="text-xs text-gray-400 font-normal">{req.patient.upid}</div>}
                                                        </td>
                                                        <td className="px-4 py-3 text-gray-600">{req.patient?.age ?? '—'}</td>
                                                        <td className="px-4 py-3 text-gray-600">
                                                            {req.patient?.gender ? (req.patient.gender === 'M' || req.patient.gender === 'Male' ? 'Male' : 'Female') : '—'}
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <div className="space-y-1">
                                                                {req.tests?.map((t, idx) => (
                                                                    <div key={idx} className="text-xs text-gray-700 flex items-center gap-1">
                                                                        <span className={`w-2 h-2 rounded-full flex-shrink-0 ${t.status === 'completed' ? 'bg-green-400' : t.status === 'processing' ? 'bg-purple-400' : 'bg-yellow-400'}`}></span>
                                                                        {t.template?.name || '—'}
                                                                    </div>
                                                                ))}
                                                            </div>
                                                        </td>
                                                        <td className="px-4 py-3 text-xs text-gray-600 max-w-[250px]">
                                                            <div className="line-clamp-3">{getResultSummary(req.tests)}</div>
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <span className={`px-2.5 py-1 text-xs font-medium rounded-full ${getStatusBadge(req.status)}`}>
                                                                {formatStatus(req.status)}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                )}
                            </div>
                            <PaginationBar data={reports} onPage={goToReportPage} jumpVal={reportPageJump} setJumpVal={setReportPageJump} onJump={handleReportPageJump} />
                        </div>
                    </>
                )}
            </div>
        </DashboardLayout>
    );
};

export default LabQueue;
