<?php

namespace App\Observers;

use App\Models\LabRequest;
use App\Services\BillingService;
use Illuminate\Support\Facades\Log;

class LabRequestObserver
{
    /**
     * Handle the LabRequest "updated" event.
     * Automatically update the bill when lab tests are COMPLETED (results submitted)
     */
    public function updated(LabRequest $labRequest): void
    {
        // Only trigger billing when status changes to 'completed'
        if ($labRequest->isDirty('status') && $labRequest->status === 'completed') {
            Log::info("LabRequestObserver: Lab request #{$labRequest->id} completed - adding to bill");

            try {
                if (!$labRequest->treatment_id && !$labRequest->admission_id) {
                    Log::warning("LabRequestObserver: No treatment or admission found for lab request #{$labRequest->id}");
                    return;
                }

                $billingService = app(BillingService::class);

                if ($labRequest->treatment_id) {
                    $bill = $billingService->getOrCreateBillForTreatment($labRequest->treatment_id);
                    // Add consultation fee for outpatients
                    $billingService->addConsultationFee($bill);
                } else {
                    // For admissions, bill must already exist
                    $bill = \App\Models\Bill::where('admission_id', $labRequest->admission_id)->first();
                    if (!$bill) {
                        Log::error("LabRequestObserver: Missing bill for admission_id {$labRequest->admission_id}");
                        return;
                    }
                }

                // Add the lab test items
                $billingService->addLabTestItems($bill, $labRequest);

                // Recalculate totals
                $billingService->recalculateBill($bill);

                Log::info("LabRequestObserver: Successfully updated bill #{$bill->id} for completed lab request #{$labRequest->id}");
            } catch (\Exception $e) {
                Log::error("LabRequestObserver: Failed to update bill for lab request #{$labRequest->id}: " . $e->getMessage());
            }
        }
    }

    /**
     * Handle the LabRequest "deleted" event.
     * Remove items from bill if lab request is cancelled
     */
    public function deleted(LabRequest $labRequest): void
    {
        Log::info("LabRequestObserver: Lab request #{$labRequest->id} deleted");

        try {
            if (!$labRequest->treatment_id && !$labRequest->admission_id) {
                return;
            }

            $billingService = app(BillingService::class);

            if ($labRequest->treatment_id) {
                $bill = $billingService->getOrCreateBillForTreatment($labRequest->treatment_id);
            } else {
                $bill = \App\Models\Bill::where('admission_id', $labRequest->admission_id)->first();
                if (!$bill) return;
            }

            $billingService->removeLabRequestItems($bill, $labRequest);

            Log::info("LabRequestObserver: Successfully removed items from bill #{$bill->id}");
        } catch (\Exception $e) {
            Log::error("LabRequestObserver: Failed to remove items from bill: " . $e->getMessage());
        }
    }
}
