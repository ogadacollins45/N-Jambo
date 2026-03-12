<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LabSample extends Model
{
    use HasFactory;

    protected $fillable = [
        'lab_request_id',
        'sample_number',
        'sample_type',
        'collection_date',
        'collected_by',
        'volume',
        'container_type',
        'storage_location',
        'status',
        'rejection_reason',
    ];

    protected $casts = [
        'collection_date' => 'datetime',
    ];

    // Relationships
    public function labRequest()
    {
        return $this->belongsTo(LabRequest::class, 'lab_request_id');
    }

    public function collectedBy()
    {
        return $this->belongsTo(Staff::class, 'collected_by');
    }

    // Helper to generate sample number
    public static function generateSampleNumber()
    {
        $date = now()->format('Ymd');
        $prefix = "SMP-{$date}-";

        // Find the highest sequence already used today to avoid reusing numbers
        // when records have been deleted (count-based approach would re-issue used numbers).
        $last = static::where('sample_number', 'like', $prefix . '%')
            ->orderByRaw('CAST(SUBSTRING(sample_number, ?) AS UNSIGNED) DESC', [strlen($prefix) + 1])
            ->value('sample_number');

        $next = $last ? ((int) substr($last, strlen($prefix))) + 1 : 1;

        // Retry loop: in case of concurrent inserts, keep incrementing until unique.
        $candidate = $prefix . str_pad($next, 5, '0', STR_PAD_LEFT);
        while (static::where('sample_number', $candidate)->exists()) {
            $next++;
            $candidate = $prefix . str_pad($next, 5, '0', STR_PAD_LEFT);
        }

        return $candidate;
    }
}
