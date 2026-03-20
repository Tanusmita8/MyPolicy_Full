package com.mypolicy.implementation.service;

import com.mypolicy.implementation.config.MappingConfig;
import com.mypolicy.implementation.model.FailedLogRecord;
import com.mypolicy.implementation.model.StandardizedRecord;
import com.mypolicy.implementation.repository.FailedLogRepository;
import com.mypolicy.implementation.util.DataMassagingUtil;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Generic Metadata-Driven Ingestion. Uses mapping config to standardize records
 * from any insurer collection without hard-coding field names.
 */
@Service
public class MetadataIngestionService {

    private static final Logger log = LoggerFactory.getLogger(MetadataIngestionService.class);

    private final MongoTemplate mongoTemplate;
    private final MappingConfig mappingConfig;
    private final AuditLogger auditLogger;
    private final DownstreamRetryExecutor downstreamRetryExecutor;
    private final FailedLogRepository failedLogRepository;

    public MetadataIngestionService(MongoTemplate mongoTemplate,
                                    MappingConfig mappingConfig,
                                    AuditLogger auditLogger,
                                    DownstreamRetryExecutor downstreamRetryExecutor,
                                    FailedLogRepository failedLogRepository) {
        this.mongoTemplate = mongoTemplate;
        this.mappingConfig = mappingConfig;
        this.auditLogger = auditLogger;
        this.downstreamRetryExecutor = downstreamRetryExecutor;
        this.failedLogRepository = failedLogRepository;
    }

    private static final List<String> POLICY_COLLECTIONS = List.of(
            "life_insurance", "auto_insurance", "health_insurance"
    );

    /**
     * Canonical fields whose <em>source</em> column names differ per product line (unlike PAN/Mobile/Email).
     * Used to detect when the uploaded file matches a different collection than the one selected.
     */
    private static final List<String> PRODUCT_SIGNATURE_KEYS = List.of(
            "policy_id", "premium", "start_date", "policy_end", "sum_assured"
    );

    public List<StandardizedRecord> standardizeCollection(String collectionName) {
        Map<String, String> mapping = mappingConfig.getMappingForCollection(collectionName);
        if (mapping.isEmpty()) {
            log.warn("No mapping for collection: {}", collectionName);
            return List.of();
        }

        List<Document> docs = downstreamRetryExecutor.executeWithRetry(
                () -> mongoTemplate.findAll(Document.class, collectionName),
                "mongo.findAll",
                "collection=" + collectionName
        );
        List<StandardizedRecord> records = new ArrayList<>();

        for (Document doc : docs) {
            String objectId = doc.getObjectId("_id").toString();
            Map<String, Object> docMap = doc.entrySet().stream()
                    .collect(Collectors.toMap(Map.Entry::getKey, e -> (Object) e.getValue()));
            StandardizedRecord rec = StandardizedRecord.fromMongoDoc(
                    collectionName, objectId, mapping, docMap
            );
            records.add(rec);
        }

        auditLogger.logMapping(collectionName, records.size());
        log.info("Standardized {} records from {}", records.size(), collectionName);
        return records;
    }

    /**
     * Standardize all policy collections (life, auto, health). Excludes customer_details.
     */
    public Map<String, List<StandardizedRecord>> standardizeAllPolicies() {
        return POLICY_COLLECTIONS.stream()
                .collect(Collectors.toMap(c -> c, this::standardizeCollection));
    }

