import React, { useContext } from "react";
import { AuthContext } from "../context/AuthContext";

// ==========================================
// MAINTENANCE MODE TOGGLE
// ==========================================
// Change this to `true` to take the system down for maintenance.
// Change this to `false` to restore normal functionality.
export const IS_MAINTENANCE_MODE = false;
// ==========================================

const MaintenanceGuard = ({ type = "login" }) => {
  const { logout } = useContext(AuthContext) || {};
  const [expanded, setExpanded] = React.useState(true);

  if (!IS_MAINTENANCE_MODE) return null;

  if (type === "login") {
    return (
      <div className="bg-amber-50 border-l-4 border-amber-500 p-4 mb-6 shadow-sm rounded-r-md w-full">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-amber-400" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <h3 className="text-sm font-medium text-amber-800">System Maintenance</h3>
            <div className="mt-2 text-sm text-amber-700">
              <p>The system is currently down for maintenance. We will be back online shortly.</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (type === "app") {
    return (
      <div className="absolute top-full left-0 w-full bg-red-600 text-white shadow-md z-[100] border-t border-red-500">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between py-2">
            <div className="flex items-center gap-2">
              <svg className="h-5 w-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
              </svg>
              <span className="font-bold text-sm tracking-wide">SYSTEM MAINTENANCE</span>
            </div>
            <button 
              onClick={() => setExpanded(!expanded)} 
              className="text-white hover:bg-red-700 px-3 py-1 text-xs font-semibold rounded border border-red-400 transition-colors"
            >
              {expanded ? 'Hide Details' : 'Show Details'}
            </button>
          </div>
          
          <div className={`overflow-hidden transition-all duration-300 ease-in-out ${expanded ? 'max-h-40 opacity-100 py-3 border-t border-red-500' : 'max-h-0 opacity-0 py-0'}`}>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <p className="text-sm text-red-50 leading-relaxed max-w-3xl">
                The system is currently undergoing maintenance. Certain features may be unavailable. To ensure your data remains safe, please log out.
              </p>
              <button 
                onClick={() => {
                  if (logout) logout();
                  window.location.href = '/login';
                }}
                className="bg-white text-red-600 hover:bg-gray-100 font-bold py-2 px-5 rounded shadow-sm transition-colors whitespace-nowrap text-sm"
              >
                Log Out Now
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return null;
};

export default MaintenanceGuard;
