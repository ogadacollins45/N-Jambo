# Lab Test Completion Notifications — Implementation Guide

This guide documents **every exact file change** needed to add a lab test notification bell to the navbar. When a lab technician completes all tests on a lab request, a red badge appears on a `Bell` icon in the navbar for doctors and admins. Clicking the bell opens a page listing all completed-but-unreviewed lab results, with "View Patient" and "Mark Reviewed" actions.

---

## How It Works

- **No polling.** The badge count is fetched once on page load. It also refreshes automatically when a lab tech submits results.
- **Event-driven.** A shared React Context (`LabNotificationContext`) holds the count and a `refreshLabCount()` function. The `LabProcessing` page calls `refreshLabCount()` after submitting results, which updates the badge instantly.
- **Role-scoped.** Doctors see only their own requests. Admins see all.
- **Acknowledged via "Mark Reviewed".** The `reviewed_at` field in `lab_requests` stays `NULL` after completion, creating the notification. Doctors/admins dismiss it by clicking "Mark Reviewed", which sets `reviewed_at`.

---

## Prerequisites / Assumptions

These are the files and models that must already exist:

- `hms-backend/app/Http/Controllers/LabProcessingController.php` — has a `submitResults()` method that updates `lab_requests.status` to `'completed'`
- `hms-backend/app/Http/Controllers/LabRequestController.php` — existing controller
- `hms-backend/routes/api.php` — existing API routes file
- `hms-backend/app/Models/LabRequest.php` — model with `reviewed_at` and `reviewed_by` in `$fillable`, and `status` field
- `hms-frontend/src/components/Navbar.jsx` — existing navbar with fullscreen button
- `hms-frontend/src/pages/LabProcessing.jsx` — existing lab processing page with a `submitResults()` function
- `hms-frontend/src/main.jsx` — app entry point using `AuthProvider` and `SidebarProvider`
- `hms-frontend/src/context/AuthContext.jsx` — provides `user` with `user.role`

The authenticated user model in the backend is **`Staff`** (not a separate `User` model). `Staff.id` maps directly to `lab_requests.doctor_id`.

---

## Step 1 — Backend: Fix LabProcessingController

**File:** `hms-backend/app/Http/Controllers/LabProcessingController.php`

Find the `submitResults` method. Inside it, find the block that checks if all tests are completed and updates the lab request. It currently looks like this:

```php
$allCompleted = $labRequest->tests()->where('status', '!=', 'completed')->count() === 0;
if ($allCompleted) {
    $labRequest->update([
        'status' => 'completed',
        'reviewed_at' => now(),
    ]);
}
```

**Remove the `'reviewed_at' => now()` line.** The updated block must be:

```php
// Check if all tests completed - mark request as completed but NOT reviewed
// reviewed_at is set separately when a doctor reviews the results
$allCompleted = $labRequest->tests()->where('status', '!=', 'completed')->count() === 0;
if ($allCompleted) {
    $labRequest->update([
        'status' => 'completed',
    ]);
}
```

**Why:** `reviewed_at` being set immediately on completion would mean the badge never appears. It must stay `NULL` until a doctor explicitly marks it as reviewed.

---

## Step 2 — Backend: Add Two Methods to LabRequestController

**File:** `hms-backend/app/Http/Controllers/LabRequestController.php`

Add these two methods **before the final closing `}`** of the class:

```php
/**
 * Get count of completed but unreviewed lab requests (for notification badge)
 * - Doctors see only their own requests
 * - Admins see all
 */
public function notificationsCount(Request $request)
{
    $user = $request->user();

    $query = LabRequest::where('status', 'completed')
        ->whereNull('reviewed_at');

    if ($user->role === 'doctor') {
        // The authenticated user IS a Staff record; doctor_id in lab_requests references staff.id
        $query->where('doctor_id', $user->id);
    }
    // Admin sees all unreviewed completed requests

    return response()->json(['count' => $query->count()]);
}

/**
 * Mark a lab request as reviewed by the logged-in doctor/admin
 */
public function markAsReviewed(Request $request, $id)
{
    $labRequest = LabRequest::findOrFail($id);

    if ($labRequest->status !== 'completed') {
        return response()->json(['message' => 'Lab request is not completed yet'], 422);
    }

    $labRequest->update([
        'reviewed_at' => now(),
        'reviewed_by' => $request->user()->id,
    ]);

    return response()->json(['message' => 'Lab request marked as reviewed']);
}
```

> **Note:** The `LabRequest` model must have `'reviewed_at'` and `'reviewed_by'` in its `$fillable` array. Check `app/Models/LabRequest.php`. If they are missing, add them.

