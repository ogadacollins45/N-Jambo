import React, { useState, useEffect, useCallback } from "react";
import { RefreshCw, Printer, FlaskConical, Info, ChevronDown, ChevronRight, User } from "lucide-react";
import { Link } from "react-router-dom";

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const MONTHS = [
  { value: 1, label: "January" }, { value: 2, label: "February" },
  { value: 3, label: "March" }, { value: 4, label: "April" },
  { value: 5, label: "May" }, { value: 6, label: "June" },
  { value: 7, label: "July" }, { value: 8, label: "August" },
  { value: 9, label: "September" }, { value: 10, label: "October" },
  { value: 11, label: "November" }, { value: 12, label: "December" },
];

/** Human-readable column header labels */
const COLUMN_LABELS = {
  total_exam: "Total Exam",
  number_positive: "No. Positive",
  low: "Low",
  high: "High",
  number_of_specimens: "No. of Specimens",
  number_of_results_received: "No. of Results Received",
  hb_lt_5_g_dl: "HB <5 g/dl",
  hb_5_to_10_g_dl: "HB 5–10 g/dl",
  pre_diabetes: "Pre-Diabetes",
  diabetes: "Diabetes",
  number_lt_500: "Number <500",
  number: "Number",
  total_cultures: "Total Cultures",
  culture_positive: "No. Culture +ve",
  malignant: "Malignant",
  tnm_stage: "TNM Stage",
  number_contaminated: "Contaminated",
};

/** Phase 1 section tabs (1, 7, 8) */
const SECTION_TABS = [
  { id: "1", emoji: "🧪", label: "S1 — Urine Analysis" },
  { id: "2", emoji: "🩸", label: "S2 — Blood Chemistry" },
  { id: "3", emoji: "🦟", label: "S3 — Parasitology" },
  { id: "4", emoji: "💉", label: "S4 — Haematology" },
  { id: "5", emoji: "🧫", label: "S5 — Bacteriology" },
  { id: "6", emoji: "🔬", label: "S6 — Histology" },
  { id: "7", emoji: "🩺", label: "S7 — Serology" },
  { id: "8", emoji: "📤", label: "S8 — Referrals" },
  { id: "9", emoji: "💊", label: "S9 — Susceptibility" },
];

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Returns Tailwind text colour classes for a data cell value.
 * Zero / empty values get a muted style; non-zero gets an accent colour.
 */
