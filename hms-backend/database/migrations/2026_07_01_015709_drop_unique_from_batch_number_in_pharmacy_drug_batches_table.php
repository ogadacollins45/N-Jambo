<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('pharmacy_drug_batches', function (Blueprint $table) {
            $table->dropUnique('pharmacy_drug_batches_batch_number_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pharmacy_drug_batches', function (Blueprint $table) {
            $table->unique('batch_number', 'pharmacy_drug_batches_batch_number_unique');
        });
    }
};
