import React, { useState, useEffect } from 'react';
import { X, Search, UserPlus, Microscope, Trash2, Loader } from 'lucide-react';
import axios from 'axios';
import { useDebounce } from 'use-debounce';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api';

const AddManualLabRequestModal = ({ isOpen, onClose, onSuccess }) => {
    const [step, setStep] = useState(1); // 1: Patient, 2: Lab Tests, 3: Summary
    const [patientMode, setPatientMode] = useState('search'); // 'search' or 'register'

    // Patient search
    const [searchQuery, setSearchQuery] = useState('');
    const [searchResults, setSearchResults] = useState([]);
    const [selectedPatient, setSelectedPatient] = useState(null);
    const [searching, setSearching] = useState(false);

    // Debounce search
    const [debouncedSearch] = useDebounce(searchQuery, 400);

    // New patient registration
    const [newPatient, setNewPatient] = useState({
        first_name: '',
        last_name: '',
        national_id: '',
        gender: '',
        dob: '',
        age: '',
        phone: '',
        email: '',
        address: '',
    });

    // Lab Tests Selection
    const [testSearch, setTestSearch] = useState('');
    const [availableTests, setAvailableTests] = useState({});
    const [selectedTests, setSelectedTests] = useState([]);
    const [priority, setPriority] = useState('routine');
    const [clinicalNotes, setClinicalNotes] = useState('');
    const [loadingTests, setLoadingTests] = useState(false);

    // Loading states
    const [loading, setLoading] = useState(false);

    // Form logic helpers
    const calculateAgeFromDOB = (dob) => {
        if (!dob) return '';
        const birthDate = new Date(dob);
        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
        return age >= 0 ? age : '';
    };

    const calculateDOBFromAge = (age) => {
        if (!age || isNaN(age)) return '';
        const today = new Date();
        const birthYear = today.getFullYear() - parseInt(age);
        const dob = new Date(birthYear, today.getMonth(), today.getDate());
        return dob.toISOString().split('T')[0];
    };

    const handlePatientChange = (e) => {
        const { name, value } = e.target;
        if (name === 'dob') {
            const newAge = calculateAgeFromDOB(value);
            setNewPatient((prev) => ({ ...prev, dob: value, age: newAge }));
        } else if (name === 'age') {
            const newDOB = calculateDOBFromAge(value);
            setNewPatient((prev) => ({ ...prev, age: value, dob: newDOB }));
        } else {
            setNewPatient((prev) => ({ ...prev, [name]: value }));
        }
    };

    // Auto-search patients
    useEffect(() => {
        if (debouncedSearch.length >= 2) {
            const searchPatients = async () => {
                setSearching(true);
                try {
                    const response = await axios.get('/patients', {
                        params: { search: debouncedSearch }
                    });
                    setSearchResults(response.data.data || response.data);
                } catch (error) {
                    console.error('Error searching patients:', error);
                } finally {
                    setSearching(false);
                }
            };
            searchPatients();
        } else {
            setSearchResults([]);
        }
    }, [debouncedSearch]);

    // Fetch tests on mount or when reaching step 2
    useEffect(() => {
        if (step === 2 && Object.keys(availableTests).length === 0) {
            fetchTests();
        }
    }, [step]);

    const fetchTests = async () => {
        setLoadingTests(true);
        try {
            const res = await axios.get('/lab/tests/available');
            setAvailableTests(res.data);
        } catch (error) {
            console.error('Failed to load tests:', error);
        } finally {
            setLoadingTests(false);
        }
    };

    const handleRegisterPatient = async () => {
        setLoading(true);
        try {
            const response = await axios.post('/patients', newPatient);
            setSelectedPatient(response.data.data || response.data);
            setStep(2);
        } catch (error) {
            console.error('Error registering patient:', error);
            const errorMessage = error.response?.data?.errors
                ? Object.values(error.response.data.errors).flat().join(' ')
                : error.response?.data?.message || 'Failed to register patient';
            alert(errorMessage);
        } finally {
            setLoading(false);
        }
    };

    const toggleTest = (test) => {
        const exists = selectedTests.find((t) => t.id === test.id);
        if (exists) {
            setSelectedTests(selectedTests.filter((t) => t.id !== test.id));
        } else {
            setSelectedTests([...selectedTests, test]);
        }
    };

    const removeTest = (id) => {
        setSelectedTests(selectedTests.filter((t) => t.id !== id));
    };

    // Filter available tests by text
    const getFilteredTests = () => {
        if (!testSearch) return availableTests;
        const lowerSearch = testSearch.toLowerCase();
        let filtered = {};
        Object.keys(availableTests).forEach(category => {
            const matchedTests = availableTests[category].filter(t => 
                t.name.toLowerCase().includes(lowerSearch) || 
                (t.code && t.code.toLowerCase().includes(lowerSearch))
            );
            if (matchedTests.length > 0) {
                filtered[category] = matchedTests;
            }
        });
        return filtered;
    };

    const handleSubmit = async () => {
        if (!selectedPatient || selectedTests.length === 0) return;

        setLoading(true);
        try {
            const payload = {
                patient_id: selectedPatient.id,
                priority: priority,
                clinical_notes: clinicalNotes,
                test_ids: selectedTests.map(t => t.id),
                is_manual_request: true // Bypass doctor validation in backend
            };

            await axios.post('/lab/requests', payload);

            onSuccess();
            handleClose();
        } catch (error) {
            console.error('Error creating lab request:', error);
            alert(error.response?.data?.message || 'Failed to create lab request');
        } finally {
            setLoading(false);
        }
    };

    const handleClose = () => {
        setStep(1);
        setPatientMode('search');
        setSearchQuery('');
        setSearchResults([]);
        setSelectedPatient(null);
        setNewPatient({ first_name: '', last_name: '', national_id: '', gender: '', dob: '', age: '', phone: '', email: '', address: '' });
        setSelectedTests([]);
        setTestSearch('');
        setPriority('routine');
        setClinicalNotes('');
        onClose();
    };

    if (!isOpen) return null;

    const filteredTests = getFilteredTests();

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col">
                {/* Header */}
                <div className="bg-indigo-600 text-white px-6 py-4 flex justify-between items-center shrink-0">
                    <h2 className="text-xl font-bold flex items-center"><Microscope className="mr-2" /> Add Manual Lab Request</h2>
                    <button onClick={handleClose} className="text-indigo-100 hover:text-white transition">
                        <X size={24} />
                    </button>
                </div>

                {/* Progress */}
                <div className="flex border-b shrink-0 bg-gray-50">
                    <div className={`flex-1 text-center py-3 text-sm transition-colors ${step >= 1 ? 'bg-indigo-50 text-indigo-700 border-b-2 border-indigo-600 font-semibold' : 'text-gray-500'}`}>
                        1. Select Patient
                    </div>
                    <div className={`flex-1 text-center py-3 text-sm transition-colors ${step >= 2 ? 'bg-indigo-50 text-indigo-700 border-b-2 border-indigo-600 font-semibold' : 'text-gray-500'}`}>
                        2. Details & Tests
                    </div>
                    <div className={`flex-1 text-center py-3 text-sm transition-colors ${step >= 3 ? 'bg-indigo-50 text-indigo-700 border-b-2 border-indigo-600 font-semibold' : 'text-gray-500'}`}>
                        3. Confirm
                    </div>
                </div>

                {/* Content */}
                <div className="p-6 overflow-y-auto flex-1">
                    {/* STEP 1: PATIENT */}
                    {step === 1 && (
                        <div className="space-y-4 max-w-2xl mx-auto">
                            <div className="flex gap-4 p-1 bg-gray-100 rounded-lg">
                                <button
                                    onClick={() => setPatientMode('search')}
                                    className={`flex-1 flex items-center justify-center py-2.5 rounded-md font-medium text-sm transition-colors ${patientMode === 'search' ? 'bg-white text-indigo-700 shadow-sm' : 'text-gray-600 hover:text-gray-900'}`}
                                >
                                    <Search className="w-4 h-4 mr-2" /> Search Existing
                                </button>
                                <button
                                    onClick={() => setPatientMode('register')}
                                    className={`flex-1 flex items-center justify-center py-2.5 rounded-md font-medium text-sm transition-colors ${patientMode === 'register' ? 'bg-white text-indigo-700 shadow-sm' : 'text-gray-600 hover:text-gray-900'}`}
                                >
                                    <UserPlus className="w-4 h-4 mr-2" /> Register New
                                </button>
                            </div>

                            {patientMode === 'search' && (
                                <div className="space-y-4">
                                    <div className="relative">
                                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                                        <input
                                            type="text"
                                            placeholder="Search by name, phone, UPID..."
                                            value={searchQuery}
                                            onChange={(e) => setSearchQuery(e.target.value)}
                                            className="w-full border-gray-300 rounded-lg pl-10 pr-4 py-3 focus:ring-2 focus:ring-indigo-500 border"
                                        />
                                        {searching && <Loader className="absolute right-3 top-1/2 -translate-y-1/2 text-indigo-500 w-5 h-5 animate-spin" />}
                                    </div>
                                    <div className="border rounded-lg max-h-80 overflow-y-auto bg-gray-50">
                                        {searchResults.length > 0 ? (
                                            <div className="divide-y divide-gray-200">
                                                {searchResults.map(patient => (
                                                    <div
                                                        key={patient.id}
                                                        onClick={() => { setSelectedPatient(patient); setStep(2); }}
                                                        className="p-4 bg-white hover:bg-indigo-50 cursor-pointer transition-colors group"
                                                    >
                                                        <div className="flex justify-between items-center">
                                                            <div>
                                                                <p className="font-semibold text-gray-900 group-hover:text-indigo-700">
                                                                    {patient.first_name} {patient.last_name}
                                                                </p>
                                                                <p className="text-sm text-gray-500 mt-1">
                                                                    {patient.upid && <span className="mr-3 font-mono text-xs bg-gray-100 px-2 py-0.5 rounded">{patient.upid}</span>}
                                                                    {patient.phone || 'No phone'} • {patient.gender === 'M' ? 'Male' : patient.gender === 'F' ? 'Female' : patient.gender}
                                                                </p>
                                                            </div>
                                                            <div className="text-indigo-600 opacity-0 group-hover:opacity-100 transition-opacity">
                                                                Select &rarr;
                                                            </div>
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        ) : searchQuery.length >= 2 && !searching ? (
                                            <div className="p-8 text-center text-gray-500">No patients found.</div>
                                        ) : (
                                            <div className="p-8 text-center text-gray-400">Type to search for patients.</div>
                                        )}
                                    </div>
                                </div>
                            )}

                            {patientMode === 'register' && (
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                    {/* Patient Form Fields */}
                                    <div><label className="text-xs text-gray-500">First Name *</label><input type="text" name="first_name" value={newPatient.first_name} onChange={handlePatientChange} className="w-full border rounded p-2 focus:ring-indigo-500" required /></div>
                                    <div><label className="text-xs text-gray-500">Last Name *</label><input type="text" name="last_name" value={newPatient.last_name} onChange={handlePatientChange} className="w-full border rounded p-2 focus:ring-indigo-500" required /></div>
                                    <div><label className="text-xs text-gray-500">National ID</label><input type="text" name="national_id" value={newPatient.national_id} onChange={handlePatientChange} className="w-full border rounded p-2 focus:ring-indigo-500" /></div>
                                    <div>
                                        <label className="text-xs text-gray-500">Gender *</label>
                                        <select name="gender" value={newPatient.gender} onChange={handlePatientChange} className="w-full border rounded p-2 focus:ring-indigo-500" required>
                                            <option value="">Select...</option><option value="M">Male</option><option value="F">Female</option><option value="O">Other</option>
                                        </select>
                                    </div>
                                    <div><label className="text-xs text-gray-500">Date of Birth</label><input type="date" name="dob" value={newPatient.dob} onChange={handlePatientChange} max={new Date().toISOString().split('T')[0]} className="w-full border rounded p-2 focus:ring-indigo-500" /></div>
                                    <div><label className="text-xs text-gray-500">Age</label><input type="number" name="age" value={newPatient.age} onChange={handlePatientChange} className="w-full border rounded p-2 focus:ring-indigo-500" /></div>
                                    <div><label className="text-xs text-gray-500">Phone</label><input type="tel" name="phone" value={newPatient.phone} onChange={handlePatientChange} className="w-full border rounded p-2 focus:ring-indigo-500" /></div>
                                    <div className="sm:col-span-2">
                                        <button onClick={handleRegisterPatient} disabled={loading || !newPatient.first_name || !newPatient.last_name || !newPatient.gender} className="w-full bg-indigo-600 text-white py-2.5 rounded hover:bg-indigo-700 disabled:opacity-50 font-medium mt-2">
                                            {loading ? 'Registering...' : 'Register & Continue'}
                                        </button>
                                    </div>
                                </div>
                            )}
                        </div>
                    )}

                    {/* STEP 2: TESTS */}
                    {step === 2 && (
                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-full">
                            {/* Left Col: Selections */}
                            <div className="space-y-4">
                                <div className="bg-indigo-50 border border-indigo-100 rounded-lg p-4 flex items-center justify-between">
                                    <div>
                                        <p className="text-xs text-indigo-500 font-semibold uppercase tracking-wider mb-1">Patient</p>
                                        <p className="font-semibold text-gray-900">{selectedPatient?.first_name} {selectedPatient?.last_name}</p>
                                    </div>
                                    <button onClick={() => setStep(1)} className="text-sm text-indigo-600 hover:text-indigo-800 underline">Change</button>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="text-sm font-medium text-gray-700 mb-1 block">Priority</label>
                                        <select value={priority} onChange={e => setPriority(e.target.value)} className="w-full border-gray-300 rounded p-2 focus:ring-indigo-500 border">
                                            <option value="routine">Routine</option>
                                            <option value="urgent">Urgent</option>
                                            <option value="stat">STAT</option>
                                        </select>
                                    </div>
                                </div>
                                <div>
                                    <label className="text-sm font-medium text-gray-700 mb-1 block">Clinical Notes (Optional)</label>
                                    <textarea value={clinicalNotes} onChange={e => setClinicalNotes(e.target.value)} rows="2" className="w-full border-gray-300 rounded p-2 focus:ring-indigo-500 border" placeholder="Relevant symptoms, suspected conditions..." />
                                </div>

                                <div>
                                    <h3 className="font-semibold text-gray-800 mb-2 mt-4 text-sm">Selected Tests ({selectedTests.length})</h3>
                                    {selectedTests.length === 0 ? (
                                        <div className="text-center py-6 border-2 border-dashed border-gray-200 rounded-lg text-gray-500 text-sm">No tests selected yet. Search and select from the list.</div>
                                    ) : (
                                        <div className="space-y-2 max-h-[250px] overflow-y-auto pr-1">
                                            {selectedTests.map(test => (
                                                <div key={test.id} className="flex justify-between items-center bg-gray-50 p-3 rounded-lg border border-gray-200">
                                                    <div>
                                                        <p className="font-medium text-sm text-gray-800">{test.name}</p>
                                                        <p className="text-xs text-gray-500">{test?.category?.name}</p>
                                                    </div>
                                                    <button onClick={() => removeTest(test.id)} className="text-red-500 hover:bg-red-50 p-2 rounded transition-colors"><Trash2 className="w-4 h-4" /></button>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            </div>

                            {/* Right Col: Available tests */}
                            <div className="flex flex-col border border-gray-200 rounded-lg bg-gray-50 overflow-hidden max-h-[60vh] lg:max-h-none">
                                <div className="p-3 border-b border-gray-200 bg-white">
                                    <div className="relative">
                                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
                                        <input
                                            type="text"
                                            placeholder="Search available tests..."
                                            value={testSearch}
                                            onChange={(e) => setTestSearch(e.target.value)}
                                            className="w-full border border-gray-300 rounded-md pl-9 pr-3 py-2 text-sm focus:ring-indigo-500"
                                        />
                                    </div>
                                </div>
                                <div className="overflow-y-auto flex-1 p-3">
                                    {loadingTests ? (
                                        <div className="flex flex-col items-center justify-center p-8 text-gray-500">
                                            <Loader className="w-6 h-6 animate-spin mb-2" /> Loading tests...
                                        </div>
                                    ) : Object.keys(filteredTests).length === 0 ? (
                                        <div className="text-center py-8 text-gray-500 text-sm">No tests found matching "{testSearch}"</div>
                                    ) : (
                                        <div className="space-y-4">
                                            {Object.entries(filteredTests).map(([category, tests]) => (
                                                <div key={category}>
                                                    <h4 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2 sticky top-0 bg-gray-50 py-1">{category}</h4>
                                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                                                        {tests.map(test => {
                                                            const isSelected = selectedTests.some(t => t.id === test.id);
                                                            return (
                                                                <div
                                                                    key={test.id}
                                                                    onClick={() => toggleTest(test)}
                                                                    className={`p-3 rounded-lg border text-sm cursor-pointer transition-colors flex justify-between items-center ${isSelected ? 'bg-indigo-50 border-indigo-200 ring-1 ring-indigo-500' : 'bg-white border-gray-200 hover:border-indigo-300 shadow-sm'}`}
                                                                >
                                                                    <span className={`font-medium ${isSelected ? 'text-indigo-900' : 'text-gray-700'}`}>{test.name}</span>
                                                                    {isSelected && <span className="w-3 h-3 rounded-full bg-indigo-600 flex-shrink-0"></span>}
                                                                </div>
                                                            );
                                                        })}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                    )}

                    {/* STEP 3: SUMMARY */}
                    {step === 3 && (
                        <div className="max-w-2xl mx-auto space-y-6">
                            <div className="bg-white border rounded-xl shadow-sm overflow-hidden">
                                <div className="bg-gray-50 px-4 py-3 border-b flex justify-between items-center">
                                    <h3 className="font-semibold text-gray-800">Request Review</h3>
                                </div>
                                <div className="p-4 space-y-4">
                                    <div className="grid grid-cols-2 gap-4">
                                        <div>
                                            <p className="text-xs text-gray-500 uppercase tracking-wider mb-1">Patient</p>
                                            <p className="font-medium">{selectedPatient?.first_name} {selectedPatient?.last_name}</p>
                                            <p className="text-sm text-gray-600">{selectedPatient?.upid}</p>
                                        </div>
                                        <div>
                                            <p className="text-xs text-gray-500 uppercase tracking-wider mb-1">Priority</p>
                                            <p className="font-medium capitalize flex items-center gap-2">
                                                <span className={`w-2 h-2 rounded-full ${priority === 'stat' ? 'bg-red-500' : priority === 'urgent' ? 'bg-orange-500' : 'bg-blue-500'}`}></span>
                                                {priority}
                                            </p>
                                        </div>
                                    </div>
                                    {clinicalNotes && (
                                        <div>
                                            <p className="text-xs text-gray-500 uppercase tracking-wider mb-1">Clinical Notes</p>
                                            <p className="text-sm bg-gray-50 p-2 rounded border text-gray-700">{clinicalNotes}</p>
                                        </div>
                                    )}
                                    
                                    <div>
                                        <p className="text-xs text-gray-500 uppercase tracking-wider mb-2">Tests Requested ({selectedTests.length})</p>
                                        <div className="border rounded-lg bg-gray-50 grid grid-cols-2 gap-px bg-gray-200">
                                            {selectedTests.map(test => (
                                              <div key={test.id} className="bg-white p-2 text-sm text-gray-800 flex items-center"><Microscope className="w-3 h-3 text-indigo-400 mr-2"/> {test.name}</div>
                                            ))}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}
                </div>

                {/* Footer Controls */}
                <div className="border-t bg-gray-50 px-6 py-4 flex justify-between shrink-0">
                    <button
                        onClick={() => step > 1 ? setStep(step - 1) : handleClose()}
                        className="px-6 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-100 font-medium transition"
                    >
                        {step === 1 ? 'Cancel' : 'Back'}
                    </button>

                    {step < 3 ? (
                        <button
                            onClick={() => setStep(step + 1)}
                            disabled={(step === 1 && !selectedPatient) || (step === 2 && selectedTests.length === 0)}
                            className="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed font-medium transition"
                        >
                            Continue
                        </button>
                    ) : (
                        <button
                            onClick={handleSubmit}
                            disabled={loading}
                            className="flex items-center px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition"
                        >
                            {loading ? <><Loader className="w-4 h-4 mr-2 animate-spin" /> Submitting...</> : 'Submit Request'}
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};

export default AddManualLabRequestModal;
