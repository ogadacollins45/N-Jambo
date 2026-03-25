<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bills', function (Blueprint $table) {
            $table->foreignId('admission_id')->nullable()->after('treatment_id')
                  ->constrained('admissions')->nullOnDelete();
            $table->enum('bill_type', ['outpatient', 'inpatient'])->default('outpatient')->after('admission_id');
        });
    }

    public function down(): void
    {
        Schema::table('bills', function (Blueprint $table) {
            $table->dropForeign(['admission_id']);
            $table->dropColumn(['admission_id', 'bill_type']);
        });
    }
};
