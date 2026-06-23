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
        Schema::table('treatment_notes', function (Blueprint $table) {
            $table->string('medication')->nullable()->after('type');
            $table->string('dosage')->nullable()->after('medication');
            $table->string('route')->nullable()->after('dosage');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('treatment_notes', function (Blueprint $table) {
            $table->dropColumn(['medication', 'dosage', 'route']);
        });
    }
};
