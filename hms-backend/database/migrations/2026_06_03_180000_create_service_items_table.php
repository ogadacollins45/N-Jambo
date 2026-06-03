<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Creates the service_items table for admin-configurable billable
     * procedures and extra items (e.g., Wound Dressing, X-Ray, etc.)
     */
    public function up(): void
    {
        Schema::create('service_items', function (Blueprint $table) {
            $table->id();

            $table->string('name');                        // e.g. "Wound Dressing"
            $table->text('description')->nullable();       // optional description
            $table->decimal('price', 10, 2);               // unit price set by admin
            $table->boolean('is_active')->default(true);   // admin can disable items

            $table->timestamps();

            $table->index(['is_active', 'name']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_items');
    }
};
