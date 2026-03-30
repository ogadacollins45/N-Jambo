import React, { useState } from "react";
import { Bar } from "react-chartjs-2";
import { Chart as ChartJS, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from "chart.js";
import { BarChart2, FileText, Activity } from "lucide-react";
import DashboardLayout from "../layout/DashboardLayout";

import MOH717 from "../components/reports/MOH717";
import DiseaseReport from "../components/reports/DiseaseReport";

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend);

export default function Reports() {
  const [activeTab, setActiveTab] = useState("overview");

  const data = {
    labels: ["OPD", "IPD", "Emergency"],
    datasets: [
      {
        label: "Patient Category",
        data: [120, 80, 45],
        backgroundColor: ["#2563eb", "#16a34a", "#dc2626"],
      },
    ],
  };

  return (
    <DashboardLayout>
      <div className="p-6 max-w-7xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
              <BarChart2 className="w-6 h-6 text-blue-600" />
              System Reports
            </h1>
            <p className="text-sm text-gray-500 mt-1">
              View and export facility performance and MOH reports.
            </p>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="border-b border-gray-200">
            <nav className="flex -mb-px px-6 flex-wrap gap-x-2">
              <button
                onClick={() => setActiveTab('overview')}
                className={`whitespace-nowrap py-4 px-6 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === 'overview'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Overview
              </button>
              <button
                onClick={() => setActiveTab('moh717')}
                className={`whitespace-nowrap py-4 px-6 border-b-2 font-medium text-sm transition-colors flex items-center gap-2 ${
                  activeTab === 'moh717'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <FileText className="w-4 h-4" />
                MOH 717
              </button>
              <button
                onClick={() => setActiveTab('disease')}
                className={`whitespace-nowrap py-4 px-6 border-b-2 font-medium text-sm transition-colors flex items-center gap-2 ${
                  activeTab === 'disease'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Activity className="w-4 h-4" />
                Disease Surveillance
              </button>
            </nav>
          </div>

          <div className="p-6">
            {activeTab === 'overview' && (
              <div className="bg-white rounded-xl p-2 w-full max-w-3xl">
                <h2 className="text-lg font-semibold mb-4 text-gray-800">Patient Distribution</h2>
                <Bar data={data} />
              </div>
            )}
            {activeTab === 'moh717' && <MOH717 />}
            {activeTab === 'disease' && <DiseaseReport />}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
