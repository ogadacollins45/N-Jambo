<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LabRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'request_number',
        'patient_id',
        'doctor_id',
        'treatment_id',
        'visit_id',
        'priority',
        'clinical_notes',
        'request_date',
        'status',
        'lab_technician_id',
        'reviewed_by',
        'reviewed_at',
    ];

    protected $casts = [
        'request_date' => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    // Relationships
    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function doctor()
    {
        return $this->belongsTo(Staff::class, 'doctor_id');
    }

    public function treatment()
    {
        return $this->belongsTo(Treatment::class);
    }

    public function labTechnician()
    {
        return $this->belongsTo(Staff::class, 'lab_technician_id');
    }

    public function reviewedBy()
    {
        return $this->belongsTo(Staff::class, 'reviewed_by');
    }

    public function tests()
    {
        return $this->hasMany(LabRequestTest::class, 'lab_request_id');
    }

    public function samples()
    {
        return $this->hasMany(LabSample::class, 'lab_request_id');
    }

    public function results()
    {
        return $this->hasMany(LabResult::class, 'lab_request_id');
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    // Helper to generate request number
    public static function generateRequestNumber()
    {
        $date = now()->format('Ymd');
        $prefix = "LAB-{$date}-";

        // Find the highest sequence already used today to avoid reusing numbers
        // when records have been deleted (count-based approach would re-issue used numbers).
        $last = static::where('request_number', 'like', $prefix . '%')
            ->orderByRaw('CAST(SUBSTRING(request_number, ?) AS UNSIGNED) DESC', [strlen($prefix) + 1])
            ->value('request_number');

        $next = $last ? ((int) substr($last, strlen($prefix))) + 1 : 1;

        // Retry loop: in case of concurrent inserts, keep incrementing until unique.
        $candidate = $prefix . str_pad($next, 4, '0', STR_PAD_LEFT);
        while (static::where('request_number', $candidate)->exists()) {
            $next++;
            $candidate = $prefix . str_pad($next, 4, '0', STR_PAD_LEFT);
        }

        return $candidate;
    }
}
