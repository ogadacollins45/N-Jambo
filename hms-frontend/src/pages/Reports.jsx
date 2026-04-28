import React, { useState, useEffect } from "react";
import { Bar, Doughnut } from "react-chartjs-2";
import {
  Chart as ChartJS,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
  ArcElement,
} from "chart.js";
import {
  BarChart2, FileText, Activity, Users, Bed, AlertTriangle,
  PieChart, FlaskConical, TrendingUp, RefreshCw, CalendarDays,
} from "lucide-react";
import DashboardLayout from "../layout/DashboardLayout";

import MOH717 from "../components/reports/MOH717";
import DiseaseReport from "../components/reports/DiseaseReport";
import MOH706 from "../components/reports/MOH706";

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend, ArcElement);

// ─── Constants ────────────────────────────────────────────────────────────────
const MONTHS = [
  { value: 1,  label: "January" },  { value: 2,  label: "February" },
  { value: 3,  label: "March" },    { value: 4,  label: "April" },
  { value: 5,  label: "May" },      { value: 6,  label: "June" },
  { value: 7,  label: "July" },     { value: 8,  label: "August" },
  { value: 9,  label: "September" },{ value: 10, label: "October" },
  { value: 11, label: "November" }, { value: 12, label: "December" },
];

const DOUGHNUT_COLORS = [
  "#4f46e5", "#0ea5e9", "#10b981", "#f59e0b",
  "#ef4444", "#a855f7", "#ec4899", "#14b8a6",
  "#f97316", "#6366f1",
];

// ─── Stat Card ────────────────────────────────────────────────────────────────
const StatCard = ({ title, value, sub, icon: Icon, colorClass, bgClass, loading }) => (
  <div className={`p-6 rounded-2xl border ${bgClass} flex items-center gap-4 transition-all hover:shadow-md hover:scale-[1.01]`}>
    <div className={`p-4 rounded-xl ${colorClass} text-white shadow-md flex-shrink-0`}>
      <Icon className="w-6 h-6" />
    </div>
    <div>
      <p className="text-sm font-medium text-gray-500">{title}</p>
      {loading ? (
        <div className="h-8 w-24 bg-gray-200 animate-pulse rounded-lg mt-1" />
      ) : (
        <p className="text-3xl font-black text-gray-900 tabular-nums">{value}</p>
      )}
      {sub && !loading && (
        <p className="text-xs text-gray-400 mt-0.5">{sub}</p>
      )}
    </div>
  </div>
);

