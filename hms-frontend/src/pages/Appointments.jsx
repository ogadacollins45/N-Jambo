import React, { useEffect, useState, useContext } from "react";
import axios from "axios";
import DashboardLayout from "../layout/DashboardLayout";
import { AuthContext } from "../context/AuthContext";
import CreateAppointmentModal from "../components/CreateAppointmentModal";
import {
    Calendar,
    Clock,
    User,
    Stethoscope,
    Filter,
    Search,
    AlertCircle,
    CheckCircle,
    XCircle,
    Loader,
    Plus,
    Edit,
} from "lucide-react";

export default function Appointments() {
    const { user } = useContext(AuthContext);
    const role = user?.role || localStorage.getItem("role");
    const userId = user?.id || localStorage.getItem("userId");

    const [appointments, setAppointments] = useState([]);
    const [doctors, setDoctors] = useState([]);
    const [selectedDoctor, setSelectedDoctor] = useState("");
    const [statusFilter, setStatusFilter] = useState("all");
    const [searchQuery, setSearchQuery] = useState("");
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [totalAppointments, setTotalAppointments] = useState(0);
    const [showCreateModal, setShowCreateModal] = useState(false);
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 20;

    const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

    // Fetch doctors list (for admin)
    useEffect(() => {
        if (role === "admin") {
            const fetchDoctors = async () => {
                try {
                    const res = await axios.get(`${API_BASE_URL}/doctors`);
                    setDoctors(res.data || []);
                    if (res.data && res.data.length > 0) {
                        setSelectedDoctor(res.data[0].id.toString());
                    }
                } catch (err) {
                    console.error("Failed to load doctors", err);
                }
            };
            fetchDoctors();
        }
    }, [role, API_BASE_URL]);

    // Fetch appointments
    const fetchAppointments = async (currentPage = 1) => {
        setLoading(true);
        setError("");
        try {
            const doctorIdToFetch = role === "doctor" ? userId : selectedDoctor;

            if (!doctorIdToFetch) {
                setLoading(false);
                return;
            }

            const res = await axios.get(`${API_BASE_URL}/appointments`, {
                params: {
                    doctor_id: doctorIdToFetch,
                    page: currentPage,
                    status: statusFilter,
                    search: searchQuery
                }
            });
            setAppointments(res.data.data || []);
            setTotalPages(res.data.last_page || 1);
            setTotalAppointments(res.data.total || 0);
        } catch (err) {
            console.error("Failed to load appointments", err);
            setError("Unable to load appointments. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        if (role === "doctor" || (role === "admin" && selectedDoctor)) {
            fetchAppointments(page);
        } else if (role === "admin" && !selectedDoctor) {
            setLoading(false);
        }
    }, [role, userId, selectedDoctor, page, statusFilter, searchQuery]);

    // Pagination
    // We already fetch paginated data from the server, and the backend handles filtering.
    const paginatedAppointments = appointments;

    const getStatusBadge = (status) => {
        const normalizedStatus = status?.toLowerCase() || "scheduled";
        const styles = {
            pending: "bg-yellow-100 text-yellow-700",
            scheduled: "bg-blue-100 text-blue-700",
            confirmed: "bg-green-100 text-green-700",
            completed: "bg-green-100 text-green-700",
            cancelled: "bg-red-100 text-red-700",
        };
        const icons = {
            pending: <Clock className="w-3 h-3" />,
            scheduled: <Calendar className="w-3 h-3" />,
            confirmed: <CheckCircle className="w-3 h-3" />,
            completed: <CheckCircle className="w-3 h-3" />,
            cancelled: <XCircle className="w-3 h-3" />,
        };
        return (
            <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${styles[normalizedStatus] || "bg-gray-100 text-gray-700"}`}>
                {icons[normalizedStatus]}
                {status}
            </span>
        );
    };

    const handleStatusUpdate = async (appointmentId, newStatus) => {
        try {
            await axios.put(`${API_BASE_URL}/appointments/${appointmentId}`, {
                status: newStatus
            });
            // Refresh appointments
            fetchAppointments();
        } catch (err) {
            console.error("Failed to update status", err);
            alert("Failed to update appointment status");
        }
    };

    return (
        <DashboardLayout>
            <div className="min-h-screen">
                <div className="w-full max-w-full">
                    {/* Header */}
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6 mt-14">
                        <div>
                            <h1 className="text-2xl md:text-3xl font-bold text-gray-800 flex items-center gap-2">
                                <Calendar className="w-6 h-6 md:w-7 md:h-7 text-indigo-600" />
                                Appointments
                            </h1>
                            <p className="text-sm text-gray-600 mt-1">
                                {role === "admin" ? "View and manage appointments by doctor" : "View and manage your appointments"}
                            </p>
                        </div>
                        <button
                            onClick={() => setShowCreateModal(true)}
                            className="bg-indigo-600 text-white px-4 md:px-6 py-2 md:py-3 rounded-lg hover:bg-indigo-700 transition-all shadow-md flex items-center gap-2 font-semibold text-sm md:text-base"
                        >
                            <Plus className="w-4 h-4 md:w-5 md:h-5" />
                            <span className="hidden sm:inline">New Appointment</span>
                            <span className="sm:hidden">New</span>
                        </button>
                    </div>

                    {/* Filters */}
                    <div className="bg-white rounded-xl shadow-md border border-gray-200 p-4 md:p-6 mb-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                            {/* Doctor Selector (Admin only) */}
                            {role === "admin" && (
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                        <Stethoscope className="inline-block w-4 h-4 mr-1" />
                                        Select Doctor
                                    </label>
                                    <select
                                        value={selectedDoctor}
                                        onChange={(e) => setSelectedDoctor(e.target.value)}
                                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                                    >
                                        <option value="">Choose a doctor...</option>
                                        {doctors.map((doc) => (
                                            <option key={doc.id} value={doc.id}>
                                                Dr. {doc.first_name} {doc.last_name}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            )}

                            {/* Status Filter */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    <Filter className="inline-block w-4 h-4 mr-1" />
                                    Status
                                </label>
                                <select
                                    value={statusFilter}
                                    onChange={(e) => setStatusFilter(e.target.value)}
                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                                >
                                    <option value="all">All Statuses</option>
                                    <option value="scheduled">Scheduled</option>
                                    <option value="pending">Pending</option>
                                    <option value="confirmed">Confirmed</option>
                                    <option value="completed">Completed</option>
                                    <option value="cancelled">Cancelled</option>
                                </select>
                            </div>

                            {/* Search */}
                            <div className="md:col-span-2">
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    <Search className="inline-block w-4 h-4 mr-1" />
                                    Search Patient
                                </label>
                                <input
                                    type="text"
                                    placeholder="Search by name or phone..."
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                                />
                            </div>
                        </div>
                    </div>

                    {/* Content */}
                    {loading ? (
                        <div className="flex items-center justify-center py-20">
                            <div className="text-center">
                                <Loader className="animate-spin h-12 w-12 text-indigo-500 mx-auto mb-4" />
                                <p className="text-sm font-medium text-gray-600">Loading appointments...</p>
                            </div>
                        </div>
                    ) : error ? (
                        <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded-lg flex items-center">
                            <AlertCircle className="w-6 h-6 mr-3 flex-shrink-0" />
                            <p className="text-sm md:text-base">{error}</p>
                        </div>
                    ) : role === "admin" && !selectedDoctor ? (
                        <div className="bg-blue-50 border border-blue-200 rounded-xl p-8 text-center">
                            <Stethoscope className="w-16 h-16 text-blue-400 mx-auto mb-4" />
                            <p className="text-lg font-medium text-gray-700">Please select a doctor to view appointments</p>
                            <p className="text-sm text-gray-600 mt-2">Use the dropdown above to choose a doctor</p>
                        </div>
                    ) : filteredAppointments.length === 0 ? (
                        <div className="bg-gray-50 border border-gray-200 rounded-xl p-8 text-center">
                            <Calendar className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                            <p className="text-lg font-medium text-gray-700">No appointments found</p>
                            <p className="text-sm text-gray-600 mt-2">
                                {searchQuery || statusFilter !== "all" ? "Try adjusting your filters" : "Click 'New Appointment' to schedule one"}
                            </p>
                        </div>
                    ) : (
                        <>
                            <div className="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
                                <div className="overflow-x-auto">
                                    <table className="w-full text-left border-collapse min-w-[640px]">
                                        <thead>
                                            <tr className="border-b-2 border-gray-200 bg-gray-50">
                                                <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Date & Time</th>
                                                <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Patient</th>
                                                <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Contact</th>
                                                {role === "admin" && <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Doctor</th>}
                                                <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Status</th>
                                                <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700 text-center">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {paginatedAppointments.map((apt, index) => (
                                                <tr key={apt.id || index} className="border-b border-gray-100 hover:bg-blue-50 transition-colors">
                                                    <td className="py-3 px-4 text-xs md:text-sm text-gray-800">
                                                        <div className="flex items-center gap-2">
                                                            <Calendar className="w-4 h-4 text-gray-400" />
                                                            <div>
                                                                <div className="font-medium">{new Date(apt.appointment_time).toLocaleDateString()}</div>
                                                                <div className="text-xs text-gray-600">{new Date(apt.appointment_time).toLocaleTimeString()}</div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td className="py-3 px-4 text-xs md:text-sm">
                                                        <div className="flex items-center gap-2">
                                                            <User className="w-4 h-4 text-gray-400" />
                                                            <span className="font-medium text-gray-800">
                                                                {apt.patient ? `${apt.patient.first_name} ${apt.patient.last_name}` : "N/A"}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td className="py-3 px-4 text-xs md:text-sm text-gray-600">
                                                        {apt.patient?.phone || "N/A"}
                                                    </td>
                                                    {role === "admin" && (
                                                        <td className="py-3 px-4 text-xs md:text-sm text-gray-700">
                                                            {apt.doctor ? `Dr. ${apt.doctor.first_name} ${apt.doctor.last_name}` : "N/A"}
                                                        </td>
                                                    )}
                                                    <td className="py-3 px-4">{getStatusBadge(apt.status)}</td>
                                                    <td className="py-3 px-4 text-center">
                                                        <div className="flex items-center justify-center gap-2">
                                                            <select
                                                                value={apt.status.toLowerCase()}
                                                                onChange={(e) => handleStatusUpdate(apt.id, e.target.value)}
                                                                className="text-xs px-2 py-1 border border-gray-300 rounded focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                                            >
                                                                <option value="scheduled">Scheduled</option>
                                                                <option value="confirmed">Confirmed</option>
                                                                <option value="completed">Completed</option>
                                                                <option value="cancelled">Cancelled</option>
                                                            </select>
                                                        </div>
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>

                                {/* Footer with Pagination */}
                                <div className="px-4 py-3 bg-gray-50 border-t border-gray-200 flex flex-col sm:flex-row justify-between items-center gap-3">
                                    <p className="text-xs md:text-sm text-gray-600">
                                        Showing <span className="font-semibold text-gray-800">{((page - 1) * 15) + (paginatedAppointments.length > 0 ? 1 : 0)}</span> to{" "}
                                        <span className="font-semibold text-gray-800">{((page - 1) * 15) + paginatedAppointments.length}</span> of{" "}
                                        <span className="font-semibold text-gray-800">{totalAppointments}</span> appointments
                                    </p>

                                    {totalPages > 1 && (
                                        <div className="flex gap-2">
                                            <button
                                                onClick={() => setPage(Math.max(1, page - 1))}
                                                disabled={page === 1}
                                                className="px-3 py-1 text-sm border border-gray-300 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                            >
                                                Previous
                                            </button>
                                            <span className="px-3 py-1 text-sm">
                                                Page {page} of {totalPages}
                                            </span>
                                            <button
                                                onClick={() => setPage(Math.min(totalPages, page + 1))}
                                                disabled={page === totalPages}
                                                className="px-3 py-1 text-sm border border-gray-300 rounded hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                            >
                                                Next
                                            </button>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </>
                    )}
                </div>
            </div>

            {/* Create Appointment Modal */}
            {showCreateModal && (
                <CreateAppointmentModal
                    onClose={() => setShowCreateModal(false)}
                    onSuccess={() => {
                        setShowCreateModal(false);
                        fetchAppointments();
                    }}
                    userRole={role}
                    userId={userId}
                    selectedDoctorId={selectedDoctor}
                />
            )}
        </DashboardLayout>
    );
}
