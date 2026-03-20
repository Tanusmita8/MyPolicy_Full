package com.mypolicy.implementation.model;

/**
 * Upload path: stitching counts for this file's new rows only, plus ingestion stats.
 */
public record UploadPipelineResult(
        int totalProcessed,
        int matched,
        int unmatched,
        int dataRowsInFile,
        int insertedCount,
        int skippedDuplicates,
        int failedValidationCount,
        String message
) {
}
