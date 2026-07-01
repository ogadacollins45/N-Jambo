import React, { useState, useEffect } from 'react';
import DashboardLayout from '../layout/DashboardLayout';
import axios from 'axios';
import { Activity, Edit, Check, X, ClipboardList } from 'lucide-react';
import Preloader from '../components/Preloader';

const DEFAULT_SERVICES = [
    { name: 'Obstetric Ultrasound', price: 2000 },
    { name: 'Abdominal-Pelvic Ultrasound', price: 3000 },
    { name: 'KUB (Kidneys, Ureters & Bladder)', price: 2000 },
    { name: 'Pelvic Ultrasound', price: 2000 },
    { name: 'Abdominal Ultrasound', price: 2000 },
    { name: 'Renal Ultrasound', price: 2000 },
    { name: 'Prostate Ultrasound', price: 2000 },
    { name: 'Soft Tissue Ultrasound', price: 2000 },
    { name: 'Breast Ultrasound', price: 3000 },
    { name: 'Thyroid Ultrasound', price: 3000 },
    { name: 'Scrotal Ultrasound', price: 3000 },
    { name: 'Twin Pregnancy Scan', price: 3000 },
    { name: 'Detailed Anomaly Scan', price: 3500 },
    { name: 'Doppler Ultrasound', price: 5000 },
    { name: 'Obstetric Doppler', price: 5000 }
];

