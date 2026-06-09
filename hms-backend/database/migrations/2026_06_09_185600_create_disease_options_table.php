<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('disease_options', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->boolean('is_custom')->default(false);
            $table->timestamps();
        });

        // Port over existing custom diagnoses from system_diagnoses if they exist
        if (Schema::hasTable('system_diagnoses')) {
            $oldDiagnoses = \Illuminate\Support\Facades\DB::table('system_diagnoses')->get();
            foreach ($oldDiagnoses as $diagnosis) {
                \Illuminate\Support\Facades\DB::table('disease_options')->insertOrIgnore([
                    'name' => $diagnosis->name,
                    'is_custom' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // Seed base diseases
        $baseLabels = array_values(\App\Services\DiseaseMapper::labels());
        if (!in_array('All Other Diseases', $baseLabels)) {
            $baseLabels[] = 'All Other Diseases';
        }

        foreach ($baseLabels as $label) {
            \Illuminate\Support\Facades\DB::table('disease_options')->insertOrIgnore([
                'name' => $label,
                'is_custom' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('disease_options');
    }
};