    /**
     * Ingest parsed CSV rows into MongoDB. Inserts documents into the given collection.
     * Call standardizeAllPolicies() after to get StandardizedRecords for stitching.
     *
     * @return ObjectIds (hex strings) of documents inserted in this call; empty if nothing was inserted.
     */
    public List<String> ingestRecords(String collectionName, List<Map<String, Object>> rows) {
        if (rows == null || rows.isEmpty()) {
            log.warn("No rows to ingest for collection: {}", collectionName);
            return List.of();
        }

        Map<String, String> mapping = mappingConfig.getMappingForCollection(collectionName);
        if (mapping.isEmpty()) {
            log.warn("No mapping for collection: {}", collectionName);
            throw new IllegalArgumentException("Unknown collection: " + collectionName);
        }

        assertDeclaredCollectionMatchesFileProductType(collectionName, rows);

        String policyIdSourceKey = mapping.get("policy_id");
        String insurerSourceKey = mapping.get("insurer");
        int totalRows = rows.size();

        // Build a set of existing composite keys (policyNumber + insurerId) for idempotent ingestion.
        // For larger datasets this can be optimized, but it is sufficient for current sample sizes.
        var existingKeys = new java.util.HashSet<String>();
        if (policyIdSourceKey != null && insurerSourceKey != null) {
            List<Document> existingDocs = downstreamRetryExecutor.executeWithRetry(
                    () -> mongoTemplate.findAll(Document.class, collectionName),
                    "mongo.findAll",
                    "collection=" + collectionName + ", purpose=buildExistingKeys"
            );
            for (Document doc : existingDocs) {
                Object policyVal = doc.get(policyIdSourceKey);
                Object insurerVal = doc.get(insurerSourceKey);
                if (policyVal != null && insurerVal != null) {
                    String key = policyVal.toString().trim() + "|" + insurerVal.toString().trim();
                    existingKeys.add(key);
                }
            }
        }

        List<Document> documents = new ArrayList<>();
        var batchKeys = new java.util.HashSet<String>();
        int skippedDuplicates = 0;
        int failedValidation = 0;

        for (Map<String, Object> row : rows) {
            Map<String, Object> coerced = coerceNumericFields(row, mapping);

            // Hard validation for identity fields: if a row has invalid PAN / mobile / email / DOB,
            // log it to failed_log and skip ingesting it into the main collection.
            List<String> validationErrors = validateSemantic(row, coerced, mapping, collectionName);
            if (!validationErrors.isEmpty()) {
                FailedLogRecord failed = new FailedLogRecord();
                failed.setSourceCollection(collectionName);
                Object insurerValRaw = row.get(mapping.get("insurer"));
                failed.setInsurer(insurerValRaw != null ? insurerValRaw.toString() : null);
                failed.setRawData(new java.util.HashMap<>(row));
                failed.setValidationErrors(String.join("; ", validationErrors));
                failed.setCreatedAt(java.time.Instant.now());
                failedLogRepository.save(failed);
                failedValidation++;
                // Skip this row from normal ingestion
                continue;
            }

            if (policyIdSourceKey != null && insurerSourceKey != null) {
                Object policyVal = coerced.get(policyIdSourceKey);
                Object insurerVal = coerced.get(insurerSourceKey);
                if (policyVal != null && insurerVal != null) {
                    String key = policyVal.toString().trim() + "|" + insurerVal.toString().trim();
                    if (existingKeys.contains(key) || batchKeys.contains(key)) {
                        skippedDuplicates++;
                        continue;
                    }
                    batchKeys.add(key);
                    existingKeys.add(key);
                }
            }

            documents.add(new Document(coerced));
        }

        // If all rows failed validation, surface this clearly
        if (failedValidation == totalRows) {
            throw new IllegalArgumentException("All rows failed validation for collection " + collectionName);
        }

        if (documents.isEmpty()) {
            log.info("No new records to ingest into {} (all rows were duplicates)", collectionName);
            return List.of();
        }

        downstreamRetryExecutor.executeVoidWithRetry(
                () -> mongoTemplate.insert(documents, collectionName),
                "mongo.insertMany",
                "collection=" + collectionName + ", count=" + documents.size()
        );
        auditLogger.logMapping(collectionName + "_ingest", documents.size());
        log.info("Ingested {} records into {} (skipped {} duplicate rows based on policyNumber+insurerId, {} rows failed validation and were sent to failed_log)",
                documents.size(), collectionName, skippedDuplicates, failedValidation);

        // Step 4: if more than 20% of rows failed validation, mark the operation as failed
        if (failedValidation > 0 && failedValidation * 1.0 / totalRows > 0.2) {
            throw new IllegalArgumentException(
                    "Too many rows failed validation for collection " + collectionName +
                            ": " + failedValidation + " of " + totalRows
            );
        }

        List<String> insertedIds = new ArrayList<>(documents.size());
        for (Document d : documents) {
            if (d.getObjectId("_id") == null) {
                throw new IllegalStateException("Insert did not assign _id for document in " + collectionName);
            }
            insertedIds.add(d.getObjectId("_id").toString());
        }
        return insertedIds;
    }

    /**
     * Standardize only the documents inserted in the current upload (by {@code _id}), for batch-level stats.
     */
    public List<StandardizedRecord> standardizeByIds(String collectionName, List<String> objectIds) {
        if (objectIds == null || objectIds.isEmpty()) {
            return List.of();
        }
        Map<String, String> mapping = mappingConfig.getMappingForCollection(collectionName);
        if (mapping.isEmpty()) {
            return List.of();
        }
        List<StandardizedRecord> records = new ArrayList<>();
        for (String idStr : objectIds) {
            Document doc = downstreamRetryExecutor.executeWithRetry(
                    () -> mongoTemplate.findById(new ObjectId(idStr), Document.class, collectionName),
                    "mongo.findById",
                    "collection=" + collectionName + ", id=" + idStr
            );
            if (doc == null) {
                log.warn("Document not found after insert: {} {}", collectionName, idStr);
                continue;
            }
            String objectId = doc.getObjectId("_id").toString();
            Map<String, Object> docMap = doc.entrySet().stream()
                    .collect(Collectors.toMap(Map.Entry::getKey, e -> (Object) e.getValue()));
            records.add(StandardizedRecord.fromMongoDoc(collectionName, objectId, mapping, docMap));
        }
        return records;
    }

    /**
     * Ensures the CSV/XLSX column shape matches the selected Mongo collection. Each product line uses
     * different source headers (e.g. life: PolicyNum / SumAssured; auto: PolicyNumber / IDV). If the file
     * clearly matches another line (higher signature score), ingestion fails fast instead of writing
     * mis-keyed documents.
     */
    private void assertDeclaredCollectionMatchesFileProductType(String declaredCollection,
                                                                List<Map<String, Object>> rows) {
        Set<String> headers = rows.get(0).keySet().stream()
                .map(k -> k != null ? k.trim() : "")
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toCollection(LinkedHashSet::new));