// ─── Main Component ───────────────────────────────────────────────────────────
export default function Reports() {
  const [activeTab, setActiveTab] = useState("overview");

  // ── Period selector (defaults to current month/year) ──────────────────────
  const now = new Date();
  const [selMonth, setSelMonth] = useState(now.getMonth() + 1);
  const [selYear,  setSelYear]  = useState(now.getFullYear());

  // ── Overview state ─────────────────────────────────────────────────────────
  const [overviewData, setOverviewData] = useState(null);
  const [diseaseData,  setDiseaseData]  = useState(null);
  const [overviewLoading, setOverviewLoading] = useState(false);
  const [overviewError,   setOverviewError]   = useState(null);
  const [fetchedPeriod, setFetchedPeriod] = useState(null);

  const fetchOverview = async (month, year) => {
    setOverviewLoading(true);
    setOverviewError(null);
    try {
      const token   = localStorage.getItem("token");
      const headers = { Authorization: `Bearer ${token}`, Accept: "application/json" };
      const base    = import.meta.env.VITE_API_BASE_URL;

      const [statsRes, diseaseRes] = await Promise.all([
        fetch(`${base}/api/reports/overview?month=${month}&year=${year}`, { headers }),
        fetch(`${base}/api/reports/disease-report?month=${month}&year=${year}`, { headers }),
      ]);

      if (!statsRes.ok)   throw new Error(`Overview HTTP ${statsRes.status}`);
      if (!diseaseRes.ok) throw new Error(`Disease HTTP ${diseaseRes.status}`);

      const [stats, disease] = await Promise.all([statsRes.json(), diseaseRes.json()]);
      setOverviewData(stats);
      setDiseaseData(disease);
      setFetchedPeriod({ month, year });
    } catch (err) {
      console.error(err);
      setOverviewError("Failed to load overview data. Please try again.");
    } finally {
      setOverviewLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === "overview") fetchOverview(selMonth, selYear);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab]);

  // ── Top diagnoses from disease-report (same as Disease Surveillance) ───────
  const topDiagnoses = React.useMemo(() => {
    if (!diseaseData?.diseases) return [];
    const labels = diseaseData.labels ?? {};
    return Object.entries(diseaseData.diseases)
      .map(([key, val]) => ({ label: labels[key] ?? key, count: val.total ?? 0 }))
      .filter((d) => d.count > 0)
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);
  }, [diseaseData]);

  // ── Chart data ────────────────────────────────────────────────────────────
  const trendChartData = overviewData?.monthly_trend
    ? {
        labels: overviewData.monthly_trend.map((m) => m.month),
        datasets: [{
          label: "Outpatient Visits",
          data:  overviewData.monthly_trend.map((m) => m.count),
          backgroundColor: "#4f46e5",
          borderRadius: 8,
          borderSkipped: false,
        }],
      }
    : null;

  const diagnosisChartData = topDiagnoses.length
    ? {
        labels: topDiagnoses.map((d) => d.label),
        datasets: [{
          data: topDiagnoses.map((d) => d.count),
          backgroundColor: DOUGHNUT_COLORS,
          borderWidth: 0,
          hoverOffset: 6,
        }],
      }
    : null;

  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      y: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: "#f3f4f6" } },
      x: { grid: { display: false } },
    },
  };

  const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: "right", labels: { boxWidth: 12, font: { size: 11 } } },
    },
  };

  // ── Helpers ───────────────────────────────────────────────────────────────
  const periodLabel = fetchedPeriod
    ? `${MONTHS.find((m) => m.value === fetchedPeriod.month)?.label} ${fetchedPeriod.year}`
    : "—";

  const tabClass = (tab, activeColor = "bg-indigo-600") =>
    `flex items-center gap-2 px-8 py-4 text-sm font-semibold transition-all duration-300 outline-none ${
      activeTab === tab
        ? `${activeColor} text-white shadow-inner`
        : "text-gray-500 hover:bg-gray-200 hover:text-gray-800 focus:bg-gray-200"
    }`;

  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gray-50">
        <div className="w-full p-6 space-y-6">

          {/* Page Header */}
          <div className="bg-white rounded-2xl shadow-xl overflow-hidden w-full">
            <div className="p-6 sm:p-8 bg-gradient-to-r from-blue-600 to-indigo-600">
              <div className="flex items-center">
                <BarChart2 className="w-8 h-8 text-white mr-4" />
                <div>
                  <h1 className="text-2xl font-bold text-white">System Reports</h1>
                  <p className="text-blue-100 text-sm mt-0.5">
                    View and export facility performance and MOH reports.
                  </p>
                </div>
              </div>
            </div>

            {/* Tab navigation */}
            <div className="border-b border-gray-200 bg-gray-50 flex overflow-x-auto hide-scrollbar -mt-1 rounded-t-none">
              <button onClick={() => setActiveTab("overview")} className={tabClass("overview")}>
                <PieChart className={`w-4 h-4 transition-colors duration-300 ${activeTab === "overview" ? "text-white" : "text-gray-400"}`} />
                Overview
              </button>
              <button onClick={() => setActiveTab("moh717")} className={tabClass("moh717")}>
                <FileText className={`w-4 h-4 transition-colors duration-300 ${activeTab === "moh717" ? "text-white" : "text-gray-400"}`} />
                MOH 717
              </button>
              <button onClick={() => setActiveTab("disease")} className={tabClass("disease")}>
                <Activity className={`w-4 h-4 transition-colors duration-300 ${activeTab === "disease" ? "text-white" : "text-gray-400"}`} />
                Disease Surveillance
              </button>
              <button onClick={() => setActiveTab("moh706")} className={tabClass("moh706", "bg-teal-600")}>
                <FlaskConical className={`w-4 h-4 transition-colors duration-300 ${activeTab === "moh706" ? "text-white" : "text-gray-400"}`} />
                MOH 706
              </button>
            </div>

            {/* Tab content */}
            <div className="p-6 bg-white min-h-[500px]">

              {/* ── OVERVIEW TAB ──────────────────────────────────────────── */}
              {activeTab === "overview" && (
                <div className="space-y-6 animate-in fade-in duration-500">

                  {/* ── Period selector bar ──────────────────────────────── */}
                  <div className="flex flex-col sm:flex-row items-start sm:items-end gap-4 bg-indigo-50 border border-indigo-100 rounded-2xl p-4">
                    <div className="flex items-center gap-2 text-indigo-700 mr-2">
                      <CalendarDays className="w-5 h-5" />
                      <span className="text-sm font-semibold">Reporting Period</span>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-gray-500 mb-1">Month</label>
                      <select
                        value={selMonth}
                        onChange={(e) => setSelMonth(+e.target.value)}
                        className="border border-gray-300 rounded-xl bg-white px-3 py-2 text-sm
                                   focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none shadow-sm"
                      >
                        {MONTHS.map((m) => (
                          <option key={m.value} value={m.value}>{m.label}</option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-gray-500 mb-1">Year</label>
                      <input
                        type="number"
                        value={selYear}
                        min={2020}
                        max={2100}
                        onChange={(e) => setSelYear(+e.target.value)}
                        className="border border-gray-300 rounded-xl bg-white px-3 py-2 text-sm w-28
                                   focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none shadow-sm"
                      />
                    </div>

                    <button
                      onClick={() => fetchOverview(selMonth, selYear)}
                      disabled={overviewLoading}
                      className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white
                                 px-5 py-2 rounded-xl text-sm font-semibold shadow-sm transition-all
                                 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      <RefreshCw className={`w-4 h-4 ${overviewLoading ? "animate-spin" : ""}`} />
                      Load Report
                    </button>

                    {fetchedPeriod && (
                      <p className="text-xs text-indigo-500 ml-auto self-center font-medium">
                        Showing data for <span className="font-bold">{periodLabel}</span>
                      </p>
                    )}
                  </div>

                  {/* Error */}
                  {overviewError && (
                    <div className="bg-rose-50 border border-rose-200 rounded-xl p-4 text-rose-700 text-sm flex items-center gap-3">
                      <AlertTriangle className="w-5 h-5 flex-shrink-0" />
                      {overviewError}
                    </div>
                  )}

                  {/* ── Summary Cards ────────────────────────────────────── */}
                  <div>
                    <p className="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-3">
                      {periodLabel} — At a Glance
                    </p>
                    <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
                      <StatCard
                        title={`Outpatient Visits — ${periodLabel}`}
                        value={overviewData?.total_outpatient_this_month?.toLocaleString() ?? "—"}
                        sub="Treatments recorded for the selected month"
                        icon={Users}
                        colorClass="bg-indigo-500"
                        bgClass="bg-indigo-50 border-indigo-100"
                        loading={overviewLoading}
                      />
                      <StatCard
                        title={`Outpatient Visits — ${fetchedPeriod?.year ?? selYear}`}
                        value={overviewData?.total_outpatient_this_year?.toLocaleString() ?? "—"}
                        sub="Year-to-date outpatient total"
                        icon={TrendingUp}
                        colorClass="bg-sky-500"
                        bgClass="bg-sky-50 border-sky-100"
                        loading={overviewLoading}
                      />
                      <StatCard
                        title="Active Inpatient Admissions"
                        value={overviewData?.active_admissions?.toLocaleString() ?? "—"}
                        sub="Currently admitted patients (live)"
                        icon={Bed}
                        colorClass="bg-emerald-500"
                        bgClass="bg-emerald-50 border-emerald-100"
                        loading={overviewLoading}
                      />
                      <StatCard
                        title="Total Registered Patients"
                        value={overviewData?.total_patients?.toLocaleString() ?? "—"}
                        sub="All-time registered patients (live)"
                        icon={Users}
                        colorClass="bg-violet-500"
                        bgClass="bg-violet-50 border-violet-100"
                        loading={overviewLoading}
                      />
                    </div>
                  </div>

                  {/* ── Charts ───────────────────────────────────────────── */}
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

                    {/* Monthly Trend Bar Chart */}
                    <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col">
                      <h2 className="text-base font-bold text-gray-800 mb-1 flex items-center gap-2">
                        <TrendingUp className="w-5 h-5 text-indigo-500" />
                        Outpatient Trend — Last 6 Months
                      </h2>
                      <p className="text-xs text-gray-400 mb-5">Treatment visits per month (rolling from selected month)</p>
                      <div className="flex-1 min-h-[260px]">
                        {overviewLoading ? (
                          <div className="flex items-center justify-center h-full">
                            <div className="w-10 h-10 rounded-full border-4 border-indigo-100 border-t-indigo-500 animate-spin" />
                          </div>
                        ) : trendChartData ? (
                          <Bar data={trendChartData} options={barOptions} />
                        ) : (
                          <div className="flex items-center justify-center h-full text-gray-400 text-sm">
                            No trend data available
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Top Diagnoses Doughnut */}
                    <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col">
                      <h2 className="text-base font-bold text-gray-800 mb-1 flex items-center gap-2">
                        <Activity className="w-5 h-5 text-amber-500" />
                        Top Disease Categories — {periodLabel}
                      </h2>
                      <p className="text-xs text-gray-400 mb-5">
                        Based on mapped diagnosis records (same classification as Disease Surveillance)
                      </p>
                      <div className="flex-1 min-h-[260px] flex items-center justify-center">
                        {overviewLoading ? (
                          <div className="w-10 h-10 rounded-full border-4 border-amber-100 border-t-amber-500 animate-spin" />
                        ) : diagnosisChartData ? (
                          <div className="w-full h-[260px]">
                            <Doughnut data={diagnosisChartData} options={doughnutOptions} />
                          </div>
                        ) : (
                          <div className="text-center text-gray-400 text-sm">
                            <Activity className="w-12 h-12 mx-auto text-gray-200 mb-2" />
                            No diagnosis data for {periodLabel}
                          </div>
                        )}
                      </div>

                      {/* Legend table */}
                      {!overviewLoading && topDiagnoses.length > 0 && (
                        <div className="mt-4 border-t border-gray-100 pt-4 space-y-2">
                          {topDiagnoses.slice(0, 5).map((d, i) => (
                            <div key={i} className="flex items-center gap-3">
                              <span
                                className="w-2.5 h-2.5 rounded-full flex-shrink-0"
                                style={{ backgroundColor: DOUGHNUT_COLORS[i] }}
                              />
                              <span className="text-sm text-gray-700 flex-1 truncate">{d.label}</span>
                              <span className="text-sm font-bold text-gray-800 tabular-nums">{d.count}</span>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>

                  </div>
                </div>
              )}

              {/* Other tabs */}
              {activeTab === "moh717"  && <div className="animate-in fade-in duration-500"><MOH717 /></div>}
              {activeTab === "disease" && <div className="animate-in fade-in duration-500"><DiseaseReport /></div>}
              {activeTab === "moh706"  && <div className="animate-in fade-in duration-500"><MOH706 /></div>}

            </div>
          </div>

        </div>
      </div>
    </DashboardLayout>
  );
}
