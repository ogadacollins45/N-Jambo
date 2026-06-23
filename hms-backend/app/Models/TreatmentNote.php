<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Staff;

class TreatmentNote extends Model
{
    protected $fillable = [
        'admission_id',
        'user_id',
        'type',
        'medication',
        'dosage',
        'route',
        'directions',
        'frequency',
        'status',
    ];

    public function admission()
    {
        return $this->belongsTo(Admission::class);
    }

    public function user()
    {
        return $this->belongsTo(Staff::class, 'user_id');
    }
}
