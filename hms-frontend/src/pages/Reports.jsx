import React, { useState } from "react";
import { Bar, Doughnut } from "react-chartjs-2";
import {
  Chart as ChartJS,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
  ArcElement
} from "chart.js";
import { BarChart2, FileText, Activity, Users, Bed, AlertTriangle, PieChart, FlaskConical } from "lucide-react";
import DashboardLayout from "../layout/DashboardLayout";

import MOH717 from "../components/reports/MOH717";
import DiseaseReport from "../components/reports/DiseaseReport";
import MOH706 from "../components/reports/MOH706";

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend, ArcElement);

export default function Reports() {
  const [activeTab, setActiveTab] = useState("overview");

  const barData = {
    labels: ["Outpatient Dept (OPD)", "Inpatient Dept (IPD)", "Emergency"],
    datasets: [
      {
        label: "Patients this Week",
        data: [120, 80, 45],
        backgroundColor: ["#4f46e5", "#10b981", "#ef4444"],
        borderRadius: 6,
      },
    ],
  };

  const doughnutData = {
    labels: ["Malaria", "Typhoid", "Respiratory", "Other"],
    datasets: [
      {
        data: [45, 25, 20, 10],
        backgroundColor: ["#3b82f6", "#f59e0b", "#14b8a6", "#9ca3af"],
        borderWidth: 0,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'bottom' }
    }
  };

  const StatCard = ({ title, value, icon: Icon, colorClass, bgLightClass }) => (
    <div className={`p-6 rounded-2xl border ${bgLightClass} border-opacity-50 flex items-center gap-4 transition-transform hover:scale-[1.02]`}>
      <div className={`p-4 rounded-xl ${colorClass} text-white shadow-md`}>
        <Icon className="w-6 h-6" />
      </div>
      <div>
        <p className="text-sm font-medium text-gray-600">{title}</p>
        <p className="text-2xl font-bold text-gray-900">{value}</p>
      </div>
    </div>
  );

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
                  <p className="text-blue-100 text-sm mt-0.5">View and export facility performance and MOH reports.</p>
                </div>
              </div>
            </div>

            {/* Tab navigation */}
            <div className="border-b border-gray-200 bg-gray-50 flex overflow-x-auto hide-scrollbar -mt-1 rounded-t-none">
              <button
                onClick={() => setActiveTab('overview')}
                className={`flex items-center gap-2 px-8 py-4 text-sm font-semibold transition-all duration-300 outline-none ${
                  activeTab === 'overview'
                    ? 'bg-indigo-600 text-white shadow-inner'
                    : 'text-gray-500 hover:bg-gray-200 hover:text-gray-800 focus:bg-gray-200'
                }`}
              >
                <PieChart className={`w-4 h-4 transition-colors duration-300 ${activeTab === 'overview' ? 'text-white' : 'text-gray-400'}`} />
                Overview
              </button>
              <button
                onClick={() => setActiveTab('moh717')}
                className={`flex items-center gap-2 px-8 py-4 text-sm font-semibold transition-all duration-300 outline-none ${
                  activeTab === 'moh717'
                    ? 'bg-indigo-600 text-white shadow-inner'
                    : 'text-gray-500 hover:bg-gray-200 hover:text-gray-800 focus:bg-gray-200'
                }`}
              >
                <FileText className={`w-4 h-4 transition-colors duration-300 ${activeTab === 'moh717' ? 'text-white' : 'text-gray-400'}`} />
                MOH 717
              </button>
              <button
                onClick={() => setActiveTab('disease')}
                className={`flex items-center gap-2 px-8 py-4 text-sm font-semibold transition-all duration-300 outline-none ${
                  activeTab === 'disease'
                    ? 'bg-indigo-600 text-white shadow-inner'
                    : 'text-gray-500 hover:bg-gray-200 hover:text-gray-800 focus:bg-gray-200'
                }`}
              >
                <Activity className={`w-4 h-4 transition-colors duration-300 ${activeTab === 'disease' ? 'text-white' : 'text-gray-400'}`} />
                Disease Surveillance
              </button>
              <button
                onClick={() => setActiveTab('moh706')}
                className={`flex items-center gap-2 px-8 py-4 text-sm font-semibold transition-all duration-300 outline-none ${
                  activeTab === 'moh706'
                    ? 'bg-teal-600 text-white shadow-inner'
                    : 'text-gray-500 hover:bg-gray-200 hover:text-gray-800 focus:bg-gray-200'
                }`}
              >
                <FlaskConical className={`w-4 h-4 transition-colors duration-300 ${activeTab === 'moh706' ? 'text-white' : 'text-gray-400'}`} />
                MOH 706
              </button>
            </div>

            {/* Tab content */}
            <div className="p-6 bg-white min-h-[500px]">
              {activeTab === 'overview' && (
                <div className="space-y-8 animate-in fade-in duration-500">
                  {/* Summary Stats */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <StatCard 
                      title="Total Outpatient Visits" 
                      value="1,248" 
                      icon={Users} 
                      colorClass="bg-indigo-500" 
                      bgLightClass="bg-indigo-50 border-indigo-100" 
                    />
                    <StatCard 
                      title="Active Inpatient Admissions" 
                      value="42" 
                      icon={Bed} 
                      colorClass="bg-emerald-500" 
                      bgLightClass="bg-emerald-50 border-emerald-100" 
                    />
                    <StatCard 
                      title="Emergency Cases" 
                      value="18" 
                      icon={AlertTriangle} 
                      colorClass="bg-rose-500" 
                      bgLightClass="bg-rose-50 border-rose-100" 
                    />
                  </div>

                  {/* Charts */}
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col">
                      <h2 className="text-lg font-bold text-gray-800 mb-6 flex items-center gap-2">
                        <Users className="w-5 h-5 text-indigo-500"/> Patient Distribution
                      </h2>
                      <div className="flex-1 min-h-[300px]">
                        <Bar data={barData} options={chartOptions} />
                      </div>
                    </div>
                    
                    <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col">
                      <h2 className="text-lg font-bold text-gray-800 mb-6 flex items-center gap-2">
                        <Activity className="w-5 h-5 text-amber-500"/> Top Diagnoses (Week)
                      </h2>
                      <div className="flex-1 min-h-[300px] flex justify-center items-center">
                        <div className="w-full max-w-[300px]">
                          <Doughnut data={doughnutData} options={chartOptions} />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}
              {activeTab === 'moh717' && <div className="animate-in fade-in duration-500"><MOH717 /></div>}
              {activeTab === 'disease' && <div className="animate-in fade-in duration-500"><DiseaseReport /></div>}
              {activeTab === 'moh706' && <div className="animate-in fade-in duration-500"><MOH706 /></div>}
            </div>
          </div>

        </div>
      </div>
    </DashboardLayout>
  );
}
