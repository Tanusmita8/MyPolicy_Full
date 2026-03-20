package com.mypolicy.implementation.service;

import com.mypolicy.implementation.model.StandardizedRecord;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

@Service
public class PipelineOrchestratorService {

    private final MetadataIngestionService metadataIngestionService;
    private final StitchingService stitchingService;
    private final FileProcessingService fileProcessingService;

    public PipelineOrchestratorService(MetadataIngestionService metadataIngestionService,
                                      StitchingService stitchingService,
                                      FileProcessingService fileProcessingService) {
        this.metadataIngestionService = metadataIngestionService;
        this.stitchingService = stitchingService;
        this.fileProcessingService = fileProcessingService;
    }

    public StitchingService.StitchingResult runFullPipeline() {
        Map<String, List<StandardizedRecord>> standardized = metadataIngestionService.standardizeAllPolicies();
        List<StandardizedRecord> allPolicies = standardized.values().stream()
                .flatMap(List::stream)
                .toList();
        return stitchingService.stitchPolicies(allPolicies);
    }

    /**
     * Accepts an uploaded CSV or XLSX file and collection name. Parses the file, ingests into MongoDB,
     * then triggers full standardization and stitching.
     */
    public StitchingService.StitchingResult uploadAndProcess(MultipartFile file, String collectionName) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is empty or null");
        }
        String originalFilename = file.getOriginalFilename() != null ? file.getOriginalFilename().toLowerCase() : "";
        StitchingService.StitchingResult result = uploadAndProcessStream(file.getInputStream(), originalFilename, collectionName);
        return result;
    }

    public StitchingService.StitchingResult uploadAndProcessStream(InputStream inputStream,
                                                                   String originalFilename,
                                                                   String collectionName) throws IOException {
        List<Map<String, Object>> rows;
        if (originalFilename != null && originalFilename.endsWith(".xlsx")) {
            rows = fileProcessingService.parseXlsx(inputStream);
        } else {
            rows = fileProcessingService.parseCsv(inputStream);
        }

        // Drop completely empty data rows (e.g. trailing blank line) but do NOT fail the job.
        rows.removeIf(row -> row.values().stream()
                .allMatch(v -> v == null || v.toString().trim().isEmpty()));

        if (rows.isEmpty()) {
            throw new IllegalArgumentException("Uploaded file has no data rows");
        }
        List<String> insertedIds = metadataIngestionService.ingestRecords(collectionName, rows);
        List<StandardizedRecord> allPolicies = metadataIngestionService.standardizeAllPolicies().values().stream()
                .flatMap(List::stream)
                .toList();
        stitchingService.stitchPolicies(allPolicies);
        List<StandardizedRecord> uploadBatch = metadataIngestionService.standardizeByIds(collectionName, insertedIds);
        return stitchingService.computeStitchingStats(uploadBatch);
    }
}