---

## Step 3 — Backend: Add Routes to api.php

**File:** `hms-backend/routes/api.php`

Find the existing line:
```php
Route::get('/lab/tests/available', [\App\Http\Controllers\LabRequestController::class, 'availableTests']);
```

**Add two lines immediately after it:**

```php
Route::get('/lab/tests/available', [\App\Http\Controllers\LabRequestController::class, 'availableTests']);
// Lab notifications (badge count and marking as reviewed)
Route::get('/lab/notifications/count', [\App\Http\Controllers\LabRequestController::class, 'notificationsCount']);
Route::post('/lab/requests/{id}/review', [\App\Http\Controllers\LabRequestController::class, 'markAsReviewed']);
```

These routes must be inside the `auth:sanctum` middleware group (same group as the other lab routes).

---

## Step 4 — Frontend: Create LabNotificationContext.jsx

**Create a new file:** `hms-frontend/src/context/LabNotificationContext.jsx`

Paste the following complete file content:

```jsx
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
```

---

## Step 5 — Frontend: Create LabCompleted.jsx

**Create a new file:** `hms-frontend/src/pages/LabCompleted.jsx`

Paste the following complete file content:

```jsx
import React, { useState, useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import DashboardLayout from '../layout/DashboardLayout';
import { AuthContext } from '../context/AuthContext';
import { useLabNotification } from '../context/LabNotificationContext';
import {
    Microscope,
    CheckCircle2,
    User,
    Clock,
} from 'lucide-react';

const LabCompleted = () => {
    const navigate = useNavigate();
    const { user } = useContext(AuthContext);
    const { refreshLabCount } = useLabNotification();

    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);
    const [reviewingId, setReviewingId] = useState(null);
    const [page, setPage] = useState(1);
    const [meta, setMeta] = useState({ current_page: 1, last_page: 1, total: 0 });

    const API_BASE = `${import.meta.env.VITE_API_BASE_URL}/api`;
    const token = localStorage.getItem('token');

    const loadCompleted = async (p = 1) => {
        setLoading(true);
        try {
            const res = await axios.get(`${API_BASE}/lab/requests`, {
                headers: { Authorization: `Bearer ${token}` },
                params: {
                    status: 'completed',
                    page: p,
                    per_page: 20,
                },
            });

            const allData = res.data?.data ?? res.data ?? [];
            // Only show unreviewed items (reviewed_at == null)
            const unreviewed = Array.isArray(allData)
                ? allData.filter(r => !r.reviewed_at)
                : [];

            setRequests(unreviewed);
            if (res.data?.current_page) {
                setMeta({
                    current_page: res.data.current_page,
                    last_page: res.data.last_page,
                    total: res.data.total,
                });
            }
        } catch (err) {
            console.error('Error loading completed lab requests:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadCompleted(1);
        // Refresh badge count whenever this page is opened
        refreshLabCount();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const handleMarkReviewed = async (requestId) => {
        setReviewingId(requestId);
        try {
            await axios.post(
                `${API_BASE}/lab/requests/${requestId}/review`,
                {},
                { headers: { Authorization: `Bearer ${token}` } }
            );
            // Remove it from the list immediately
            setRequests(prev => prev.filter(r => r.id !== requestId));
            // Refresh the sidebar badge count
            refreshLabCount();
        } catch (err) {
            console.error('Error marking as reviewed:', err);
            alert(err.response?.data?.message || 'Failed to mark as reviewed');
        } finally {
            setReviewingId(null);
        }
    };

    const getPriorityStyle = (priority) => {
        if (priority === 'stat') return 'bg-red-100 text-red-700 border-red-300';
        if (priority === 'urgent') return 'bg-orange-100 text-orange-700 border-orange-300';
        return 'bg-blue-100 text-blue-700 border-blue-300';
    };

    return (
        <DashboardLayout>
            <div className="min-h-screen bg-gray-50 pt-24 p-6">
                {/* Header */}
                <div className="mb-6">
                    <h1 className="text-3xl font-bold text-gray-800 flex items-center gap-3">
                        <Microscope className="w-8 h-8 text-green-600" />
                        Completed Lab Results
                    </h1>
                    <p className="text-gray-600 mt-1">
                        Lab requests completed and awaiting review. Mark as reviewed to dismiss.
                    </p>
                </div>

                {/* Table */}
                <div className="bg-white rounded-xl shadow-md">
                    <div className="p-6">
                        {loading ? (
                            <div className="text-center py-16">
                                <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-green-600" />
                                <p className="text-gray-500 mt-3">Loading results...</p>
                            </div>
                        ) : requests.length === 0 ? (
                            <div className="text-center py-16">
                                <CheckCircle2 className="w-16 h-16 text-green-300 mx-auto mb-4" />
                                <p className="text-gray-600 font-medium text-lg">All caught up!</p>
                                <p className="text-gray-400 text-sm mt-1">No unreviewed completed lab results.</p>
                            </div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead className="bg-gray-50 border-b border-gray-200">
                                        <tr>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Request #</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Patient</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">UPID</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Doctor</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Tests</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Priority</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Completed</th>
                                            <th className="px-4 py-3 text-left font-semibold text-gray-700">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100">
                                        {requests.map((req) => (
                                            <tr key={req.id} className="hover:bg-gray-50 transition-colors">
                                                <td className="px-4 py-3 font-mono text-gray-800 font-medium">
                                                    {req.request_number}
                                                </td>
                                                <td className="px-4 py-3 font-medium text-gray-800">
                                                    {req.patient?.first_name} {req.patient?.last_name}
                                                </td>
                                                <td className="px-4 py-3 text-gray-600">
                                                    {req.patient?.upid || '—'}
                                                </td>
                                                <td className="px-4 py-3 text-gray-600">
                                                    Dr. {req.doctor?.first_name || 'N/A'}
                                                </td>
                                                <td className="px-4 py-3 text-gray-600">
                                                    {req.tests?.length || 0} test(s)
                                                    <div className="text-xs text-gray-400 mt-0.5 space-y-0.5">
                                                        {req.tests?.slice(0, 2).map((t, i) => (
                                                            <div key={i}>{t.template?.name}</div>
                                                        ))}
                                                        {req.tests?.length > 2 && <div>+{req.tests.length - 2} more</div>}
                                                    </div>
                                                </td>
                                                <td className="px-4 py-3">
                                                    <span className={`px-2 py-1 text-xs rounded-full border font-medium ${getPriorityStyle(req.priority)}`}>
                                                        {req.priority?.toUpperCase()}
                                                    </span>
                                                </td>
                                                <td className="px-4 py-3 text-gray-500 text-xs">
                                                    <div className="flex items-center gap-1">
                                                        <Clock className="w-3.5 h-3.5" />
                                                        {new Date(req.updated_at).toLocaleString()}
                                                    </div>
                                                </td>
                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-2">
                                                        {/* View Patient */}
                                                        <button
                                                            onClick={() => navigate(`/patients/${req.patient_id}`)}
                                                            className="flex items-center gap-1 bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                                        >
                                                            <User className="w-3.5 h-3.5" />
                                                            View Patient
                                                        </button>
                                                        {/* Mark Reviewed */}
                                                        <button
                                                            onClick={() => handleMarkReviewed(req.id)}
                                                            disabled={reviewingId === req.id}
                                                            className="flex items-center gap-1 bg-green-600 hover:bg-green-700 disabled:bg-green-300 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                                        >
                                                            <CheckCircle2 className="w-3.5 h-3.5" />
                                                            {reviewingId === req.id ? 'Reviewing...' : 'Mark Reviewed'}
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>

                    {/* Pagination */}
                    {meta.last_page > 1 && (
                        <div className="px-6 py-4 border-t bg-gray-50 flex items-center justify-between">
                            <p className="text-sm text-gray-600">
                                Page {meta.current_page} of {meta.last_page}
                            </p>
                            <div className="flex gap-2">
                                <button
                                    onClick={() => { setPage(p => p - 1); loadCompleted(page - 1); }}
                                    disabled={meta.current_page === 1}
                                    className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    Previous
                                </button>
                                <button
                                    onClick={() => { setPage(p => p + 1); loadCompleted(page + 1); }}
                                    disabled={meta.current_page === meta.last_page}
                                    className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
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

export default LabCompleted;
```

