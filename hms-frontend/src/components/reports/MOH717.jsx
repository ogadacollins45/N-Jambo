import React, { useState, useEffect } from "react";
import { Download, RefreshCw, Printer } from "lucide-react";

const MOH717 = () => {
  const [month, setMonth] = useState(new Date().getMonth() + 1);
  const [year, setYear] = useState(new Date().getFullYear());
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState(null);
  const [facilityInfo, setFacilityInfo] = useState({
    county: "Bungoma",
    subCounty: "Tongaren",
    facility: "Naitiri Jambo Health Medical Services",
    kmhfl: "XXXXXX",
  });

  const months = [
    { value: 1, label: "January" },
    { value: 2, label: "February" },
    { value: 3, label: "March" },
    { value: 4, label: "April" },
    { value: 5, label: "May" },
    { value: 6, label: "June" },
    { value: 7, label: "July" },
    { value: 8, label: "August" },
    { value: 9, label: "September" },
    { value: 10, label: "October" },
    { value: 11, label: "November" },
    { value: 12, label: "December" },
  ];

  const fetchReport = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem("token");
      const res = await fetch(
        `${import.meta.env.VITE_API_BASE_URL}/api/reports/moh-717?month=${month}&year=${year}`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            Accept: "application/json",
          },
        }
      );
      if (res.ok) {
        const data = await res.json();
        setReportData(data);
      } else {
        console.error("Failed to fetch MOH 717 data");
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReport();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [month, year]);

  const handlePrint = () => {
    window.print();
  };

  // Helper for rendering A1 & A2 demographic rows
  const renderDemographicRows = (dataSection) => {
    const rows = [
      { key: "over_5_m", label: "Over 5 - Male" },
      { key: "over_5_f", label: "Over 5 - Female" },
      { key: "under_5_m", label: "Children Under 5 - Male" },
      { key: "under_5_f", label: "Children Under 5 - Female" },
      { key: "over_60", label: "Over 60 years" },
    ];

    let totalNew = 0, totalReatt = 0, totalTotal = 0;

    const formattedRows = rows.map((row) => {
      const rowData = dataSection?.[row.key] || { new: 0, reatt: 0, total: 0 };
      totalNew += rowData.new || 0;
      totalReatt += rowData.reatt || 0;
      totalTotal += rowData.total || 0;

      return (
        <tr key={row.key} className="border-b border-gray-200">
          <td className="px-4 py-2 text-sm text-gray-700">{row.label}</td>
          <td className="px-4 py-2 text-sm text-right">{rowData.new || 0}</td>
          <td className="px-4 py-2 text-sm text-right">{rowData.reatt || 0}</td>
          <td className="px-4 py-2 text-sm text-right font-medium">{rowData.total || 0}</td>
        </tr>
      );
    });

    formattedRows.push(
      <tr key="total" className="bg-gray-50 border-b border-gray-300 font-bold">
        <td className="px-4 py-2 text-sm">TOTAL</td>
        <td className="px-4 py-2 text-sm text-right">{totalNew}</td>
        <td className="px-4 py-2 text-sm text-right">{totalReatt}</td>
        <td className="px-4 py-2 text-sm text-right">{totalTotal}</td>
      </tr>
    );

    return formattedRows;
  };

  // Helper for A.3 Special Clinics
  const renderSpecialClinics = () => {
    const rows = [
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
      { key: "other", label: "All other Special Clinics" },
    ];

    let totalNew = 0, totalReatt = 0, totalTotal = 0;

    const dataSection = reportData?.a3 || {};

    const formattedRows = rows.map((row) => {
      const rowData = dataSection[row.key] || { new: 0, reatt: 0, total: 0 };
      totalNew += rowData.new || 0;
      totalReatt += rowData.reatt || 0;
      totalTotal += rowData.total || 0;

      return (
        <tr key={row.key} className="border-b border-gray-200">
          <td className="px-4 py-2 text-sm text-gray-700">{row.label}</td>
          <td className="px-4 py-2 text-sm text-right">{rowData.new || 0}</td>
          <td className="px-4 py-2 text-sm text-right">{rowData.reatt || 0}</td>
          <td className="px-4 py-2 text-sm text-right font-medium">{rowData.total || 0}</td>
        </tr>
      );
    });

    formattedRows.push(
      <tr key="total_a3" className="bg-gray-50 border-b border-gray-300 font-bold">
        <td className="px-4 py-2 text-sm">TOTAL SPECIAL CLINICS</td>
        <td className="px-4 py-2 text-sm text-right">{totalNew}</td>
        <td className="px-4 py-2 text-sm text-right">{totalReatt}</td>
        <td className="px-4 py-2 text-sm text-right">{totalTotal}</td>
      </tr>
    );

    return formattedRows;
  };

  // Helper for A.4 MCH/FP
  const renderMCH = () => {
    const rows = [
      { key: "cwc", label: "CWC Attendances" },
      { key: "anc", label: "ANC Attendances" },
      { key: "pnc", label: "PNC Attendances" },
      { key: "fp", label: "FP Attendances" },
    ];

    let totalNew = 0, totalReatt = 0, totalTotal = 0;
    const dataSection = reportData?.a4 || {};

    const formattedRows = rows.map((row) => {
      const rowData = dataSection[row.key] || { new: 0, reatt: 0, total: 0 };
      totalNew += rowData.new || 0;
      totalReatt += rowData.reatt || 0;
      totalTotal += rowData.total || 0;

      return (
        <tr key={row.key} className="border-b border-gray-200">
          <td className="px-4 py-2 text-sm text-gray-700">{row.label}</td>
          <td className="px-4 py-2 text-sm text-right">{rowData.new || 0}</td>
          <td className="px-4 py-2 text-sm text-right">{rowData.reatt || 0}</td>
          <td className="px-4 py-2 text-sm text-right font-medium">{rowData.total || 0}</td>
        </tr>
      );
    });

    formattedRows.push(
      <tr key="total_a4" className="bg-gray-50 border-b border-gray-300 font-bold">
        <td className="px-4 py-2 text-sm">TOTAL MCH/FP</td>
        <td className="px-4 py-2 text-sm text-right">{totalNew}</td>
        <td className="px-4 py-2 text-sm text-right">{totalReatt}</td>
        <td className="px-4 py-2 text-sm text-right">{totalTotal}</td>
      </tr>
    );

    return formattedRows;
  };

  const renderSingleColumnRows = (title, items, dataSection, showTotal = false) => {
    let sum = 0;
    const formattedRows = items.map((row) => {
      const val = dataSection?.[row.key] || 0;
      sum += val;
      return (
        <tr key={row.key} className="border-b border-gray-200">
          <td className="px-4 py-2 text-sm text-gray-700">{row.label}</td>
          <td className="px-4 py-2 text-sm text-right font-medium">{val}</td>
        </tr>
      );
    });

    if (showTotal) {
      formattedRows.push(
        <tr key="total" className="bg-gray-50 border-b border-gray-300 font-bold">
          <td className="px-4 py-2 text-sm">TOTAL {title.toUpperCase()}</td>
          <td className="px-4 py-2 text-sm text-right">{sum}</td>
        </tr>
      );
    }
    return formattedRows;
  };

  return (
    <div className="space-y-6 print:m-0 print:p-0">
      {/* Controls (Hidden on hit Print) */}
      <div className="print:hidden flex flex-col md:flex-row gap-4 items-end bg-blue-50 p-4 rounded-xl border border-blue-100">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Month</label>
          <select
            value={month}
            onChange={(e) => setMonth(parseInt(e.target.value))}
            className="border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-white px-3 py-2"
          >
            {months.map((m) => (
              <option key={m.value} value={m.value}>{m.label}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Year</label>
          <input
            type="number"
            value={year}
            onChange={(e) => setYear(parseInt(e.target.value))}
            className="border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-white px-3 py-2 w-32"
          />
        </div>
        <button
          onClick={fetchReport}
          disabled={loading}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2 disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
          Generate
        </button>
        <button
          onClick={handlePrint}
          className="ml-auto bg-gray-800 hover:bg-gray-900 text-white px-4 py-2 rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2"
        >
          <Printer className="w-4 h-4" />
          Print Report
        </button>
      </div>

      {/* Report Form Container */}
      <div className="bg-white border-2 border-black p-8 text-black print:border-none print:shadow-none mx-auto max-w-[800px]">
        {/* Header */}
        <div className="text-center mb-6">
          <h2 className="text-xl font-bold font-serif uppercase">Republic of Kenya</h2>
          <h3 className="text-lg font-bold font-serif uppercase">Ministry of Health</h3>
          <h4 className="text-lg font-bold mt-2">MONTHLY SERVICE WORKLOAD REPORT FOR HEALTH FACILITIES</h4>
          <h5 className="text-xl font-black mt-2">MOH 717</h5>
          <p className="text-sm italic mt-1">Revised April 2019</p>
        </div>

        {/* Facility Info grid */}
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-y-4 gap-x-6 border-2 border-black p-4 mb-6 font-medium text-sm">
          <div className="flex">
            <span className="mr-2">County:</span>
            <span className="border-b border-black border-dotted flex-1 inline-block">{facilityInfo.county}</span>
          </div>
          <div className="flex">
            <span className="mr-2">Sub-County:</span>
            <span className="border-b border-black border-dotted flex-1 inline-block">{facilityInfo.subCounty}</span>
          </div>
          <div className="flex">
            <span className="mr-2">Health Facility:</span>
            <span className="border-b border-black border-dotted flex-1 inline-block">{facilityInfo.facility}</span>
          </div>
          <div className="flex">
            <span className="mr-2">Month:</span>
            <span className="border-b border-black border-dotted flex-1 inline-block">{months.find(m => m.value === month)?.label}</span>
          </div>
          <div className="flex">
            <span className="mr-2">Year:</span>
            <span className="border-b border-black border-dotted flex-1 inline-block">{year}</span>
          </div>
          <div className="flex">
            <span className="mr-2">KMHFL Code:</span>
            <span className="border-b border-black border-dotted flex-1 inline-block">{facilityInfo.kmhfl}</span>
          </div>
        </div>

        {/* A. OUTPATIENT SERVICES */}
        <div className="mb-2">
          <h3 className="font-bold text-lg bg-gray-100 p-1 border border-black mb-2">A. OUTPATIENT SERVICES</h3>
          
          <div className="overflow-x-auto">
            <table className="w-full border-collapse border border-black">
              <thead>
                <tr className="bg-gray-50 border-b border-black">
                  <th className="border-r border-black p-2 text-left font-bold w-1/2">A.1 GENERAL OUTPATIENTS (FILTER CLINICS)</th>
                  <th className="border-r border-black p-2 font-bold w-1/6">NEW</th>
                  <th className="border-r border-black p-2 font-bold w-1/6">RE-ATT</th>
                  <th className="p-2 font-bold w-1/6">TOTAL</th>
                </tr>
              </thead>
              <tbody>
                {renderDemographicRows(reportData?.a1)}
              </tbody>

              <thead>
                <tr className="bg-gray-50 border-y border-black">
                  <th className="border-r border-black p-2 text-left font-bold">A.2 CASUALTY</th>
                  <th className="border-r border-black p-2 font-bold">NEW</th>
                  <th className="border-r border-black p-2 font-bold">RE-ATT</th>
                  <th className="p-2 font-bold">TOTAL</th>
                </tr>
              </thead>
              <tbody>
                {renderDemographicRows(reportData?.a2)}
              </tbody>

              <thead>
                <tr className="bg-gray-50 border-y border-black">
                  <th className="border-r border-black p-2 text-left font-bold">A.3 SPECIAL CLINICS</th>
                  <th className="border-r border-black p-2 font-bold">NEW</th>
                  <th className="border-r border-black p-2 font-bold">RE-ATT</th>
                  <th className="p-2 font-bold">TOTAL</th>
                </tr>
              </thead>
              <tbody>
                {renderSpecialClinics()}
              </tbody>

              <thead>
                <tr className="bg-gray-50 border-y border-black">
                  <th className="border-r border-black p-2 text-left font-bold">A.4 MCH/FP CLIENTS</th>
                  <th className="border-r border-black p-2 font-bold">NEW</th>
                  <th className="border-r border-black p-2 font-bold">RE-ATT</th>
                  <th className="p-2 font-bold">TOTAL</th>
                </tr>
              </thead>
              <tbody>
                {renderMCH()}
              </tbody>
            </table>

            {/* A.5 and A.6 structure */}
            <div className="flex mt-4 gap-4">
              <div className="w-1/2">
                <table className="w-full border-collapse border border-black">
                  <thead>
                    <tr className="bg-gray-50 border-b border-black">
                      <th className="border-r border-black p-2 text-left font-bold">A.5 DENTAL CLINIC</th>
                      <th className="p-2 font-bold w-24">TOTAL</th>
                    </tr>
                  </thead>
                  <tbody>
                    {renderSingleColumnRows("Dental Services", [
                      { key: "attendances", label: "Attendances (Excluding fillings and extractions)" },
                      { key: "fillings", label: "Fillings" },
                      { key: "extractions", label: "Extractions" },
                    ], reportData?.a5, true)}
                  </tbody>
                </table>
              </div>
              <div className="w-1/2 flex items-center justify-center p-4 border border-black bg-gray-50">
                <div className="text-center">
                  <h3 className="font-bold text-lg mb-2">A.6 TOTAL OUTPATIENT SERVICES</h3>
                  <div className="text-3xl font-black">{reportData?.a6_total || 0}</div>
                </div>
              </div>
            </div>

            {/* Other Services */}
            <div className="mt-4">
              <h4 className="font-bold mb-2">Other Services</h4>
              <table className="w-1/2 border-collapse border border-black">
                <tbody>
                  {renderSingleColumnRows("", [
                    { key: "a7", label: "A.7 Medical Examinations" },
                    { key: "a8", label: "A.8 Medical Reports" },
                    { key: "a9", label: "A.9 Dressings" },
                    { key: "a10", label: "A.10 Removal of Stitches" },
                    { key: "a11", label: "A.11 Injections" },
                    { key: "a12", label: "A.12 Stitching" },
                  ], reportData?.other_services)}
                </tbody>
              </table>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
};

export default MOH717;
