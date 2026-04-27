<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Services\LabTestMapper;
use App\Http\Controllers\ReportController;
use Illuminate\Http\Request;

echo "=== MOH 706 Section 1 Fix Verification ===\n\n";

// 1. Check that 'Urinalysis' still maps to 1.1
$code = LabTestMapper::map('Urinalysis');
echo "LabTestMapper::map('Urinalysis') = '$code'\n";
echo "Is 1.1 in allCodes: " . (in_array('1.1', LabTestMapper::allCodes()) ? 'YES ✓' : 'NO ✗') . "\n\n";

// 2. Simulate what the controller does — build codeIndex and check 1.1 is in it
$controller = new ReportController();
$method = new ReflectionMethod(ReportController::class, 'initMoh706Structure');
$method->setAccessible(true);
$sections = $method->invoke($controller);

// Build codeIndex
$codeIndex = [];
foreach ($sections as $sNum => $section) {
    foreach ($section['subsections'] as $subIdx => $sub) {
        foreach ($sub['rows'] as $rowIdx => $row) {
            $codeIndex[$row['code']] = [$sNum, $subIdx, $rowIdx];
        }
    }
}

echo "Section 1 row codes in codeIndex: ";
$s1Codes = array_keys(array_filter($codeIndex, fn($v) => $v[0] === '1'));
echo implode(', ', $s1Codes) . "\n";

echo "Is '1.1' in codeIndex: " . (isset($codeIndex['1.1']) ? 'YES ✓' : 'NO ✗') . "\n\n";

// 3. Actually call the report endpoint for April
echo "=== Running full MOH 706 for April 2026 ===\n";
$request = Request::create('/api/reports/moh-706?month=4&year=2026');
$method2 = new ReflectionMethod(ReportController::class, 'getMoh706');
$method2->setAccessible(true);
$response = $method2->invoke($controller, $request);
$data = json_decode($response->getContent(), true);

$s1 = $data['sections']['1'] ?? null;
if (!$s1) {
    echo "Section 1 not found in response!\n";
    exit(1);
}

echo "Section 1 title: {$s1['title']}\n";
foreach ($s1['subsections'] as $sub) {
    echo "\n  Subsection [{$sub['code']}] {$sub['title']}:\n";
    foreach ($sub['rows'] as $row) {
        $totalExam = $row['total_exam'] ?? 0;
        $numPos    = $row['number_positive'] ?? 0;
        $patients  = count($row['patients'] ?? []);
        echo "    [{$row['code']}] {$row['label']}: total_exam=$totalExam, number_positive=$numPos, patients=$patients\n";
    }
}

echo "\nDone.\n";
