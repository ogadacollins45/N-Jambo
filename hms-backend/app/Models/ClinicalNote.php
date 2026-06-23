<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Staff;

class ClinicalNote extends Model
{
    protected $fillable = [
        'admission_id',
        'user_id',
        'chief_complaint',
        'general_exam',
        'systemic_exam',
        'diagnosis',
        'plan_notes',
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