function cellColor(colName, value) {
  if (!value || value === 0) return "text-gray-400";
  switch (colName) {
    case "total_exam":
    case "total_cultures":
    case "number_of_specimens": return "text-blue-700 font-semibold";
    case "number_positive":
    case "culture_positive":
    case "high": return "text-amber-700 font-bold";
    case "number_contaminated": return "text-orange-700 font-bold";
    case "number_of_results_received": return "text-indigo-700 font-semibold";
    case "low": return "text-sky-700 font-bold";
    case "malignant": return "text-rose-700 font-bold";
    default: return "text-gray-700 font-semibold";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components
// ─────────────────────────────────────────────────────────────────────────────

/** Summary pill shown at the top of an active section */
const SectionSummaryBar = ({ subsections }) => {
  let totalTests = 0;
  let totalPositive = 0;
  let totalSpecimens = 0;
  let totalReceived = 0;

  subsections.forEach((sub) => {
    sub.rows.forEach((row) => {
      totalTests += row.total_exam ?? 0;
      totalPositive += row.number_positive ?? 0;
      totalSpecimens += row.number_of_specimens ?? 0;
      totalReceived += row.number_of_results_received ?? 0;
    });
  });

  const pills = [];
  if (totalTests > 0 || totalPositive > 0) {
    pills.push({ label: "Total Exams", value: totalTests, color: "blue" });
    pills.push({ label: "Positive", value: totalPositive, color: "amber" });
  }
  if (totalSpecimens > 0 || totalReceived > 0) {
    pills.push({ label: "Specimens Sent", value: totalSpecimens, color: "blue" });
    pills.push({ label: "Results Received", value: totalReceived, color: "indigo" });
  }
  if (pills.length === 0) return null;

  return (
    <div className="flex flex-wrap gap-3 mb-5 print:hidden">
      {pills.map(({ label, value, color }) => (
        <div
          key={label}
          className={`flex flex-col items-center justify-center px-5 py-3 rounded-xl border bg-${color}-50 border-${color}-100 min-w-[100px]`}
        >
          <span className={`text-2xl font-black text-${color}-600`}>{value}</span>
          <span className="text-xs text-gray-500 mt-0.5 text-center leading-tight">{label}</span>
        </div>
      ))}
    </div>
  );
};

const PatientTable = ({ patients, label }) => {
  const fmt = (d) => d ? new Date(d).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" }) : "—";
  const genderBadge = (g) => g === "M" ? (
    <span className="px-1.5 py-0.5 text-xs bg-blue-100 text-blue-700 rounded font-medium">M</span>
  ) : (
    <span className="px-1.5 py-0.5 text-xs bg-pink-100 text-pink-700 rounded font-medium">F</span>
  );

  return (
    <tr className="print:hidden">
      <td colSpan={100} className="bg-blue-50/50 px-6 py-3 border-b border-blue-100">
        <div className="text-xs font-semibold text-blue-700 mb-2 flex items-center gap-2">
          <User className="w-3.5 h-3.5" />
          {patients.length} patient{patients.length !== 1 ? "s" : ""} — {label}
        </div>
        <table className="w-full text-xs bg-white rounded-lg overflow-hidden shadow-sm">
          <thead>
            <tr className="bg-gray-100 text-gray-600">
              <th className="px-3 py-2 text-left">UPID</th>
              <th className="px-3 py-2 text-left">Name</th>
              <th className="px-3 py-2 text-center">Age</th>
              <th className="px-3 py-2 text-center">Sex</th>
              <th className="px-3 py-2 text-left">Primary Diagnosis</th>
              <th className="px-3 py-2 text-center">Visit Date</th>
              <th className="px-3 py-2 text-center">View</th>
            </tr>
          </thead>
          <tbody>
            {patients.map((p, pi) => (
              <tr key={pi} className="border-t border-gray-100 hover:bg-blue-50 transition-colors">
                <td className="px-3 py-2 font-mono text-blue-600">{p.upid}</td>
                <td className="px-3 py-2 font-medium text-gray-800">{p.name}</td>
                <td className="px-3 py-2 text-center">{p.age}</td>
                <td className="px-3 py-2 text-center">{genderBadge(p.gender)}</td>
                <td className="px-3 py-2 text-gray-700 max-w-[200px] truncate" title={p.diagnosis}>
                  {p.diagnosis || "—"}
                </td>
                <td className="px-3 py-2 text-center text-gray-500">{fmt(p.visit_date)}</td>
                <td className="px-3 py-2 text-center">
                  <Link to={`/patients/${p.patient_id}`} className="text-blue-600 hover:underline font-medium">View</Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </td>
    </tr>
  );
};

/** Generic subsection table — columns and rows are driven by the API response */
const SubsectionTable = ({ subsection, expanded, toggle }) => {
  // Compute column totals
  const totals = {};
  subsection.columns.forEach((col) => { totals[col] = 0; });
  subsection.rows.forEach((row) => {
    subsection.columns.forEach((col) => {
      totals[col] = (totals[col] ?? 0) + (row[col] ?? 0);
    });
  });

  const sectionHasData = subsection.rows.some((row) =>
    subsection.columns.some((col) => (row[col] ?? 0) > 0)
  );

  // Unique patient count for footer (de-dup across rows by patient_id)
  const subsectionPatientIds = new Set(
    subsection.rows.flatMap((row) => (row.patients || []).map((p) => p.patient_id))
  );
  const totalPatients = subsectionPatientIds.size;

  return (
    <div className="mb-5 border border-gray-200 rounded-2xl overflow-hidden shadow-sm print:border-black print:rounded-none print:mb-4">
      {/* Subsection header bar */}
      <div className="flex items-center gap-3 px-5 py-3 bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-blue-100 print:bg-gray-100 print:border-black">
        <span className="text-xs font-mono font-bold text-blue-500 bg-blue-100 px-2 py-0.5 rounded print:bg-gray-200 print:text-black">
          {subsection.code}
        </span>
        <h3 className="font-bold text-blue-800 text-sm print:text-black">
          {subsection.title}
        </h3>
        {!sectionHasData && (
          <span className="ml-auto text-xs text-gray-400 italic flex items-center gap-1 print:hidden">
            <Info className="w-3 h-3" /> No data this period
          </span>
        )}
        {sectionHasData && totalPatients > 0 && (
          <span className="ml-auto text-xs text-blue-500 font-semibold flex items-center gap-1 print:hidden">
            <User className="w-3 h-3" /> {totalPatients} patient{totalPatients !== 1 ? "s" : ""}
          </span>
        )}
      </div>

      {/* Data table */}
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-gray-50 border-b border-gray-200 print:border-black">
              <th className="py-2.5 px-3 w-8 print:hidden" />
              <th className="py-2.5 px-3 text-left text-xs font-semibold text-gray-400 w-16 print:text-black">
                Code
              </th>
              <th className="py-2.5 px-4 text-left text-xs font-semibold text-gray-500 print:text-black">
                Test Name
              </th>
              {subsection.columns.map((col) => (
                <th
                  key={col}
                  className="py-2.5 px-4 text-center text-xs font-semibold text-gray-500 w-32 print:text-black"
                >
                  {COLUMN_LABELS[col] ?? col}
                </th>
              ))}
              {/* Patients column — always shown, drives expand */}
              <th className="py-2.5 px-4 text-center text-xs font-semibold text-blue-500 w-28 print:text-black">
                Patients
              </th>
            </tr>
          </thead>

          <tbody>
            {subsection.rows.map((row, idx) => {
              const hasData = subsection.columns.some((col) => (row[col] ?? 0) > 0);
              const patients = row.patients || [];
              const hasPatients = patients.length > 0;
              const isExpanded = expanded[`${subsection.code}_${row.code}`];

              return (
                <React.Fragment key={row.code}>
                  <tr
                    className={`border-b border-gray-100 transition-colors ${idx % 2 === 0 ? "" : "bg-gray-50/40"
                      } ${hasData ? "hover:bg-blue-50/20" : "text-gray-400"} ${hasPatients ? "cursor-pointer" : ""}`}
                    onClick={() => hasPatients && toggle(subsection.code, row.code)}
                  >
                    <td className="py-2.5 px-3 text-center print:hidden">
                      {hasPatients ? (isExpanded ? <ChevronDown className="w-4 h-4 text-blue-500" /> : <ChevronRight className="w-4 h-4 text-blue-400" />) : null}
                    </td>
                    <td className="py-2.5 px-3 font-mono text-xs text-gray-400">
                      {row.code}
                    </td>
                    <td className={`py-2.5 px-4 font-medium ${hasData ? "text-gray-800" : "text-gray-400"}`}>
                      {row.label}
                    </td>
                    {subsection.columns.map((col) => {
                      const val = row[col] ?? 0;
                      return (
                        <td
                          key={col}
                          className={`py-2.5 px-4 text-center tabular-nums ${cellColor(col, val)}`}
                        >
                          {val > 0 ? val : <span className="text-gray-300">—</span>}
                        </td>
                      );
                    })}
                    {/* Patients count cell */}
                    <td className="py-2.5 px-4 text-center print:text-black">
                      {hasPatients ? (
                        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold
                          ${isExpanded
                            ? "bg-blue-600 text-white"
                            : "bg-blue-100 text-blue-700 hover:bg-blue-200"
                          } transition-colors`}>
                          <User className="w-3 h-3" />
                          {patients.length}
                        </span>
                      ) : (
                        <span className="text-gray-300">—</span>
                      )}
                    </td>
                  </tr>
                  {isExpanded && hasPatients && <PatientTable patients={patients} label={row.label} />}
                </React.Fragment>
              );
            })}
          </tbody>

          {/* Totals footer */}
          <tfoot>
            <tr className="bg-blue-600 text-white font-bold print:bg-gray-200 print:text-black">
              <td className="px-3 py-2.5 print:hidden" />
              <td className="px-3 py-2.5 text-xs" />
              <td className="px-4 py-2.5 text-xs text-right uppercase tracking-wider font-black">
                Subsection Total
              </td>
              {subsection.columns.map((col) => (
                <td key={col} className="px-4 py-2.5 text-center tabular-nums">
                  {totals[col]}
                </td>
              ))}
              {/* Patients total — unique across subsection */}
              <td className="px-4 py-2.5 text-center tabular-nums">
                {totalPatients > 0 ? (
                  <span className="inline-flex items-center gap-1">
                    <User className="w-3 h-3 opacity-80" />
                    {totalPatients}
                  </span>
                ) : <span className="opacity-40">0</span>}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
};

/** Matrix generic rendering for Section 9 */
const MatrixSubsectionTable = ({ subsection, expanded, toggle }) => {
  const columns = subsection.matrix_columns || [];

  return (
    <div className="mb-5 border border-gray-200 rounded-2xl overflow-hidden shadow-sm print:border-black print:rounded-none">
      {/* Subsection header bar — matches SubsectionTable */}
      <div className="flex items-center gap-3 px-5 py-3 bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-blue-100 print:bg-gray-100 print:border-black">
        <span className="text-xs font-mono font-bold text-blue-500 bg-blue-100 px-2 py-0.5 rounded print:bg-gray-200 print:text-black">
          {subsection.code}
        </span>
        <h3 className="font-bold text-blue-800 text-sm print:text-black">{subsection.title}</h3>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-gray-50 border-b border-gray-200 print:border-black">
              <th className="py-2.5 px-3 w-8 sticky left-0 z-10 bg-gray-50 print:hidden" />
              <th className="py-2.5 px-3 text-left text-xs font-semibold text-gray-400 w-12 sticky left-8 z-10 bg-gray-50 print:bg-transparent print:text-black">Code</th>
              <th className="py-2.5 px-4 text-left text-xs font-semibold text-gray-500 w-48 sticky left-20 z-10 bg-gray-50 print:bg-transparent print:text-black">Organism</th>
              {columns.map((col) => (
                <th key={col.name} className="py-2 px-1 font-semibold text-gray-500 text-center w-12 align-bottom print:text-black">
                  <div className="text-[10px] transform -rotate-45 origin-bottom-left w-6 translate-x-3 translate-y-3 whitespace-nowrap">
                    {col.label}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {subsection.rows.map((row, idx) => {
              const hasData = columns.some((col) => (row[col.name] ?? 0) > 0);
              const patients = row.patients || [];
              const hasPatients = patients.length > 0;
              const isExpanded = expanded[`${subsection.code}_${row.code}`];

              return (
                <React.Fragment key={row.code}>
                  <tr
                    className={`border-b border-gray-100 transition-colors ${idx % 2 === 0 ? "" : "bg-gray-50/40"} ${hasData ? "hover:bg-blue-50/20 text-gray-800 font-medium" : "text-gray-400"
                      } ${hasPatients ? "cursor-pointer" : ""}`}
                    onClick={() => hasPatients && toggle(subsection.code, row.code)}
                  >
                    <td className="py-2.5 px-3 sticky left-0 z-10 bg-inherit print:hidden">
                      {hasPatients ? (isExpanded ? <ChevronDown className="w-4 h-4 text-blue-500" /> : <ChevronRight className="w-4 h-4 text-blue-400" />) : null}
                    </td>
                    <td className="py-2.5 px-3 font-mono text-xs text-gray-400 sticky left-8 z-10 bg-inherit border-r border-gray-100 print:border-black">
                      {row.code}
                    </td>
                    <td className="py-2.5 px-4 sticky left-20 z-10 bg-inherit border-r border-gray-200 print:border-black text-sm">
                      {row.label}
                    </td>
                    {columns.map((col) => {
                      const val = row[col.name] ?? 0;
                      return (
                        <td
                          key={col.name}
                          className={`py-2.5 px-1 text-center tabular-nums border-r border-gray-100 print:border-black ${val > 0 ? "font-bold text-amber-700 bg-amber-50/30" : ""
                            }`}
                        >
                          {val > 0 ? val : <span className="text-gray-300">—</span>}
                        </td>
                      );
                    })}
                  </tr>
                  {isExpanded && hasPatients && <PatientTable patients={patients} label={row.label} />}
                </React.Fragment>
              );
            })}
          </tbody>
          {/* Totals footer — matches SubsectionTable style */}
          <tfoot>
            <tr className="bg-blue-600 text-white font-bold print:bg-gray-200 print:text-black">
              <td className="px-3 py-2.5 sticky left-0 z-10 bg-blue-600 print:bg-transparent print:hidden" />
              <td className="px-3 py-2.5 text-xs sticky left-8 z-10 bg-blue-600 print:bg-transparent" />
              <td className="px-4 py-2.5 text-xs text-right uppercase tracking-wider font-black sticky left-20 z-10 bg-blue-600 print:bg-transparent">
                Section Total
              </td>
              {columns.map((col) => {
                const total = subsection.rows.reduce((sum, row) => sum + (row[col.name] ?? 0), 0);
                return (
                  <td key={col.name} className="px-1 py-2.5 text-center tabular-nums text-xs">
                    {total > 0 ? total : <span className="opacity-40">—</span>}
                  </td>
                );
              })}
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// Main Component
// ─────────────────────────────────────────────────────────────────────────────
const MOH706 = () => {
  const [month, setMonth] = useState(new Date().getMonth() + 1);
  const [year, setYear] = useState(new Date().getFullYear());
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState(null);
  const [activeSection, setActiveSection] = useState("1");
  const [fetchedPeriod, setFetchedPeriod] = useState(null);
  const [error, setError] = useState(null);
  const [expanded, setExpanded] = useState({});

  const toggle = useCallback((sectionCode, rowCode) => {
    const key = `${sectionCode}_${rowCode}`;
    setExpanded((prev) => ({ ...prev, [key]: !prev[key] }));
  }, []);

  const [facilityInfo] = useState({
    county: "Bungoma",
    subCounty: "Bungoma North",
    facility: "Naitiri Jambo Medical Centre",
    kmhfl: "30952",
  });

  // ── Fetch ─────────────────────────────────────────────────────────────────
  const fetchReport = useCallback(async () => {
    setLoading(true);
    setError(null);
    setExpanded({});
    const fm = month;
    const fy = year;
    try {
      const token = localStorage.getItem("token");
      const res = await fetch(
        `${import.meta.env.VITE_API_BASE_URL}/api/reports/moh-706?month=${fm}&year=${fy}&_t=${Date.now()}`,
        { headers: { Authorization: `Bearer ${token}`, Accept: "application/json" } }
      );
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = await res.json();
      setReportData(json);
      setFetchedPeriod({ month: fm, year: fy });
    } catch (err) {
      console.error(err);
      setError("Failed to load report. Please try again.");
    } finally {
      setLoading(false);
    }
  }, [month, year]);

  useEffect(() => { fetchReport(); }, [month, year]);

  // ── Derived data ──────────────────────────────────────────────────────────
  const currentSection = reportData?.sections?.[activeSection];

  const monthLabel = (m) =>
    MONTHS.find((mo) => mo.value === m)?.label ?? String(m);

  // ── Render ────────────────────────────────────────────────────────────────
  return (
    <div className="space-y-5">

      {/* ── Controls ────────────────────────────────────────────────────── */}
      <div className="print:hidden flex flex-col md:flex-row gap-4 items-end
                      bg-gradient-to-r from-blue-50 to-indigo-50
                      p-4 rounded-2xl border border-blue-100 shadow-sm">
        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Month</label>
          <select
            value={month}
            onChange={(e) => setMonth(+e.target.value)}
            className="border border-gray-300 rounded-xl shadow-sm bg-white px-3 py-2
                       text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none"
          >
            {MONTHS.map((m) => (
              <option key={m.value} value={m.value}>{m.label}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Year</label>
          <input
            type="number"
            value={year}
            onChange={(e) => setYear(+e.target.value)}
            className="border border-gray-300 rounded-xl shadow-sm bg-white px-3 py-2
                       w-28 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none"
          />
        </div>

        <button
          onClick={fetchReport}
          disabled={loading}
          className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2
                     rounded-xl text-sm font-semibold flex items-center gap-2
                     disabled:opacity-50 transition-all shadow-sm"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
          Generate
        </button>

        <button
          onClick={() => window.print()}
          className="ml-auto bg-gray-800 hover:bg-gray-900 text-white px-5 py-2
                     rounded-xl text-sm font-semibold flex items-center gap-2
                     transition-all shadow-sm"
        >
          <Printer className="w-4 h-4" />
          Print Report
        </button>
      </div>

      {/* ── Loading ──────────────────────────────────────────────────────── */}
      {loading && (
        <div className="flex flex-col items-center justify-center py-20 gap-4">
          <div className="relative">
            <div className="w-14 h-14 rounded-full border-4 border-blue-100" />
            <div className="absolute inset-0 w-14 h-14 rounded-full border-4 border-blue-500 border-t-transparent animate-spin" />
          </div>
          <p className="text-sm font-medium text-blue-600">
            Processing lab records…
          </p>
          <p className="text-xs text-gray-400">
            Test mapping may take a moment on first run.
          </p>
        </div>
      )}

      {/* ── Error ───────────────────────────────────────────────────────── */}
      {!loading && error && (
        <div className="rounded-2xl bg-rose-50 border border-rose-200 p-5 flex items-center gap-4">
          <span className="text-2xl">⚠️</span>
          <div>
            <p className="font-semibold text-rose-700">{error}</p>
            <button onClick={fetchReport} className="text-sm text-rose-600 underline mt-1">
              Retry
            </button>
          </div>
        </div>
      )}

      {/* ── Empty state ──────────────────────────────────────────────────── */}
      {!loading && !error && !reportData && (
        <div className="flex flex-col items-center py-20 gap-4 text-gray-400">
          <FlaskConical className="w-14 h-14 text-blue-100" />
          <p className="font-medium text-gray-500">
            Click <span className="text-blue-600 font-bold">Generate</span> to load the MOH 706 report.
          </p>
        </div>
      )}

      {/* ── Report Card ──────────────────────────────────────────────────── */}
      {!loading && !error && reportData && (
        <div className="bg-white border border-gray-100 rounded-2xl shadow-md
                        overflow-hidden print:border-none print:shadow-none">

          {/* ── Report Header ─────────────────────────────────────────── */}
          <div className="relative overflow-hidden">
            {/* gradient banner */}
            <div className="bg-gradient-to-r from-blue-600 via-blue-500 to-indigo-500 px-8 py-7 print:bg-white">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-white/20 rounded-xl backdrop-blur-sm print:hidden">
                  <FlaskConical className="w-7 h-7 text-white" />
                </div>
                <div>
                  <p className="text-blue-100 text-xs font-semibold uppercase tracking-widest print:text-gray-500 print:text-sm">
                    Republic of Kenya — Ministry of Health
                  </p>
                  <h1 className="text-white text-2xl font-black leading-tight print:text-black print:text-xl">
                    Laboratory Monthly Report
                  </h1>
                  <p className="text-4xl font-black text-white/90 leading-none mt-0.5 print:text-black print:text-3xl">
                    MOH 706
                  </p>
                </div>
                {fetchedPeriod && (
                  <div className="ml-auto text-right print:hidden">
                    <p className="text-blue-100 text-xs">Reporting Period</p>
                    <p className="text-white text-lg font-black">
                      {monthLabel(fetchedPeriod.month)} {fetchedPeriod.year}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* ── Facility Info ──────────────────────────────────────────── */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 px-6 py-4
                          border-b border-gray-100 bg-gray-50/60
                          print:bg-transparent print:border-black print:border-2 print:p-4">
            {[
              ["County", facilityInfo.county],
              ["Sub-County", facilityInfo.subCounty],
              ["Facility", facilityInfo.facility],
              ["Month / Year", `${monthLabel(month)} ${year}`],
              ["KMHFL Code", facilityInfo.kmhfl],
            ].map(([label, value]) => (
              <div key={label} className="flex flex-col">
                <span className="text-blue-500 text-[10px] font-semibold uppercase tracking-wider print:text-gray-500">
                  {label}
                </span>
                <span className="font-semibold text-gray-800 text-sm print:text-black">
                  {value}
                </span>
              </div>
            ))}
          </div>

          {/* ── Section Tab Nav ────────────────────────────────────────── */}
          <div className="print:hidden flex overflow-x-auto border-b border-gray-200 bg-gray-50">
            {SECTION_TABS.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveSection(tab.id)}
                className={`flex items-center gap-2 px-6 py-3.5 text-sm font-semibold
                            whitespace-nowrap transition-all duration-200 outline-none border-b-2 ${activeSection === tab.id
                    ? "text-blue-700 border-blue-500 bg-blue-50"
                    : "text-gray-500 border-transparent hover:bg-gray-100 hover:text-gray-700"
                  }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* ── Section Content ────────────────────────────────────────── */}
          <div className="p-6 print:p-4">

            {/* SCREEN: active section only */}
            {currentSection && (
              <div key={activeSection} className="animate-in fade-in duration-300">
                {/* Section heading */}
                <div className="flex items-center gap-3 mb-5 print:mb-3">
                  <div className="w-1 h-10 bg-gradient-to-b from-blue-400 to-indigo-400 rounded-full print:hidden" />
                  <div>
                    <p className="text-[10px] font-bold text-blue-500 uppercase tracking-widest print:text-gray-500">
                      Section {activeSection}
                    </p>
                    <h2 className="text-lg font-black text-gray-800 print:text-black">
                      {currentSection.title}
                    </h2>
                  </div>
                </div>

                {/* Summary pills */}
                <SectionSummaryBar subsections={currentSection.subsections} />

                {/* Subsection tables */}
                {currentSection.subsections.map((sub) => (
                  currentSection.type === 'matrix_table'
                    ? <MatrixSubsectionTable key={sub.code} subsection={sub} expanded={expanded} toggle={toggle} />
                    : <SubsectionTable key={sub.code} subsection={sub} expanded={expanded} toggle={toggle} />
                ))}
              </div>
            )}

            {/* PRINT: all sections stacked */}
            <div className="hidden print:block space-y-10">
              {Object.entries(reportData.sections).map(([secNum, section]) => (
                <div key={secNum} className="page-break-inside-avoid">
                  <h2 className="text-base font-black text-black mb-4 uppercase border-b border-black pb-1">
                    Section {secNum}: {section.title}
                  </h2>
                  {section.subsections.map((sub) =>
                    section.type === 'matrix_table' ? (
                      <MatrixSubsectionTable key={sub.code} subsection={sub} expanded={expanded} toggle={toggle} />
                    ) : (
                      <SubsectionTable key={sub.code} subsection={sub} expanded={expanded} toggle={toggle} />
                    )
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* ── Footer ────────────────────────────────────────────────── */}
          <div className="px-6 py-3 border-t border-gray-100 bg-gray-50/50
                          flex items-center justify-between text-xs text-gray-400
                          print:hidden">
            <span className="flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse" />
              MOH 706 — AI-assisted lab test mapping
            </span>
            {reportData?.generated_at && (
              <span>
                Generated: {new Date(reportData.generated_at).toLocaleString()}
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default MOH706;