---

## Step 6 — Frontend: Update main.jsx

**File:** `hms-frontend/src/main.jsx`

Make three changes:

### 6a — Add imports near the top (with the other imports)

Add these two import lines alongside the existing page/context imports:

```jsx
import { LabNotificationProvider } from "./context/LabNotificationContext.jsx";
import LabCompleted from "./pages/LabCompleted.jsx";
```

### 6b — Wrap the Router with LabNotificationProvider

Find the current provider wrapping, which looks like this:

```jsx
<AuthProvider>
  <SidebarProvider>
    <Router>
      <Routes>
        ...
      </Routes>
    </Router>
  </SidebarProvider>
</AuthProvider>
```

Change it to wrap `LabNotificationProvider` around `<Router>`:

```jsx
<AuthProvider>
  <SidebarProvider>
    <LabNotificationProvider>
      <Router>
        <Routes>
          ...
        </Routes>
      </Router>
    </LabNotificationProvider>
  </SidebarProvider>
</AuthProvider>
```

### 6c — Add the new route

Find the existing lab routes block:

```jsx
{/* Laboratory */}
<Route path="/lab/queue" element={<LabQueue />} />
<Route path="/lab/processing/:id" element={<LabProcessing />} />
```

Add the new route immediately after:

```jsx
{/* Laboratory */}
<Route path="/lab/queue" element={<LabQueue />} />
<Route path="/lab/processing/:id" element={<LabProcessing />} />
<Route path="/lab/completed" element={<LabCompleted />} />
```

