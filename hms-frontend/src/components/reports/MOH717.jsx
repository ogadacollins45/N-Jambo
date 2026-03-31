import React, { useState, useEffect } from "react";
import { ChevronDown, ChevronRight, RefreshCw, Printer, User } from "lucide-react";
import { Link } from "react-router-dom";

const MOH717 = () => {
  const [month, setMonth] = useState(new Date().getMonth() + 1);
  const [year, setYear] = useState(new Date().getFullYear());
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState(null);
  const [expanded, setExpanded] = useState({});
  const [fetchedPeriod, setFetchedPeriod] = useState(null); // { month, year } of the loaded report

  const [facilityInfo] = useState({
    county: "Bungoma",
    subCounty: "Tongaren",
    facility: "Naitiri Jambo Health Medical Services",
    kmhfl: "XXXXXX",
  });

  const months = [
    { value: 1, label: "January" }, { value: 2, label: "February" },
    { value: 3, label: "March" },   { value: 4, label: "April" },
    { value: 5, label: "May" },     { value: 6, label: "June" },
    { value: 7, label: "July" },    { value: 8, label: "August" },
    { value: 9, label: "September"},{ value: 10, label: "October" },
    { value: 11, label: "November"},{ value: 12, label: "December" },
  ];

  const fetchReport = async () => {
    setLoading(true);
    setExpanded({});
    const fetchingMonth = month;
    const fetchingYear = year;
    try {
      const token = localStorage.getItem("token");
      const res = await fetch(
        `${import.meta.env.VITE_API_BASE_URL}/api/reports/moh-717?month=${fetchingMonth}&year=${fetchingYear}`,
        { headers: { Authorization: `Bearer ${token}`, Accept: "application/json" } }
      );
      if (res.ok) {
        setReportData(await res.json());
        setFetchedPeriod({ month: fetchingMonth, year: fetchingYear });
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReport(); }, [month, year]);

  const handlePrint = () => window.print();

  const toggle = (sectionKey, rowKey) => {
    const key = `${sectionKey}_${rowKey}`;
    setExpanded((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  // Badges for patient rows
  const fmt = (d) => d ? new Date(d).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" }) : "—";
  const genderBadge = (g) => g === "M" ? (
    <span className="px-1.5 py-0.5 text-xs bg-blue-100 text-blue-700 rounded font-medium">M</span>
  ) : (
    <span className="px-1.5 py-0.5 text-xs bg-pink-100 text-pink-700 rounded font-medium">F</span>
  );
  const visitBadge = (v) => v === "new" ? (
    <span className="px-2 py-0.5 text-xs bg-green-100 text-green-700 rounded-full font-medium">New</span>
  ) : (
    <span className="px-2 py-0.5 text-xs bg-amber-100 text-amber-700 rounded-full font-medium">Re-Att</span>
  );

  // Helper to render expanded patient tables
  const renderPatientTable = (patients, label) => (
    <tr className="print:hidden">
      <td colSpan={7} className="bg-indigo-50 px-6 py-3 border-b border-indigo-100">
        <div className="text-xs font-semibold text-indigo-700 mb-2 flex items-center gap-2">
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
              <th className="px-3 py-2 text-center">Type</th>
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
                <td className="px-3 py-2 text-center">{visitBadge(p.visit_type)}</td>
                <td className="px-3 py-2 text-center">
                  <Link to={`/patients/${p.patient_id}`} className="text-indigo-600 hover:underline font-medium">View</Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </td>
    </tr>
  );

  // Standard interactive row generator
  const renderInteractiveRows = (sectionKey, rowConfigs) => {
    let totalNew = 0, totalReatt = 0, totalTotal = 0;
    const dataSection = reportData?.[sectionKey] || {};

    const rows = rowConfigs.map((row) => {
      const rowData = dataSection[row.key] || { new: 0, reatt: 0, total: 0, patients: [] };
      const patients = rowData.patients || [];
      const hasPatients = patients.length > 0;
      const isExpanded = expanded[`${sectionKey}_${row.key}`];
      const isHighlighted = rowData.total > 0;

      totalNew += rowData.new || 0;
      totalReatt += rowData.reatt || 0;
      totalTotal += rowData.total || 0;

      return (
        <React.Fragment key={row.key}>
          <tr 
            className={`border-b border-gray-100 transition-colors ${hasPatients ? "cursor-pointer" : ""} ${isHighlighted ? "bg-white hover:bg-indigo-50" : "bg-gray-50 text-gray-400 print:text-black"}`}
            onClick={() => hasPatients && toggle(sectionKey, row.key)}
          >
            <td className="py-2 px-3 w-8 text-center text-gray-400 print:hidden">
              {hasPatients ? (isExpanded ? <ChevronDown className="w-4 h-4 text-indigo-500" /> : <ChevronRight className="w-4 h-4 text-indigo-400" />) : null}
            </td>
            <td className={`py-2 px-4 text-sm font-medium ${isHighlighted ? "text-gray-800" : ""}`}>{row.label}</td>
            <td className="py-2 px-4 text-sm text-center font-medium text-green-700 print:text-black">{rowData.new || "—"}</td>
            <td className="py-2 px-4 text-sm text-center font-medium text-amber-700 print:text-black">{rowData.reatt || "—"}</td>
            <td className={`py-2 px-4 text-sm text-center font-bold ${isHighlighted ? "text-indigo-700" : ""} print:text-black`}>{rowData.total || 0}</td>
          </tr>
          {isExpanded && hasPatients && renderPatientTable(patients, row.label)}
        </React.Fragment>
      );
    });

    // Total Row
    rows.push(
      <tr key="total" className="bg-indigo-600 text-white font-bold print:bg-gray-100 print:text-black">
        <td colSpan={2} className="px-4 py-3 text-sm text-right">SECTION TOTAL</td>
        <td className="px-4 py-3 text-sm text-center">{totalNew}</td>
        <td className="px-4 py-3 text-sm text-center">{totalReatt}</td>
        <td className="px-4 py-3 text-sm text-center">{totalTotal}</td>
      </tr>
    );

    return rows;
  };

  const a1_a2_rows = [
    { key: "under_5_m", label: "Children Under 5 - Male" },
    { key: "under_5_f", label: "Children Under 5 - Female" },
    { key: "over_5_m", label: "Over 5 - Male" },
    { key: "over_5_f", label: "Over 5 - Female" },
    { key: "over_60", label: "Over 60 years" },
  ];

  const a3_rows = [
    { key: "ent", label: "E.N.T Clinic" },
    { key: "eye", label: "Eye Clinic" },
    { key: "tb_leprosy", label: "TB and Leprosy" },
    { key: "ccc", label: "Comprehensive Care Clinic (CCC)" },
    { key: "psychiatry", label: "Psychiatry" },
    { key: "orthopaedic", label: "Orthopaedic Clinic" },
    { key: "occupational", label: "Occupational Therapy Clinic" },
    { key: "physiotherapy", label: "Physiotherapy Clinic" },
    { key: "medical", label: "Medical Clinics" },
    { key: "surgical", label: "Surgical Clinics" },
    { key: "paediatrics", label: "Paediatrics" },
    { key: "obs_gyn", label: "Obstetrics/Gynaecology" },
    { key: "nutrition", label: "Nutrition Clinic" },
    { key: "oncology", label: "Oncology Clinic" },
    { key: "renal", label: "Renal Clinic" },
    { key: "other", label: "All other Clinics" },
  ];

  const a4_rows = [
    { key: "cwc", label: "Child Welfare Clinic (CWC)" },
    { key: "anc", label: "Antenatal Clinic (ANC)" },
    { key: "pnc", label: "Postnatal Clinic (PNC)" },
    { key: "fp", label: "Family Planning (FP)" },
  ];

  return (
    <div className="space-y-6">
      {/* Controls */}
      <div className="print:hidden flex flex-col md:flex-row gap-4 items-end bg-indigo-50 p-4 rounded-xl border border-indigo-100">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Month</label>
          <select value={month} onChange={(e) => setMonth(+e.target.value)} className="border-gray-300 rounded-lg shadow-sm focus:border-indigo-500 focus:ring-indigo-500 bg-white px-3 py-2">
            {months.map((m) => <option key={m.value} value={m.value}>{m.label}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Year</label>
          <input type="number" value={year} onChange={(e) => setYear(+e.target.value)} className="border-gray-300 rounded-lg shadow-sm focus:border-indigo-500 focus:ring-indigo-500 bg-white px-3 py-2 w-32" />
        </div>
        <button onClick={fetchReport} disabled={loading} className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2 disabled:opacity-50">
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} /> Generate
        </button>
        <button onClick={handlePrint} className="ml-auto bg-gray-800 hover:bg-gray-900 text-white px-4 py-2 rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2">
          <Printer className="w-4 h-4" /> Print Report
        </button>
      </div>

      {loading && (
        <div className="flex justify-center py-16">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600" />
        </div>
      )}

      {!loading && reportData && reportData.a6_total === 0 && fetchedPeriod && (
        <div className="flex flex-col items-center py-16 gap-4 text-gray-400">
          <svg className="w-16 h-16 text-indigo-100" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 17v-6a2 2 0 012-2h2a2 2 0 012 2v6m-6 0h6m-3-10V4m0 0C9.5 4 7 5.5 7 8" />
          </svg>
          <p className="text-lg font-semibold text-gray-500">No outpatient visits recorded</p>
          <p className="text-sm text-gray-400">
            There are no treatment records for{" "}
            <span className="font-bold text-indigo-600">
              {months.find(m => m.value === fetchedPeriod.month)?.label} {fetchedPeriod.year}
            </span>
            . Try selecting a different month.
          </p>
        </div>
      )}

      {!loading && reportData && reportData.a6_total > 0 && (
        <div className="bg-white border-2 border-transparent p-4 md:p-8 rounded-xl shadow-sm print:border-none print:shadow-none mx-auto max-w-[900px]">
          
          <div className="text-center mb-8">
            <h2 className="text-xl font-bold font-serif uppercase text-gray-800 print:text-black">Republic of Kenya</h2>
            <h3 className="text-lg font-bold font-serif uppercase text-gray-700 print:text-black">Ministry of Health</h3>
            <h4 className="text-lg font-bold mt-2 text-indigo-900 print:text-black">MONTHLY SERVICE WORKLOAD REPORT FOR HEALTH FACILITIES</h4>
            <h5 className="text-2xl font-black mt-2 text-indigo-600 print:text-black">MOH 717</h5>
            {fetchedPeriod && (
              <p className="mt-2 text-sm font-medium text-indigo-400 print:text-gray-600">
                Showing data for{" "}
                <span className="font-bold text-indigo-700 print:text-black">
                  {months.find(m => m.value === fetchedPeriod.month)?.label} {fetchedPeriod.year}
                </span>
              </p>
            )}
          </div>

          <div className="grid grid-cols-2 md:grid-cols-3 gap-y-4 gap-x-6 bg-gray-50 p-5 rounded-lg border border-gray-200 mb-8 font-medium text-sm print:border-2 print:border-black print:bg-transparent">
            <div className="flex flex-col"><span className="text-gray-500 text-xs">County</span><span>{facilityInfo.county}</span></div>
            <div className="flex flex-col"><span className="text-gray-500 text-xs">Sub-County</span><span>{facilityInfo.subCounty}</span></div>
            <div className="flex flex-col"><span className="text-gray-500 text-xs">Health Facility</span><span>{facilityInfo.facility}</span></div>
            <div className="flex flex-col"><span className="text-gray-500 text-xs">Month / Year</span><span>{months.find(m => m.value === month)?.label} {year}</span></div>
            <div className="flex flex-col"><span className="text-gray-500 text-xs">KMHFL Code</span><span>{facilityInfo.kmhfl}</span></div>
          </div>

          <div className="space-y-8">
            {/* A.1 and A.2 */}
            <div className="border border-gray-200 rounded-xl overflow-hidden print:border-black print:rounded-none">
              <table className="w-full">
                <thead>
                  <tr className="bg-indigo-100 text-indigo-900 print:bg-gray-100 print:text-black">
                    <th className="py-3 px-4 text-left font-bold text-lg" colSpan={5}>A. OUTPATIENT SERVICES</th>
                  </tr>
                  <tr className="bg-white border-b border-gray-200 print:border-black">
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 w-8 print:hidden"></th>
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 print:text-black">A.1 GENERAL OUTPATIENTS</th>
                    <th className="py-2 px-4 text-center font-semibold text-gray-600 w-24 print:text-black">NEW</th>
                    <th className="py-2 px-4 text-center font-semibold text-gray-600 w-24 print:text-black">RE-ATT</th>
                    <th className="py-2 px-4 text-center font-bold text-indigo-700 w-24 print:text-black">TOTAL</th>
                  </tr>
                </thead>
                <tbody>{renderInteractiveRows("a1", a1_a2_rows)}</tbody>
                
                <thead>
                  <tr className="bg-white border-y border-gray-200 print:border-black">
                    <th className="print:hidden"></th>
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 print:text-black">A.2 CASUALTY</th>
                    <th></th><th></th><th></th>
                  </tr>
                </thead>
                <tbody>{renderInteractiveRows("a2", a1_a2_rows)}</tbody>
              </table>
            </div>

            {/* A.3 */}
            <div className="border border-gray-200 rounded-xl overflow-hidden print:border-black print:rounded-none">
              <table className="w-full">
                <thead>
                  <tr className="bg-white border-b border-gray-200 print:border-black">
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 w-8 print:hidden"></th>
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 print:text-black">A.3 SPECIAL CLINICS</th>
                    <th className="py-2 px-4 text-center font-semibold text-gray-600 w-24 print:text-black">NEW</th>
                    <th className="py-2 px-4 text-center font-semibold text-gray-600 w-24 print:text-black">RE-ATT</th>
                    <th className="py-2 px-4 text-center font-bold text-indigo-700 w-24 print:text-black">TOTAL</th>
                  </tr>
                </thead>
                <tbody>{renderInteractiveRows("a3", a3_rows)}</tbody>
              </table>
            </div>

            {/* A.4 MCH */}
            <div className="border border-gray-200 rounded-xl overflow-hidden print:border-black print:rounded-none">
              <table className="w-full">
                <thead>
                  <tr className="bg-white border-b border-gray-200 print:border-black">
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 w-8 print:hidden"></th>
                    <th className="py-2 px-4 text-left font-semibold text-gray-600 print:text-black">A.4 MCH / FP CLIENTS</th>
                    <th className="py-2 px-4 text-center font-semibold text-gray-600 w-24 print:text-black">NEW</th>
                    <th className="py-2 px-4 text-center font-semibold text-gray-600 w-24 print:text-black">RE-ATT</th>
                    <th className="py-2 px-4 text-center font-bold text-indigo-700 w-24 print:text-black">TOTAL</th>
                  </tr>
                </thead>
                <tbody>{renderInteractiveRows("a4", a4_rows)}</tbody>
              </table>
            </div>

            {/* A.5 Dental Summary */}
            <div className="border border-gray-200 rounded-xl overflow-x-auto print:border-black print:rounded-none">
              <table className="w-full">
                <thead>
                  <tr className="bg-gray-50 border-b border-gray-200 print:border-black">
                    <th className="py-2 px-4 tracking-wide text-left font-semibold text-gray-700 print:text-black">A.5 DENTAL CLINIC</th>
                    <th className="py-2 px-4 text-center font-bold text-indigo-700 print:text-black w-24">TOTAL</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 bg-white">
                  <tr 
                    className={`transition-colors relative ${reportData.a5?.patients?.length > 0 ? "cursor-pointer hover:bg-indigo-50" : ""}`}
                    onClick={() => reportData.a5?.patients?.length > 0 && toggle("a5", "attendances")}
                  >
                    <td className="py-3 px-4 font-medium text-gray-700 flex items-center gap-2">
                      {reportData.a5?.patients?.length > 0 ? (
                        expanded["a5_attendances"] ? <ChevronDown className="w-4 h-4 text-indigo-500" /> : <ChevronRight className="w-4 h-4 text-indigo-400" />
                      ) : (
                        <span className="w-4 h-4"></span>
                      )}
                      Attendances
                    </td>
                    <td className="px-4 text-center font-bold text-lg">{reportData.a5?.attendances || 0}</td>
                  </tr>
                  <tr><td className="py-3 px-10 font-medium text-gray-700">Fillings</td><td className="px-4 text-center font-bold text-lg text-gray-600">{reportData.a5?.fillings || 0}</td></tr>
                  <tr><td className="py-3 px-10 font-medium text-gray-700">Extractions</td><td className="px-4 text-center font-bold text-lg text-gray-600">{reportData.a5?.extractions || 0}</td></tr>
                </tbody>
                {expanded["a5_attendances"] && reportData.a5?.patients?.length > 0 && (
                  <tbody>{renderPatientTable(reportData.a5.patients, "Dental Attendances")}</tbody>
                )}
              </table>
            </div>
            
            {/* A.6 Total Outpatient */}
            <div className="flex flex-col items-center justify-center p-8 border-2 border-indigo-100 rounded-xl bg-indigo-50 print:border-black print:rounded-none content-center">
              <h3 className="font-bold text-lg text-indigo-900 tracking-wide uppercase mb-3 print:text-black">A.6 Total Outpatient Services</h3>
              <div className="text-6xl font-black text-indigo-600 print:text-black drop-shadow-sm">{reportData.a6_total || 0}</div>
              <p className="text-sm text-indigo-400 mt-2">Combined attendances across all clinics</p>
            </div>

          </div>
        </div>
      )}
    </div>
  );
};

export default MOH717;
