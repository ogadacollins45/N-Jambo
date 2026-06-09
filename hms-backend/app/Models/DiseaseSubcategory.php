<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiseaseSubcategory extends Model
{
    use HasFactory;

    protected $fillable = ['disease_category_id', 'name', 'description'];

    public function category()
    {
        return $this->belongsTo(DiseaseCategory::class, 'disease_category_id');
    }
}
