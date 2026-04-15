<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Patient;
use App\Models\LabTestCategory;
use App\Models\LabTestTemplate;
use App\Models\LabTestParameter;
use App\Models\LabRequest;
use App\Models\LabRequestTest;
use App\Models\LabResult;
use App\Models\LabResultParameter;
use Carbon\Carbon;

class Moh706Section9Seeder extends Seeder
{
    public function run(): void
    {
        $doctor = User::first();
        $patients = Patient::inRandomOrder()->take(5)->get();
        if ($patients->isEmpty()) {
            $this->command->warn('No patients found! Please run PatientSeeder first.');
            return;
        }

        $microbiology = LabTestCategory::firstOrCreate(
            ['code' => 'MICRO'],
            [
                'name' => 'Microbiology',
                'description' => 'Microbiological analysis',
                'is_active' => true,
            ]
        );

        // Define Section 9 test templates (organisms)
        $organisms = [
            'Culture - E. coli O157:H7' => 'Gram-negative bacteria culture',
            'Culture - Proteus' => 'Gram-negative bacteria culture',
            'Culture - Staphylococcus aureus' => 'Gram-positive bacteria culture',
            'Culture - Pseudomonas aeruginosa' => 'Gram-negative bacteria culture',
        ];

        // Ensure these templates and their parameters exist
        $templates = [];
        foreach ($organisms as $name => $desc) {
            $template = LabTestTemplate::firstOrCreate(
                ['code' => 'ORG_' . strtoupper(substr(md5($name), 0, 8))],
                [
                    'category_id' => $microbiology->id,
                    'name' => $name,
                    'description' => $desc,
                    'sample_type' => 'other',
                    'is_active' => true,
                    'price' => 1000,
                ]
            );

            // Add standard antibiotics as parameters if not exists
            $antibiotics = [
                'Ciprofloxacin',
                'Levofloxacin',
                'Gentamicin',
                'Ceftazidime',
                'Amikacin'
            ];

            foreach ($antibiotics as $idx => $anti) {
                LabTestParameter::firstOrCreate(
                    [
                        'test_template_id' => $template->id,
                        'name' => $anti,
                    ],
                    [
                        'code' => strtoupper(substr($anti, 0, 4)),
                        'unit' => 'Susceptibility',
                        'sort_order' => $idx + 1,
                    ]
                );
            }

            $templates[] = $template;
        }

        // Target March of the current year so it aligns with user's data
        $targetDate = Carbon::create(now()->year, 3, 15);

        // Generate Dummy Results
        $this->command->info("Seeding Section 9 lab results for " . $targetDate->format('F Y') . "...");

        foreach ($templates as $template) {
            // Pick a random patient
            $patient = $patients->random();

            // Create Request
            $request = LabRequest::create([
                'request_number' => 'REQ-S9-' . rand(100000, 999999),
                'patient_id' => $patient->id,
                'doctor_id' => $doctor->id ?? null,
                'status' => 'completed',
                'priority' => 'Routine',
                'request_date' => $targetDate->copy()->addDays(rand(1, 10)),
                'clinical_notes' => 'Seeded by Moh706Section9Seeder: Culture evaluation required',
            ]);

            // Request Test
            $reqTest = LabRequestTest::create([
                'lab_request_id' => $request->id,
                'test_template_id' => $template->id,
            ]);

            // Create Result
            $result = LabResult::create([
                'lab_request_id' => $request->id,
                'lab_request_test_id' => $reqTest->id,
                'test_template_id' => $template->id,
                'performed_by' => $doctor->id ?? null,
                'verified_by' => $doctor->id ?? null,
                'status' => 'verified',
                'overall_comment' => 'Susceptibility findings noted',
                'performed_at' => $request->request_date->copy()->addDays(2),
                'verified_at' => $request->request_date->copy()->addDays(2),
            ]);

            // Result Parameters (Set some to 'Resistant' to trigger S9 matrix)
            $params = $template->parameters;
            foreach ($params as $param) {
                // Randomly set ~50% to resistant, 50% to sensitive
                $isResistant = rand(0, 1) == 1;
                $val = $isResistant ? 'Resistant' : 'Sensitive';

                LabResultParameter::create([
                    'lab_result_id' => $result->id,
                    'parameter_id' => $param->id,
                    'value' => $val,
                ]);
            }
        }

        $this->command->info("Section 9 dummy seed completed successfully.");
    }
}
