<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdmissionEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'admission_id',
        'user_id',
        'bp',
        'pulse',
        'temp',
        'spo2',
        'note',
        'recorded_at',
    ];

    protected $casts = [
        'recorded_at' => 'datetime',
    ];

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    public function admission()
    {
        return $this->belongsTo(Admission::class);
    }

    public function user()
    {
        return $this->belongsTo(Staff::class, 'user_id');
    }

    /*
    |--------------------------------------------------------------------------
    | Booted
    |--------------------------------------------------------------------------
    */

    protected static function booted()
    {
        static::creating(function ($entry) {
            if (empty($entry->recorded_at)) {
                $entry->recorded_at = now();
            }
            // Link to the authenticated staff member
            if (empty($entry->user_id) && auth()->check()) {
                $entry->user_id = auth()->id();
            }
        });
    }
}
