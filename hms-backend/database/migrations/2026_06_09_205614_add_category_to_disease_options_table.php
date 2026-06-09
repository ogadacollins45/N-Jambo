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
        Schema::table('disease_options', function (Blueprint $table) {
            $table->foreignId('disease_category_id')->nullable()->constrained('disease_categories')->nullOnDelete();
            $table->foreignId('disease_subcategory_id')->nullable()->constrained('disease_subcategories')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('disease_options', function (Blueprint $table) {
            $table->dropForeign(['disease_category_id']);
            $table->dropForeign(['disease_subcategory_id']);
            $table->dropColumn(['disease_category_id', 'disease_subcategory_id']);
        });
    }
};
