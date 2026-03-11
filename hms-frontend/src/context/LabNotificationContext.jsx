import React, { createContext, useContext, useState, useCallback } from 'react';

export const LabNotificationContext = createContext({
    labCompletedCount: 0,
    refreshLabCount: () => {},
});

export const LabNotificationProvider = ({ children }) => {
    const [labCompletedCount, setLabCompletedCount] = useState(0);

    const refreshLabCount = useCallback(async () => {
        try {
            const token = localStorage.getItem('token');
            if (!token) return;

            const res = await fetch(
                `${import.meta.env.VITE_API_BASE_URL}/api/lab/notifications/count`,
                {
                    headers: {
                        Authorization: `Bearer ${token}`,
                        Accept: 'application/json',
                    },
                }
            );

            if (res.ok) {
                const data = await res.json();
                setLabCompletedCount(data.count ?? 0);
            }
        } catch (err) {
            console.error('Error fetching lab notification count:', err);
        }
    }, []);

    return (
        <LabNotificationContext.Provider value={{ labCompletedCount, refreshLabCount }}>
            {children}
        </LabNotificationContext.Provider>
    );
};

export const useLabNotification = () => useContext(LabNotificationContext);
