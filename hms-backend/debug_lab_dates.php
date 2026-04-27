<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\LabResult;
use App\Models\LabRequest;
use Illuminate\Support\Facades\DB;

echo "=== Lab Data Date Range Debug ===\n\n";

// Check what months have lab requests
$reqByMonth = DB::table('lab_requests')
    ->selectRaw("DATE_FORMAT(request_date, '%Y-%m') as month, COUNT(*) as count, MIN(request_date) as earliest, MAX(request_date) as latest")
    ->whereNotIn('status', ['rejected','cancelled'])
    ->groupByRaw("DATE_FORMAT(request_date, '%Y-%m')")
    ->orderBy('month', 'desc')
    ->limit(12)
    ->get();

echo "--- Lab Requests by Month ---\n";
foreach ($reqByMonth as $row) {
    echo "  {$row->month}: {$row->count} requests  ({$row->earliest} to {$row->latest})\n";
}

// Check what months have lab results
$resByMonth = DB::table('lab_results')
    ->join('lab_requests', 'lab_results.lab_request_id', '=', 'lab_requests.id')
    ->selectRaw("DATE_FORMAT(lab_requests.request_date, '%Y-%m') as month, COUNT(*) as count")
    ->whereIn('lab_results.status', ['submitted','verified'])
    ->whereNotIn('lab_requests.status', ['rejected','cancelled'])
    ->groupByRaw("DATE_FORMAT(lab_requests.request_date, '%Y-%m')")
    ->orderBy('month', 'desc')
    ->limit(12)
    ->get();

echo "\n--- Lab Results (submitted/verified) by Month ---\n";
foreach ($resByMonth as $row) {
    echo "  {$row->month}: {$row->count} results\n";
}

// Check the lab_results table created_at to see if recent ones are there
echo "\n--- Recent lab_results by created_at (last 10) ---\n";
$recent = DB::table('lab_results')
    ->orderBy('created_at', 'desc')
    ->limit(10)
    ->get(['id','lab_request_id','status','created_at','updated_at']);
foreach ($recent as $r) {
    echo "  ID {$r->id} | req_id {$r->lab_request_id} | status: {$r->status} | created: {$r->created_at}\n";
}

// Check recent lab_requests
echo "\n--- Recent lab_requests by request_date (last 10) ---\n";
$recentReqs = DB::table('lab_requests')
    ->orderBy('request_date', 'desc')
    ->limit(10)
    ->get(['id','status','request_date','created_at']);
foreach ($recentReqs as $r) {
    echo "  ID {$r->id} | status: {$r->status} | request_date: {$r->request_date} | created: {$r->created_at}\n";
}

// Check if created_at vs request_date differs for April
echo "\n--- Lab requests created in April 2026 (by created_at) ---\n";
$createdInApril = DB::table('lab_requests')
    ->whereYear('created_at', 2026)
    ->whereMonth('created_at', 4)
    ->orderBy('created_at', 'desc')
    ->limit(20)
    ->get(['id','status','request_date','created_at']);
echo "Count: " . $createdInApril->count() . "\n";
foreach ($createdInApril as $r) {
    echo "  ID {$r->id} | status: {$r->status} | request_date: {$r->request_date} | created_at: {$r->created_at}\n";
}

echo "\nDone.\n";