---

## Step 7 — Frontend: Update Navbar.jsx

**File:** `hms-frontend/src/components/Navbar.jsx`

Make four changes:

### 7a — Add imports at the top

Add `useNavigate` from react-router-dom, `useLabNotification` from the context, and `Bell` from lucide-react.

Find the existing imports (approximately the first 4 lines):

```jsx
import React, { useContext, useState, useEffect } from "react";
import { AuthContext } from "../context/AuthContext";
import { useSidebar } from "../context/SidebarContext";
import { Moon, Sun, LogOut, User, Menu, X, Maximize, Minimize } from "lucide-react";
```

Replace with:

```jsx
import React, { useContext, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../context/AuthContext";
import { useSidebar } from "../context/SidebarContext";
import { useLabNotification } from "../context/LabNotificationContext";
import { Moon, Sun, LogOut, User, Menu, X, Maximize, Minimize, Bell } from "lucide-react";
```

### 7b — Consume the context and add navigate

Find, inside the `Navbar` component function, the lines:

```jsx
const { user, logout } = useContext(AuthContext);
const { toggleMobileMenu } = useSidebar();
const [darkMode, setDarkMode] = useState(false);
```

Replace with:

```jsx
const { user, logout } = useContext(AuthContext);
const { toggleMobileMenu } = useSidebar();
const navigate = useNavigate();
const { labCompletedCount } = useLabNotification();
const [darkMode, setDarkMode] = useState(false);
```

### 7c — Add the bell button on DESKTOP (beside the fullscreen button)

In the **desktop** section (`hidden md:flex`), find the fullscreen button closing tag:

```jsx
              {isFullscreen ? <Minimize className="w-5 h-5" /> : <Maximize className="w-5 h-5" />}
            </button>

            {/* User info */}
```

Add the bell button between the fullscreen button and the user info section:

```jsx
              {isFullscreen ? <Minimize className="w-5 h-5" /> : <Maximize className="w-5 h-5" />}
            </button>

            {/* Lab Notification Bell — doctor & admin only */}
            {user && (user.role === 'doctor' || user.role === 'admin') && (
              <button
                onClick={() => navigate('/lab/completed')}
                className={`relative p-2 rounded-lg transition-all duration-300 transform hover:scale-110 ${
                  darkMode
                    ? 'bg-gray-800 hover:bg-gray-700 text-gray-300'
                    : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                }`}
                title="Lab Results Notifications"
              >
                <Bell className="w-5 h-5" />
                {labCompletedCount > 0 && (
                  <span className="absolute -top-1 -right-1 min-w-[18px] h-[18px] bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center px-1 shadow-md">
                    {labCompletedCount > 99 ? '99+' : labCompletedCount}
                  </span>
                )}
              </button>
            )}

            {/* User info */}
```

### 7d — Add the bell button on MOBILE too

In the **mobile** section (`md:hidden`), find the fullscreen button closing tag:

```jsx
              {isFullscreen ? <Minimize className="w-5 h-5" /> : <Maximize className="w-5 h-5" />}
            </button>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
```

Add the bell button between the fullscreen button and the mobile user menu button:

```jsx
              {isFullscreen ? <Minimize className="w-5 h-5" /> : <Maximize className="w-5 h-5" />}
            </button>

            {/* Lab Notification Bell (mobile) — doctor & admin only */}
            {user && (user.role === 'doctor' || user.role === 'admin') && (
              <button
                onClick={() => navigate('/lab/completed')}
                className={`relative p-2 rounded-lg transition-all ${
                  darkMode
                    ? 'bg-gray-800 hover:bg-gray-700 text-gray-300'
                    : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                }`}
                title="Lab Results Notifications"
              >
                <Bell className="w-5 h-5" />
                {labCompletedCount > 0 && (
                  <span className="absolute -top-1 -right-1 min-w-[18px] h-[18px] bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center px-1 shadow-md">
                    {labCompletedCount > 99 ? '99+' : labCompletedCount}
                  </span>
                )}
              </button>
            )}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
```

