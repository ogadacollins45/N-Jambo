import React, { useState, useEffect, useMemo } from "react";
import { ChevronDown, ChevronRight, Search, RefreshCw, Printer, User } from "lucide-react";
import { Link } from "react-router-dom";

const MONTHS = [
  { value: 1, label: "January" }, { value: 2, label: "February" },
  { value: 3, label: "March" },   { value: 4, label: "April" },
  { value: 5, label: "May" },     { value: 6, label: "June" },
  { value: 7, label: "July" },    { value: 8, label: "August" },
  { value: 9, label: "September"},{ value: 10, label: "October" },
  { value: 11, label: "November"},{ value: 12, label: "December" },
];

const DiseaseReport = () => {
  const [month, setMonth] = useState(new Date().getMonth() + 1);
  const [year, setYear]   = useState(new Date().getFullYear());
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState(null);
  const [expanded, setExpanded] = useState({}); // { diseaseKey: boolean }
  const [search, setSearch] = useState("");

  const fetchReport = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem("token");
      const res = await fetch(
        `${import.meta.env.VITE_API_BASE_URL}/api/reports/disease-report?month=${month}&year=${year}`,
        { headers: { Authorization: `Bearer ${token}`, Accept: "application/json" } }
      );
      if (res.ok) setData(await res.json());
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReport(); }, [month, year]);

  const toggle = (key) =>
    setExpanded((prev) => ({ ...prev, [key]: !prev[key] }));

  // Disease rows filtered by search
  const diseaseKeys = useMemo(() => {
    if (!data) return [];
    return Object.keys(data.diseases).filter((k) => {
      const label = (data.labels[k] || k).toLowerCase();
      return search === "" || label.includes(search.toLowerCase());
    });
  }, [data, search]);

  const fmt = (d) =>
    d ? new Date(d).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" }) : "—";

  const genderBadge = (g) =>
    g === "M" ? (
      <span className="px-1.5 py-0.5 text-xs bg-blue-100 text-blue-700 rounded font-medium">M</span>
    ) : (
      <span className="px-1.5 py-0.5 text-xs bg-pink-100 text-pink-700 rounded font-medium">F</span>
    );

  const visitBadge = (v) =>
    v === "new" ? (
      <span className="px-2 py-0.5 text-xs bg-green-100 text-green-700 rounded-full font-medium">New</span>
    ) : (
      <span className="px-2 py-0.5 text-xs bg-amber-100 text-amber-700 rounded-full font-medium">Re-Att</span>
    );

  return (
    <div className="space-y-4">
      {/* Controls */}
      <div className="print:hidden flex flex-col md:flex-row gap-3 items-end bg-indigo-50 p-4 rounded-xl border border-indigo-100">
        <div>
          <label className="block text-xs font-medium text-gray-600 mb-1">Month</label>
          <select
            value={month}
            onChange={(e) => setMonth(+e.target.value)}
            className="border-gray-300 rounded-lg shadow-sm bg-white px-3 py-2 text-sm"
          >
            {MONTHS.map((m) => <option key={m.value} value={m.value}>{m.label}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-xs font-medium text-gray-600 mb-1">Year</label>
          <input
            type="number"
            value={year}
            onChange={(e) => setYear(+e.target.value)}
            className="border-gray-300 rounded-lg shadow-sm bg-white px-3 py-2 w-28 text-sm"
          />
        </div>
        <button
          onClick={fetchReport}
          disabled={loading}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
          Generate
        </button>
        <button
          onClick={() => window.print()}
          className="ml-auto bg-gray-800 hover:bg-gray-900 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2"
        >
          <Printer className="w-4 h-4" /> Print
        </button>
      </div>

      {/* Search */}
      <div className="relative print:hidden">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search disease name…"
          className="w-full pl-9 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-300 focus:border-indigo-400 outline-none"
        />
      </div>

      {loading && (
        <div className="flex justify-center py-16">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600" />
        </div>
      )}

      {!loading && data && (
        <>
          {/* Disease Table */}
          <div className="overflow-x-auto rounded-xl border border-gray-200 shadow-sm">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-indigo-600 text-white">
                  <th className="py-3 px-4 text-left font-semibold w-8"></th>
                  <th className="py-3 px-4 text-left font-semibold">Disease / Condition</th>
                  <th className="py-3 px-3 text-center font-semibold">Under 5 ♂</th>
                  <th className="py-3 px-3 text-center font-semibold">Under 5 ♀</th>
                  <th className="py-3 px-3 text-center font-semibold">Over 5 ♂</th>
                  <th className="py-3 px-3 text-center font-semibold">Over 5 ♀</th>
                  <th className="py-3 px-3 text-center font-semibold">New</th>
                  <th className="py-3 px-3 text-center font-semibold">Re-Att</th>
                  <th className="py-3 px-3 text-center font-semibold bg-indigo-700">Total</th>
                </tr>
              </thead>
              <tbody>
                {diseaseKeys.map((key, idx) => {
                  const d = data.diseases[key];
                  const label = data.labels[key] || key;
                  const hasPatients = d.patients.length > 0;
                  const isExpanded = expanded[key];
                  const isHighlighted = d.total > 0;

                  return (
                    <React.Fragment key={key}>
                      <tr
                        className={`border-b border-gray-100 transition-colors ${
                          hasPatients ? "cursor-pointer" : ""
                        } ${isHighlighted ? "bg-white hover:bg-indigo-50" : "bg-gray-50/50 text-gray-400"}`}
                        onClick={() => hasPatients && toggle(key)}
                      >
                        <td className="py-2 px-4 text-gray-400">
                          {hasPatients ? (
                            isExpanded
                              ? <ChevronDown className="w-4 h-4 text-indigo-500" />
                              : <ChevronRight className="w-4 h-4 text-indigo-400" />
                          ) : null}
                        </td>
                        <td className={`py-2 px-4 font-medium ${isHighlighted ? "text-gray-800" : ""}`}>
                          <span className="mr-2 text-xs text-gray-400">{idx + 1}.</span>
                          {label}
                        </td>
                        <td className="py-2 px-3 text-center">{d.under5_m || "—"}</td>
                        <td className="py-2 px-3 text-center">{d.under5_f || "—"}</td>
                        <td className="py-2 px-3 text-center">{d.over5_m || "—"}</td>
                        <td className="py-2 px-3 text-center">{d.over5_f || "—"}</td>
                        <td className="py-2 px-3 text-center text-green-700 font-medium">{d.new || "—"}</td>
                        <td className="py-2 px-3 text-center text-amber-700 font-medium">{d.reatt || "—"}</td>
                        <td className={`py-2 px-3 text-center font-bold ${isHighlighted ? "text-indigo-700" : ""}`}>
                          {d.total || 0}
                        </td>
                      </tr>

                      {/* Expanded patient list */}
                      {isExpanded && hasPatients && (
                        <tr key={`${key}_expand`}>
                          <td colSpan={9} className="bg-indigo-50 px-6 py-3 border-b border-indigo-100">
                            <div className="text-xs font-semibold text-indigo-700 mb-2 flex items-center gap-2">
                              <User className="w-3.5 h-3.5" />
                              {d.patients.length} patient{d.patients.length !== 1 ? "s" : ""} — {label}
                            </div>
                            <table className="w-full text-xs bg-white rounded-lg overflow-hidden shadow-sm">
                              <thead>
                                <tr className="bg-gray-100 text-gray-600">
                                  <th className="px-3 py-2 text-left">UPID</th>
                                  <th className="px-3 py-2 text-left">Name</th>
                                  <th className="px-3 py-2 text-center">Age</th>
                                  <th className="px-3 py-2 text-center">Sex</th>
                                  <th className="px-3 py-2 text-left">Diagnosis</th>
                                  <th className="px-3 py-2 text-left">Category</th>
                                  <th className="px-3 py-2 text-left">Subcategory</th>
                                  <th className="px-3 py-2 text-center">Visit Date</th>
                                  <th className="px-3 py-2 text-center">Type</th>
                                  <th className="px-3 py-2 text-center print:hidden">View</th>
                                </tr>
                              </thead>
                              <tbody>
                                {d.patients.map((p, pi) => (
                                  <tr key={pi} className="border-t border-gray-100 hover:bg-blue-50 transition-colors">
                                    <td className="px-3 py-2 font-mono text-blue-600">{p.upid}</td>
                                    <td className="px-3 py-2 font-medium text-gray-800">{p.name}</td>
                                    <td className="px-3 py-2 text-center">{p.age}</td>
                                    <td className="px-3 py-2 text-center">{genderBadge(p.gender)}</td>
                                    <td className="px-3 py-2 text-gray-700 max-w-[200px] truncate" title={p.diagnosis}>
                                      {p.diagnosis}
                                    </td>
                                    <td className="px-3 py-2">
                                      {p.category && (
                                        <span className="px-1.5 py-0.5 bg-purple-100 text-purple-700 rounded text-xs">
                                          {p.category}
                                        </span>
                                      )}
                                    </td>
                                    <td className="px-3 py-2">
                                      {p.subcategory && (
                                        <span className="px-1.5 py-0.5 bg-gray-100 text-gray-600 rounded text-xs">
                                          {p.subcategory}
                                        </span>
                                      )}
                                    </td>
                                    <td className="px-3 py-2 text-center text-gray-500">{fmt(p.visit_date)}</td>
                                    <td className="px-3 py-2 text-center">{visitBadge(p.visit_type)}</td>
                                    <td className="px-3 py-2 text-center print:hidden">
                                      <Link
                                        to={`/patients/${p.patient_id}`}
                                        className="text-indigo-600 hover:underline font-medium"
                                        onClick={(e) => e.stopPropagation()}
                                      >
                                        View
                                      </Link>
                                    </td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          </td>
                        </tr>
                      )}
                    </React.Fragment>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* Summary Section */}
          <div className="mt-4 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
            {[
              { label: "No. of First Attendances", value: data.summary.new_attendances, color: "green" },
              { label: "Re-Attendances", value: data.summary.reattendances, color: "amber" },
              { label: "Referrals FROM Facility", value: data.summary.referrals_from_facility, color: "blue" },
              { label: "Referrals TO Facility", value: data.summary.referrals_to_facility, color: "indigo" },
              { label: "Referrals From Community", value: data.summary.referrals_from_community, color: "purple" },
              { label: "Referrals To Community", value: data.summary.referrals_to_community, color: "rose" },
            ].map((s) => (
              <div key={s.label} className={`bg-${s.color}-50 border border-${s.color}-100 rounded-xl p-3 text-center`}>
                <div className={`text-2xl font-black text-${s.color}-700`}>{s.value}</div>
                <div className="text-xs text-gray-500 mt-1 leading-tight">{s.label}</div>
              </div>
            ))}
          </div>
        </>
      )}

      {!loading && !data && (
        <div className="text-center text-gray-400 py-12">No data. Click Generate to load the report.</div>
      )}
    </div>
  );
};

export default DiseaseReport;
