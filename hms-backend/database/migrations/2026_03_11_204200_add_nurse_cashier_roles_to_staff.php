<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE staff MODIFY COLUMN role ENUM('admin','doctor','reception','pharmacist','labtech','facility_clerk','nurse','cashier') DEFAULT 'doctor'");
    }

    public function down(): void
    {
        // Revert to previous set (without nurse/cashier)
        DB::statement("ALTER TABLE staff MODIFY COLUMN role ENUM('admin','doctor','reception','pharmacist','labtech','facility_clerk') DEFAULT 'doctor'");
    }
};