const ServicesPriceList = () => {
    const [services, setServices] = useState([]);
    const [loading, setLoading] = useState(true);
    const [initializing, setInitializing] = useState(false);
    
    // Editing state
    const [editingId, setEditingId] = useState(null);
    const [editPrice, setEditPrice] = useState('');

    const API_URL = `${import.meta.env.VITE_API_BASE_URL}/api/service-items`;

    useEffect(() => {
        fetchServices();
    }, []);

    const fetchServices = async () => {
        try {
            const token = localStorage.getItem('token');
            const res = await axios.get(API_URL, {
                headers: { Authorization: `Bearer ${token}` }
            });
            // Sort to ensure consistent display
            const sorted = res.data.sort((a, b) => a.name.localeCompare(b.name));
            setServices(sorted);
        } catch (err) {
            console.error("Failed to fetch services", err);
        } finally {
            setLoading(false);
        }
    };

    // Read role synchronously to avoid race conditions with rendering
    const currentRole = localStorage.getItem('role') || '';
    const isAdmin = currentRole.toLowerCase() === 'admin';

    const initializeDefaults = async () => {
        if (!window.confirm("Initialize the default ultrasound services into the system?")) return;
        setInitializing(true);
        const token = localStorage.getItem('token');
        try {
            for (const s of DEFAULT_SERVICES) {
                // Check if it already exists to prevent duplicates
                const existing = services.find(item => item.name.toLowerCase() === s.name.toLowerCase());
                if (!existing) {
                    await axios.post(API_URL, {
                        name: s.name,
                        price: s.price,
                        description: 'Comprehensive Ultrasound Service',
                        is_active: true
                    }, { headers: { Authorization: `Bearer ${token}` } });
                }
            }
            alert("Default services loaded successfully without duplicating existing ones!");
            fetchServices();
        } catch (err) {
            console.error("Initialization failed", err);
            alert("Failed to initialize some services.");
        } finally {
            setInitializing(false);
        }
    };

    const handleEditClick = (service) => {
        setEditingId(service.id);
        setEditPrice(service.price);
    };

    const handleSave = async (id) => {
        try {
            const token = localStorage.getItem('token');
            await axios.put(`${API_URL}/${id}`, {
                price: editPrice
            }, { headers: { Authorization: `Bearer ${token}` } });
            
            setEditingId(null);
            fetchServices();
        } catch (err) {
            console.error("Failed to update price", err);
            alert("Failed to update price.");
        }
    };

    if (loading) return <Preloader />;

    return (
        <DashboardLayout>
            <div className="min-h-screen bg-gray-50 pt-20 px-4 sm:px-6 lg:px-8 pb-8">
                <div className="w-full">
                    
                    <div className="bg-white rounded-2xl shadow-xl overflow-hidden w-full">
                        {/* Header Section */}
                        <div className="p-6 sm:p-8 bg-gradient-to-r from-blue-600 to-indigo-600">
                            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                                <div className="flex items-center">
                                    <ClipboardList className="w-8 h-8 text-white mr-4" />
                                    <div>
                                        <h2 className="text-2xl font-bold text-white">Comprehensive Ultrasound Services</h2>
                                        <p className="text-blue-100 text-sm mt-1">Professional Imaging • Accurate Reports • Same-Day Service</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3">
                                    {isAdmin && (
                                        <button 
                                            onClick={initializeDefaults}
                                            disabled={initializing}
                                            className="flex items-center px-4 py-2 bg-white text-indigo-600 font-medium rounded-lg hover:bg-blue-50 transition-all duration-300 shadow-md"
                                        >
                                            {initializing ? 'Loading Defaults...' : 'Initialize Default Prices'}
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>

                        <div className="p-6 sm:p-8">
                            {services.length === 0 ? (
                                <div className="text-center py-16 bg-gray-50 rounded-2xl border-2 border-dashed border-gray-200">
                                    <ClipboardList className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <p className="text-gray-500 text-lg">No services have been configured yet.</p>
                                </div>
                            ) : (
                            <div className="overflow-hidden rounded-2xl border border-gray-200 shadow-sm">
                                <table className="w-full text-left border-collapse bg-white">
                                    <thead>
                                        <tr className="bg-gray-50 border-b-2 border-gray-200">
                                            <th className="py-5 px-6 font-bold text-gray-700 uppercase tracking-wider text-sm">Ultrasound Procedure</th>
                                            <th className="py-5 px-6 font-bold text-gray-700 uppercase tracking-wider text-sm text-right">Price (KES)</th>
                                            {isAdmin && <th className="py-5 px-6 text-center font-bold text-gray-700 uppercase tracking-wider text-sm w-32">Action</th>}
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100">
                                        {services.map((service, index) => (
                                            <tr key={service.id} className="hover:bg-blue-50/50 transition-colors duration-150 group">
                                                <td className="py-4 px-6 text-gray-800 font-semibold">{service.name}</td>
                                                <td className="py-4 px-6 text-right">
                                                    {editingId === service.id ? (
                                                        <input 
                                                            type="number"
                                                            value={editPrice}
                                                            onChange={(e) => setEditPrice(e.target.value)}
                                                            className="w-28 text-right border-2 border-indigo-400 rounded-lg p-2 font-bold focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                                                            autoFocus
                                                            onKeyDown={(e) => e.key === 'Enter' && handleSave(service.id)}
                                                        />
                                                    ) : (
                                                        <span className="text-indigo-700 font-bold bg-indigo-50 px-3 py-1 rounded-md border border-indigo-100">
                                                            {Number(service.price).toLocaleString()}
                                                        </span>
                                                    )}
                                                </td>
                                                {isAdmin && (
                                                    <td className="py-4 px-6 text-center">
                                                        {editingId === service.id ? (
                                                            <div className="flex justify-center gap-3">
                                                                <button onClick={() => handleSave(service.id)} className="p-2 bg-green-100 text-green-700 rounded-lg hover:bg-green-200 transition-colors shadow-sm" title="Save">
                                                                    <Check className="w-4 h-4"/>
                                                                </button>
                                                                <button onClick={() => setEditingId(null)} className="p-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition-colors shadow-sm" title="Cancel">
                                                                    <X className="w-4 h-4"/>
                                                                </button>
                                                            </div>
                                                        ) : (
                                                            <button 
                                                                onClick={() => handleEditClick(service)} 
                                                                className="p-2 text-gray-400 bg-gray-50 rounded-lg hover:bg-indigo-100 hover:text-indigo-700 transition-all opacity-0 group-hover:opacity-100 focus:opacity-100"
                                                                title="Edit Price"
                                                            >
                                                                <Edit className="w-4 h-4 mx-auto" />
                                                            </button>
                                                        )}
                                                    </td>
                                                )}
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                        </div>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
};

export default ServicesPriceList;
