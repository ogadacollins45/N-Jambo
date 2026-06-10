import React from "react";
import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import { useSidebar } from "../context/SidebarContext";

const DashboardLayout = ({ children }) => {
  const { isCollapsed } = useSidebar();

  return (
    <div className="flex min-h-screen bg-gray-50 print:min-h-0 print:block print:bg-white">
      <div className="print:hidden"><Sidebar /></div>

      {/* Main Content Area with dynamic margin */}
      <div
        className={`
          flex-1 flex flex-col min-w-0 transition-all duration-300
          ${isCollapsed ? 'md:ml-0' : 'md:ml-0'}
          print:block print:m-0 print:p-0
        `}
      >
        <div className="print:hidden"><Navbar /></div>
        <main className="flex-1 overflow-y-auto print:overflow-visible print:block">
          <div className="w-full h-full p-4 md:p-6 pt-20 print:p-0 print:block">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
};

export default DashboardLayout;
