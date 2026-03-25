import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import axios from "axios";
import {
  Search,
  Eye,
  Bed,
  Activity,
  User,
  Clock,
  ChevronLeft,
  ChevronRight,
  AlertCircle,
} from "lucide-react";
import DashboardLayout from "../layout/DashboardLayout";

const WARDS = ["Medical", "Surgical", "Maternity", "Pediatric", "ICU", "HDU", "Other"];

export default function Admissions() {
  const [admissions, setAdmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Pagination & Filtering
  const [searchTerm, setSearchTerm] = useState("");
  const [activeTab, setActiveTab] = useState("all");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const API_BASE = `${import.meta.env.VITE_API_BASE_URL}/api`;

  useEffect(() => {
    fetchAdmissions();
  }, [currentPage, searchTerm, activeTab]);

  const fetchAdmissions = async () => {
    try {
      setLoading(true);
      const params = { page: currentPage, search: searchTerm };
      if (activeTab !== "all") params.status = activeTab;

      const response = await axios.get(`${API_BASE}/admissions`, {
        params,
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });

      setAdmissions(response.data.data || []);
      setTotalPages(response.data.last_page || 1);
      setError(null);
    } catch (err) {
      console.error("Error fetching admissions:", err);
      setError("Failed to load admissions. Please try again.");
    } finally {
      setLoading(false);
    }
  };
  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchAdmissions();
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case "active":
        return <span className="px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800 flex items-center gap-1"><Activity className="w-3 h-3" /> Active</span>;
      case "discharged":
        return <span className="px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-600 flex items-center gap-1">Discharged</span>;
      default:
        return <span className="px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">{status}</span>;
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleString("en-GB", {
      day: "numeric", month: "short", year: "numeric",
      hour: "2-digit", minute: "2-digit",
    });
  };

  return (
    <DashboardLayout>
      <div className="min-h-screen pt-12">
        <div className="max-w-full">
          <div className="bg-white rounded-xl shadow-md overflow-hidden border border-gray-200">
            {/* Header */}
            <div className="bg-gradient-to-r from-indigo-600 to-blue-600 px-4 md:px-8 py-4 md:py-6">
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                <div>
                  <h1 className="text-2xl md:text-3xl font-bold text-white mb-1 flex items-center gap-2">
                    <Bed className="w-6 h-6 md:w-8 md:h-8" />
                    Admissions
                  </h1>
                  <p className="text-indigo-100 text-xs md:text-sm">Manage and view all inpatient admissions</p>
                </div>
              </div>
            </div>

            {/* Filters */}
            <div className="px-4 md:px-8 py-4 bg-gray-50 border-b border-gray-200">
              <div className="flex flex-col sm:flex-row gap-3 items-stretch justify-between sm:items-center">
                <div className="relative flex-1 max-w-lg">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
                  <form onSubmit={handleSearch} className="w-full">
                    <input
                      type="text"
                      placeholder="Search patient name, ID..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="bg-white border border-gray-300 text-gray-800 rounded-lg pl-9 pr-4 py-2 md:py-3 w-full shadow-sm focus:ring-2 focus:ring-indigo-200 focus:border-indigo-400 outline-none transition-all placeholder-gray-400 text-sm"
                    />
                  </form>
                </div>

                <div className="flex bg-gray-200/70 p-1 rounded-lg">
                  {["all", "active", "discharged"].map((tab) => (
                    <button
                      key={tab}
                      onClick={() => { setActiveTab(tab); setCurrentPage(1); }}
                      className={`px-4 md:px-6 py-2 rounded-md text-sm font-medium capitalize transition-all duration-200 ${activeTab === tab
                        ? "bg-white text-indigo-700 shadow-sm"
                        : "text-gray-600 hover:text-gray-800"
                      }`}
                    >
                      {tab}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Table */}
            <div className="p-4 md:p-8">
              {loading && admissions.length === 0 ? (
                <div className="flex justify-center items-center h-64">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                </div>
              ) : error ? (
                <div className="flex flex-col justify-center items-center h-64 text-red-500 bg-red-50/50">
                  <AlertCircle className="w-8 h-8 mb-2 opacity-50" />
                  <p>{error}</p>
                  <button onClick={fetchAdmissions} className="mt-4 px-4 py-2 bg-white border border-red-200 text-red-600 rounded-lg hover:bg-red-50 text-sm font-medium">Retry</button>
                </div>
              ) : admissions.length === 0 ? (
                <div className="text-center py-20 bg-gray-50/50">
                  <div className="bg-gray-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                    <Bed className="w-8 h-8 text-gray-400" />
                  </div>
                  <p className="text-gray-500 font-medium text-lg">No admissions found</p>
                  <p className="text-gray-400 text-sm mt-1">Try adjusting your filters or search terms.</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse min-w-[640px]">
                    <thead>
                      <tr className="border-b-2 border-gray-200 bg-gray-50">
                        <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Patient</th>
                        <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Ward & Bed</th>
                        <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700 hidden md:table-cell">Admitted At</th>
                        <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700 hidden lg:table-cell">Doctor</th>
                        <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700">Status</th>
                        <th className="py-3 px-4 text-xs md:text-sm font-semibold text-gray-700 text-center">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white">
                      {admissions.map((admission) => (
                        <tr key={admission.id} className="border-b border-gray-100 hover:bg-indigo-50 transition-colors">
                          <td className="py-3 px-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <div className="h-10 w-10 flex-shrink-0 bg-gradient-to-br from-indigo-100 to-blue-100 rounded-full flex items-center justify-center border border-indigo-200">
                                <span className="text-indigo-700 font-bold text-sm">
                                  {admission.patient?.first_name?.[0] || ""}{admission.patient?.last_name?.[0] || ""}
                                </span>
                              </div>
                              <div className="ml-4">
                                <div className="text-sm font-semibold text-gray-900">
                                  {admission.patient?.first_name} {admission.patient?.last_name}
                                </div>
                                <div className="text-xs text-gray-500">{admission.patient?.upid || "N/A"}</div>
                              </div>
                            </div>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">
                            <div className="text-sm text-gray-900 font-medium capitalize">{admission.ward} Ward</div>
                            <div className="text-xs text-gray-500">{admission.bed || "Unassigned"}</div>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap hidden md:table-cell">
                            <div className="text-sm text-gray-900 flex items-center gap-1.5">
                              <Clock className="w-3.5 h-3.5 text-gray-400" />
                              {formatDate(admission.admitted_at)}
                            </div>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap hidden lg:table-cell">
                            <div className="text-sm text-gray-900 flex items-center gap-1.5">
                              <User className="w-3.5 h-3.5 text-gray-400" />
                              {admission.doctor ? `Dr. ${admission.doctor.last_name}` : "Unassigned"}
                            </div>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">
                            {getStatusBadge(admission.status)}
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap text-center">
                            <Link
                              to={`/inpatient/${admission.id}`}
                              className="inline-flex items-center gap-1.5 bg-indigo-600 text-white px-3 md:px-4 py-1.5 md:py-2 rounded-lg hover:bg-indigo-700 transition-all text-xs md:text-sm font-medium shadow-sm"
                            >
                              <Eye className="w-3.5 h-3.5" /> View
                            </Link>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>

            {/* Pagination */}
            {!loading && admissions.length > 0 && (
              <div className="px-4 md:px-8 py-3 md:py-4 bg-gray-50 border-t border-gray-200">
                <div className="flex flex-col sm:flex-row justify-between items-center gap-3">
                  <p className="text-xs md:text-sm text-gray-600">
                    Page <span className="font-semibold text-gray-800">{currentPage}</span> of <span className="font-semibold text-gray-800">{totalPages}</span>
                  </p>
                  {totalPages > 1 && (
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                        disabled={currentPage === 1}
                        className={`px-3 py-2 rounded-lg flex items-center gap-1 text-sm font-medium transition-all ${currentPage === 1
                          ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                          : "bg-white text-gray-700 border border-gray-300 hover:bg-gray-100"
                        }`}
                      >
                        <ChevronLeft className="w-4 h-4" />
                        <span className="hidden sm:inline">Previous</span>
                      </button>
                      <button
                        onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                        disabled={currentPage === totalPages}
                        className={`px-3 py-2 rounded-lg flex items-center gap-1 text-sm font-medium transition-all ${currentPage === totalPages
                          ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                          : "bg-white text-gray-700 border border-gray-300 hover:bg-gray-100"
                        }`}
                      >
                        <span className="hidden sm:inline">Next</span>
                        <ChevronRight className="w-4 h-4" />
                      </button>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
