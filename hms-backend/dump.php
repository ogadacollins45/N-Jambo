<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$request = \Illuminate\Http\Request::create('/api/report/moh706', 'GET', ['month' => 3, 'year' => 2026]);
$response = app(\App\Http\Controllers\ReportController::class)->getMoh706($request);
file_put_contents('payload.json', $response->content());
echo "Done";
