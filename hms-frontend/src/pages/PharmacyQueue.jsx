import { useState, useEffect } from 'react';
import axios from 'axios';
import { Pill, User, Clock, CheckCircle } from 'lucide-react';
import DashboardLayout from '../layout/DashboardLayout';
import './PharmacyQueue.css';

const PharmacyQueue = () => {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('all'); // all, pending, dispensed
    const [selectedOrder, setSelectedOrder] = useState(null);
    const [dispensing, setDispensing] = useState(false);
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [totalOrders, setTotalOrders] = useState(0);

    useEffect(() => {
        fetchOrders(page);
        // No polling - manual refresh only for cost optimization
    }, [filter, page]);

    const fetchOrders = async (currentPage = 1) => {
        setLoading(true);
        try {
            const params = filter !== 'all' ? { status: filter, page: currentPage } : { page: currentPage };
            const res = await axios.get(`${import.meta.env.VITE_API_BASE_URL}/api/pharmacy/orders`, { params });
            setOrders(res.data.data || []);
            setTotalPages(res.data.last_page || 1);
            setTotalOrders(res.data.total || 0);
            setLoading(false);
        } catch (error) {
            console.error('Error fetching pharmacy orders:', error);
            setLoading(false);
        }
    };

    const handleDispense = async (orderId) => {
        if (!confirm('Are you sure you want to dispense this medication? Inventory will be deducted and billing will be updated.')) {
            return;
        }

        setDispensing(true);
        try {
            await axios.post(`${import.meta.env.VITE_API_BASE_URL}/api/pharmacy/orders/${orderId}/dispense`);
            alert('Medication dispensed successfully!');
            fetchOrders();
            setSelectedOrder(null);
        } catch (error) {
            console.error('Error dispensing medication:', error);
            alert(error.response?.data?.error || 'Failed to dispense medication');
        } finally {
            setDispensing(false);
        }
    };

    const getStatusBadge = (status) => {
        if (status === 'pending') {
            return <span className="badge badge-warning"><Clock size={14} /> Pending</span>;
        }
        return <span className="badge badge-success"><CheckCircle size={14} /> Dispensed</span>;
    };

    if (loading) {
        return (
            <DashboardLayout>
                <div className="loading">Loading pharmacy queue...</div>
            </DashboardLayout>
        );
    }

    return (
        <DashboardLayout>
            <div className="pharmacy-queue">
                <div className="queue-header">
                    <h1><Pill size={32} /> Pharmacy Queue</h1>
                    <p>Manage prescription dispensing</p>
                </div>

                <div className="queue-filters">
                    <button
                        className={`filter-btn ${filter === 'all' ? 'active' : ''}`}
                        onClick={() => { setFilter('all'); setPage(1); }}
                    >
                        All Orders {filter === 'all' && `(${totalOrders})`}
                    </button>
                    <button
                        className={`filter-btn ${filter === 'pending' ? 'active' : ''}`}
                        onClick={() => { setFilter('pending'); setPage(1); }}
                    >
                        Pending {filter === 'pending' && `(${totalOrders})`}
                    </button>
                    <button
                        className={`filter-btn ${filter === 'dispensed' ? 'active' : ''}`}
                        onClick={() => { setFilter('dispensed'); setPage(1); }}
                    >
                        Dispensed {filter === 'dispensed' && `(${totalOrders})`}
                    </button>
                </div>

                <div className="queue-content">
                    {orders.length === 0 ? (
                        <div className="empty-state">
                            <Pill size={64} className="empty-icon" />
                            <p>No pharmacy orders found</p>
                        </div>
                    ) : (
                        <div className="orders-grid">
                            {orders.map((order) => (
                                <div key={order.id} className={`order-card ${order.status}`}>
                                    <div className="order-header">
                                        <div>
                                            <h3><User size={18} /> {order.patient.name}</h3>
                                            <p className="text-muted">Age: {order.patient.age || 'N/A'}</p>
                                        </div>
                                        {getStatusBadge(order.status)}
                                    </div>

                                    <div className="order-info">
                                        <p><strong>Doctor:</strong> {order.doctor?.name || 'N/A'}</p>
                                        <p><strong>Ordered:</strong> {new Date(order.created_at).toLocaleString()}</p>
                                        {order.dispensed_at && (
                                            <p><strong>Dispensed:</strong> {new Date(order.dispensed_at).toLocaleString()}</p>
                                        )}
                                    </div>

                                    <div className="medications-list">
                                        <h4>Medications:</h4>
                                        <ul>
                                            {order.medications.map((med, idx) => (
                                                <li key={idx}>
                                                    <Pill size={14} />
                                                    {med.name} - {med.quantity} {med.unit}
                                                </li>
                                            ))}
                                        </ul>
                                    </div>

                                    {order.status === 'pending' && (
                                        <button
                                            className="btn btn-primary"
                                            onClick={() => handleDispense(order.id)}
                                            disabled={dispensing}
                                        >
                                            {dispensing ? 'Dispensing...' : 'Dispense Medication'}
                                        </button>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                    
                    {/* Pagination Controls */}
                    {totalPages > 1 && (
                        <div className="flex justify-between items-center mt-6 py-4 border-t border-gray-100">
                            <span className="text-sm text-gray-600 font-medium">
                                Showing Page {page} of {totalPages}
                            </span>
                            <div className="flex space-x-2">
                                <button
                                    onClick={() => setPage(p => Math.max(1, p - 1))}
                                    disabled={page === 1}
                                    className={`px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-300 ${page === 1 ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-white text-indigo-600 border border-indigo-200 hover:bg-indigo-50 hover:shadow-md'}`}
                                >
                                    Previous
                                </button>
                                <button
                                    onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                                    disabled={page === totalPages}
                                    className={`px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-300 ${page === totalPages ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-white text-indigo-600 border border-indigo-200 hover:bg-indigo-50 hover:shadow-md'}`}
                                >
                                    Next
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </DashboardLayout>
    );
};

export default PharmacyQueue;
