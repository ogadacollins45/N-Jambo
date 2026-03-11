<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Patient extends Model
{
    use HasFactory;

    protected $fillable = [
        'upid',
        'first_name',
        'last_name',
        'gender',
        'dob',
        'age',
        'age_years',
        'age_months',
        'age_days',
        'phone',
        'email',
        'address',
        'national_id',
        
        // NEW MOH fields (all nullable)
        'county',
        'sub_county',
        'ward',
        'village',
        'next_of_kin',
        'next_of_kin_phone',
        'pregnancy_status',
        'has_disability',
        'disability_type',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'has_disability' => 'boolean',
    ];

    // A patient has many treatments
    public function treatments()
    {
        return $this->hasMany(Treatment::class);
    }

    // A patient has many appointments
    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    // 🔹 A patient has many bills (for receipts sidebar / history)
    public function bills()
    {
        return $this->hasMany(Bill::class)->orderByDesc('created_at');
    }

    // Auto-generate UPID like NJ-0001, NJ-0002...
    protected static function booted()
    {
        static::creating(function ($patient) {
            if (empty($patient->upid)) {
                // Get last patient's UPID numeric part (if exists) — check NJ- first, fall back to legacy BH-
                $lastPatient = self::where('upid', 'LIKE', 'NJ-%')
                    ->orderByDesc('id')
                    ->first();

                if (!$lastPatient) {
                    $lastPatient = self::where('upid', 'LIKE', 'BH-%')
                        ->orderByDesc('id')
                        ->first();
                }

                // Extract the numeric part and increment
                $nextNumber = 1;
                if ($lastPatient && preg_match('/(?:NJ|BH)-(\d+)/', $lastPatient->upid, $matches)) {
                    $nextNumber = (int) $matches[1] + 1;
                }

                // Format to NJ-0001 style (4 digits, auto-expands beyond 9999)
                $patient->upid = 'NJ-' . str_pad($nextNumber, 4, '0', STR_PAD_LEFT);
            }
            
            // Auto-set created_by
            if (auth()->check()) {
                $patient->created_by = auth()->id();
            }
        });

        static::updating(function ($patient) {
            // Auto-set updated_by
            if (auth()->check()) {
                $patient->updated_by = auth()->id();
            }
        });
    }

    /*
    |--------------------------------------------------------------------------
    | MOH Helper Methods
    |--------------------------------------------------------------------------
    */

    // Get age group attribute for MOH reporting (uses age_years preferentially)
    public function getAgeGroupAttribute()
    {
        $years = $this->age_years ?? $this->age;
        if ($years === null) return null;

        if ($years < 1) return '<1';
        if ($years <= 4) return '1-4';
        if ($years <= 14) return '5-14';
        if ($years <= 49) return '15-49';
        return '50+';
    }

    // Check if reproductive age female (for pregnancy status)
    public function isReproductiveAgeFemale()
    {
        $years = $this->age_years ?? $this->age;
        return $this->gender === 'F' && $years >= 10 && $years <= 49;
    }
}