---

## Step 8 — Frontend: Update LabProcessing.jsx

**File:** `hms-frontend/src/pages/LabProcessing.jsx`

This makes the badge update **immediately** when a lab tech submits results, without needing a page refresh.

### 8a — Add import

Find the existing imports at the top. After the `DashboardLayout` import line, add:

```jsx
import { useLabNotification } from '../context/LabNotificationContext';
```

### 8b — Consume the context

Find, inside the `LabProcessing` component, the lines:

```jsx
const { id } = useParams();
const navigate = useNavigate();
const [request, setRequest] = useState(null);
```

Replace with:

```jsx
const { id } = useParams();
const navigate = useNavigate();
const { refreshLabCount } = useLabNotification();
const [request, setRequest] = useState(null);
```

### 8c — Call refreshLabCount after successful submit

Find, inside the `submitResults` function, the lines:

```jsx
alert('Results submitted successfully');
loadRequest();
```

Replace with:

```jsx
alert('Results submitted successfully');
loadRequest();

// Refresh the lab notification badge for doctors/admins
refreshLabCount();
```

---

## Step 9 — Frontend: Update Sidebar.jsx (initial count fetch)

**File:** `hms-frontend/src/components/Sidebar.jsx`

The Sidebar should trigger the initial count fetch on mount so the navbar bell is populated as soon as the user logs in.

### 9a — Add import

At the top of the file, after the existing context imports, add:

```jsx
import { useLabNotification } from "../context/LabNotificationContext";
```

### 9b — Consume refreshLabCount

Inside the `Sidebar` component, after the existing `role` line, add:

```jsx
const { refreshLabCount } = useLabNotification();
```

### 9c — Trigger the initial fetch on mount

After the existing `useEffect` for queue count, add a new `useEffect`:

```jsx
// Fetch lab notification count on mount (no polling — updates on action only)
useEffect(() => {
  refreshLabCount();
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, []);
```

---

## Summary of All File Changes

| # | File | Type | What Changed |
|---|------|------|--------------|
| 1 | `hms-backend/…/LabProcessingController.php` | MODIFY | Removed `'reviewed_at' => now()` from the all-completed block |
| 2 | `hms-backend/…/LabRequestController.php` | MODIFY | Added `notificationsCount()` and `markAsReviewed()` methods |
| 3 | `hms-backend/routes/api.php` | MODIFY | Added 2 new routes: GET `/lab/notifications/count` and POST `/lab/requests/{id}/review` |
| 4 | `hms-frontend/src/context/LabNotificationContext.jsx` | **NEW** | React context holding `labCompletedCount` and `refreshLabCount()` |
| 5 | `hms-frontend/src/pages/LabCompleted.jsx` | **NEW** | Page listing unreviewed completed tests with "View Patient" + "Mark Reviewed" buttons |
| 6 | `hms-frontend/src/main.jsx` | MODIFY | Added `LabNotificationProvider` wrapper + `LabCompleted` import + `/lab/completed` route |
| 7 | `hms-frontend/src/components/Navbar.jsx` | MODIFY | Added bell icon button with red badge (desktop + mobile), visible to doctor and admin only |
| 8 | `hms-frontend/src/pages/LabProcessing.jsx` | MODIFY | Calls `refreshLabCount()` after successfully submitting test results |
| 9 | `hms-frontend/src/components/Sidebar.jsx` | MODIFY | Calls `refreshLabCount()` on mount to initialize the badge count |

---

## Verification Checklist

After implementing:

- [ ] Login as **lab technician** → open a pending lab request → submit all test results
- [ ] The request status becomes `completed` and `reviewed_at` stays `NULL` in the database
- [ ] Login as **doctor** → the `Bell` icon in the navbar shows a red badge with count `1`
- [ ] Login as **admin** → the `Bell` icon also shows the badge
- [ ] Click the bell → navigates to `/lab/completed`
- [ ] The completed test appears in the table with patient name, UPID, doctor, and tests
- [ ] Click **"View Patient →"** → navigates to `/patients/:id` (the patient details page)
- [ ] Click **"Mark Reviewed"** → the row disappears from the list and the badge decrements
- [ ] Badge reaches `0` when all requests are reviewed → bell icon shows no badge