        Map<String, Integer> scores = new LinkedHashMap<>();
        for (String coll : POLICY_COLLECTIONS) {
            Map<String, String> m = mappingConfig.getMappingForCollection(coll);
            int score = 0;
            for (String canonical : PRODUCT_SIGNATURE_KEYS) {
                String sourceCol = m.get(canonical);
                if (sourceCol != null && headers.contains(sourceCol.trim())) {
                    score++;
                }
            }
            scores.put(coll, score);
        }

        int best = scores.values().stream().mapToInt(Integer::intValue).max().orElse(0);
        if (best == 0) {
            throw new IllegalArgumentException(
                    "File headers do not contain recognizable product columns for any line "
                            + "(expected columns such as PolicyNumber/IDV for auto, PolicyNum/SumAssured for life, etc.). "
                            + "Check headers against mapping_config.json for " + declaredCollection + "."
            );
        }

        List<String> winners = scores.entrySet().stream()
                .filter(e -> e.getValue() == best)
                .map(Map.Entry::getKey)
                .toList();

        if (winners.size() == 1) {
            String inferred = winners.get(0);
            if (!inferred.equals(declaredCollection)) {
                throw new IllegalArgumentException(
                        "Product type mismatch: this file matches collection \"" + inferred
                                + "\" but you selected \"" + declaredCollection + "\". "
                                + "Choose the correct collection or fix the file headers."
                );
            }
            return;
        }

        // Tie: multiple product lines match the same number of signature columns
        if (!winners.contains(declaredCollection)) {
            throw new IllegalArgumentException(
                    "Product type mismatch: file could match " + winners
                            + " but you selected \"" + declaredCollection + "\"."
            );
        }
        throw new IllegalArgumentException(
                "Ambiguous file: headers match multiple product types equally (" + winners
                        + "). Add or correct columns so only one product line matches."
        );
    }

    private Map<String, Object> coerceNumericFields(Map<String, Object> row, Map<String, String> mapping) {
        List<String> numericSourceKeys = List.of("DOB", "Mobile", "PolicyStartDate", "PolicyEndDate",
                "PolicyStart", "PolicyEnd", "IDV", "AnnualPremium", "SumAssured", "AnnualPrem",
                "Coverage Amount", "Annual Premium", "Policy Start Date", "Policy End Date",
                "customerId", "refPhoneMobile", "datBirthCust");
        Map<String, Object> result = new HashMap<>(row);
        for (String key : result.keySet()) {
            Object val = result.get(key);
            if (val != null && val instanceof String s && !s.isBlank() && numericSourceKeys.contains(key)) {
                try {
                    if (s.contains(".")) {
                        result.put(key, Double.parseDouble(s));
                    } else {
                        long n = Long.parseLong(s.replaceAll("[^0-9-]", ""));
                        result.put(key, n <= Integer.MAX_VALUE ? (int) n : n);
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return result;
    }

    /**
     * Per-row semantic validation before ingestion. Returns a list of human-readable error messages.
     * If the list is non-empty, the row is considered invalid and should be written to failed_log.
     */
    private List<String> validateSemantic(Map<String, Object> originalRow,
                                          Map<String, Object> coercedRow,
                                          Map<String, String> mapping,
                                          String collectionName) {
        List<String> errors = new ArrayList<>();

        String panKey = mapping.get("pan");
        String mobileKey = mapping.get("mobile");
        String emailKey = mapping.get("email");
        String dobKey = mapping.get("dob");

        // PAN pattern check (simple Indian PAN-like pattern)
        if (panKey != null) {
            Object panVal = originalRow.get(panKey);
            if (panVal != null) {
                String pan = panVal.toString().trim();
                if (!pan.isEmpty() && !pan.matches("^[A-Z]{5}[0-9]{4}[A-Z]$")) {
                    errors.add("Invalid PAN format: " + pan);
                }
            }
        }

        // Mobile numeric + length check
        if (mobileKey != null) {
            Object mobileVal = originalRow.get(mobileKey);
            if (mobileVal != null) {
                String mobile = mobileVal.toString().replaceAll("\\D", "");
                if (!mobile.isEmpty() && (mobile.length() < 8 || mobile.length() > 15)) {
                    errors.add("Invalid mobile length: " + mobileVal);
                }
            }
        }

        // Email basic pattern
        if (emailKey != null) {
            Object emailVal = originalRow.get(emailKey);
            if (emailVal != null) {
                String email = emailVal.toString().trim();
                if (!email.isEmpty() && !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                    errors.add("Invalid email format: " + email);
                }
            }
        }

        // DOB must be 8-digit YYYYMMDD if present
        if (dobKey != null) {
            Object dobVal = originalRow.get(dobKey);
            if (dobVal != null) {
                String dobStr = dobVal.toString().trim();
                if (!dobStr.isEmpty() && !dobStr.matches("^\\d{8}$")) {
                    errors.add("Invalid DOB format (expected YYYYMMDD): " + dobStr);
                }
            }
        }

        return errors;
    }
}
