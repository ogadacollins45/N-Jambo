# AI Agent Optimization Guide: High-Performance Laravel + React Implementation

This document serves as an instruction manual for an AI agent operating in a similar Laravel + React (or generic full-stack) codebase. The goal is to optimize a system that is currently consuming excessive server resources (vCPU/RAM) and slow network loads due to unoptimized queries and heavy client-side fetching.

**Context:** The codebase this was derived from had endpoints (like `PatientController`) and React views (`PatientDetails.jsx`) that were extremely heavy. The following strategies reduced initial load times and slashed server resource consumption. Please implement these equivalent strategies in your target codebase.

## 1. Eliminate PHP-Level Filtering (Push Logic to SQL)
**The Problem:** The system was fetching entire tables with heavy relationships into memory, then using language-level functions (e.g., PHP `foreach` or Collection `filter()`) to find records matching a condition (e.g., "patients with incomplete lab tests").
**The Solution:**
- Rewrite these endpoints to use pure SQL logic (e.g., Eloquent's `whereHas`, `whereDoesntHave`, nested closures).
- **Rule:** The database engine MUST handle all filtering using indexes. Only the exact, paginated matching rows should ever touch application memory.

## 2. Implement Payload Trimming via `select()`
**The Problem:** Queries like `Model::with('relationship')->paginate()` pull every column from the database. Text fields (like `history_presenting_illness`, `notes`, `JSON blobs`) are unnecessarily sent over the network when the UI only displays a summary table or collapsed card.
**The Solution:**
- Explicitly trim queries using `->select(['id', 'name', 'status', ...])`.
- Apply this to eager-loaded relationships as well: `with('doctor:id,first_name,last_name')`.
- **Rule:** Never fetch or send a column that the immediate UI view does not render.

## 3. Server-Side Pagination Over Client-Side
**The Problem:** The frontend fetches all historical records (e.g., a patient's entire treatment history) at once and paginates them using Javascript (e.g., `Array.prototype.slice()`). For entities with dozens or hundreds of related records, this causes massive initial payloads.
**The Solution:**
- Convert the backend endpoint to return a `paginate(10)` response.
- Update the frontend to track `currentPage` and request data from the server sequentially.
- **Rule:** If a list can grow unbounded over time, it MUST be server-paginated.

## 4. Extreme Lazy-Loading (Frontend UI & Backend Details)
**The Problem:** A complex details page makes 7+ heavy API calls concurrently on mount, fetching data for tabs, modals, and dropdowns (like all available lab tests, doctors, or deleted history) that the user might never interact with.
**The Solution:**
- **Initial Load:** Make only the absolute minimum API calls needed to render the primary view (e.g., basic info and active status).
- **Tabs:** Implement lazy-load flags. When a user clicks a hidden tab (e.g., "Lab Results"), fetch the data *then*. Use a clean `Loader` animation (`<Loader animate-spin />`) in the UI to indicate fetching.
- **Forms/Modals:** Fetch massive reference lists (like all available doctors or tests) ONLY when the user clicks the button to open that specific form.
- **Detail Expansion:** For complex items (like a Treatment Card), the paginated list should only contain lean summary data. When the user clicks to "Expand" the card, fire a separate `GET /resource/{id}` API call to fetch the heavy text fields and nested relationships.
- **Rule:** Defer all secondary data fetching until explicit user interaction (click/expand).

## Summary for the Implementing Agent
When analyzing your target codebase, immediately search for:
1. `->get()` calls without limits on tables that grow over time.
2. Collection-level aggregations (`$collection->filter()`, `$collection->count()`). Replace them with SQL `COUNT()`, `SUM()`.
3. Fat relationships loaded without specific columns.
4. React `useEffect` hooks that fire massive `Promise.all` requests on mount for hidden UI elements.

Apply these patterns surgically. Good luck!
