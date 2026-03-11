<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Add age_years, age_months, age_days as separate integer columns.
     * The old 'age' column is left untouched for backwards compatibility.
     * Months and days default to 0; all are nullable so legacy records work.
     */
    public function up()
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->unsignedSmallInteger('age_years')->default(0)->nullable()->after('age');
            $table->unsignedTinyInteger('age_months')->default(0)->nullable()->after('age_years');
            $table->unsignedTinyInteger('age_days')->default(0)->nullable()->after('age_months');
        });
    }

    public function down()
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->dropColumn(['age_years', 'age_months', 'age_days']);
        });
    }
};
