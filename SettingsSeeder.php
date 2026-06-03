<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\Setting::setSetting(
            'consultation_fee',
            3.00,
            'number',
            'Default consultation fee for patient visits'
        );

        \App\Models\Setting::setSetting(
            'prescription_duplicate_limit_days',
            5,
            'number',
            'Limit in days before the same drug can be prescribed again to a patient without admin override'
        );
    }
}
