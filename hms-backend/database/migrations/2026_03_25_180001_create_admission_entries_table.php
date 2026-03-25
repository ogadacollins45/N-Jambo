<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('admission_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admission_id')->constrained('admissions')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('staff')->nullOnDelete();
            $table->string('bp', 20)->nullable();
            $table->string('pulse', 20)->nullable();
            $table->string('temp', 20)->nullable();
            $table->string('spo2', 20)->nullable();
            $table->text('note')->nullable();
            $table->timestamp('recorded_at')->nullable();
            $table->timestamps();

            $table->index('admission_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admission_entries');
    }
};
