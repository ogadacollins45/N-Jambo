import React from 'react';
import { X, Trash2, AlertTriangle, Loader } from 'lucide-react';

const ConfirmDeleteModal = ({ 
    isOpen, 
    onClose, 
    onConfirm, 
    title = "Confirm Deletion",
    message = "Are you sure you want to delete this item? This action cannot be undone.",
    confirmText = "Delete Item",
    isDeleting = false,
    dangerZone = true
}) => {
    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden flex flex-col animate-in zoom-in-95 duration-200">
                {/* Header */}
                <div className={`px-6 py-4 flex items-center justify-between ${dangerZone ? 'bg-red-50 border-b border-red-100' : 'bg-gray-50 border-b border-gray-100'}`}>
                    <div className="flex items-center gap-3">
                        <div className={`p-2 rounded-lg ${dangerZone ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-600'}`}>
                            <AlertTriangle size={24} />
                        </div>
                        <h2 className="text-xl font-bold text-gray-900">{title}</h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-black/5 rounded-full text-gray-400 hover:text-gray-600 transition-colors"
                        disabled={isDeleting}
                    >
                        <X size={20} />
                    </button>
                </div>

                {/* Content */}
                <div className="p-6">
                    <p className="text-gray-600 leading-relaxed">
                        {message}
                    </p>
                    
                    {dangerZone && (
                        <div className="mt-4 p-3 bg-red-50 border border-red-100 rounded-xl text-xs text-red-700 font-medium">
                            <p className="flex items-center gap-2">
                                <AlertTriangle size={14} />
                                Warning: This will permanently remove all associated records including treatments, appointments, and bills.
                            </p>
                        </div>
                    )}
                </div>

                {/* Footer */}
                <div className="px-6 py-4 bg-gray-50 border-t border-gray-100 flex items-center justify-end gap-3">
                    <button
                        onClick={onClose}
                        className="px-4 py-2 text-gray-600 font-medium hover:text-gray-800 transition-colors"
                        disabled={isDeleting}
                    >
                        Cancel
                    </button>
                    <button
                        onClick={onConfirm}
                        disabled={isDeleting}
                        className={`flex items-center gap-2 px-6 py-2.5 text-white font-bold rounded-xl transition-all hover:scale-[1.02] active:scale-[0.98] shadow-lg ${
                            dangerZone 
                            ? 'bg-red-600 hover:bg-red-700 shadow-red-100' 
                            : 'bg-indigo-600 hover:bg-indigo-700 shadow-indigo-100'
                        } disabled:opacity-50 disabled:cursor-not-allowed`}
                    >
                        {isDeleting ? (
                            <>
                                <Loader size={18} className="animate-spin" />
                                Processing...
                            </>
                        ) : (
                            <>
                                <Trash2 size={18} />
                                {confirmText}
                            </>
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ConfirmDeleteModal;
