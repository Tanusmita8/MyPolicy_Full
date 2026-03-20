package com.mypolicy.implementation.service;

import com.mypolicy.implementation.model.CustomerDetails;
import com.mypolicy.implementation.model.StandardizedRecord;
import com.mypolicy.implementation.model.UnifiedPortfolioRecord;
import com.mypolicy.implementation.model.UnmatchedPolicyRecord;
import com.mypolicy.implementation.repository.CustomerDetailsRepository;
import com.mypolicy.implementation.repository.UnifiedPortfolioRepository;
import com.mypolicy.implementation.repository.UnmatchedPolicyRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Identity Stitching Service. Links policy records to Customer Master using:
 * Rule 1: Match by PAN (refCustItNum)
 * Rule 2: Match by Mobile + DOB
 */
@Service
public class StitchingService {

    private final CustomerDetailsRepository customerDetailsRepository;
    private final UnifiedPortfolioRepository unifiedPortfolioRepository;
    private final UnmatchedPolicyRepository unmatchedPolicyRepository;
    private final SecurityUtils securityUtils;
    private final AuditLogger auditLogger;

    public StitchingService(CustomerDetailsRepository customerDetailsRepository,
                            UnifiedPortfolioRepository unifiedPortfolioRepository,
                            UnmatchedPolicyRepository unmatchedPolicyRepository,
                            SecurityUtils securityUtils,
                            AuditLogger auditLogger) {
        this.customerDetailsRepository = customerDetailsRepository;
        this.unifiedPortfolioRepository = unifiedPortfolioRepository;
        this.unmatchedPolicyRepository = unmatchedPolicyRepository;
        this.securityUtils = securityUtils;
        this.auditLogger = auditLogger;
    }

    public StitchingResult stitchPolicies(List<StandardizedRecord> policies) {
        AtomicInteger matched = new AtomicInteger(0);
        AtomicInteger unmatched = new AtomicInteger(0);

        unifiedPortfolioRepository.deleteAll();
        unmatchedPolicyRepository.deleteAll();

        for (StandardizedRecord policy : policies) {
            Optional<CustomerDetails> customer = findCustomer(policy);
            if (customer.isPresent()) {
                UnifiedPortfolioRecord record = buildUnifiedRecord(policy, customer.get());
                unifiedPortfolioRepository.save(record);
                matched.incrementAndGet();
                auditLogger.logStitching(
                        record.getMatchMethod(),
                        policy.getPolicyId(),
                        customer.get().getCustomerId()
                );
            } else {
                UnmatchedPolicyRecord unmatchedRecord = buildUnmatchedRecord(policy);
                unmatchedPolicyRepository.save(unmatchedRecord);
                unmatched.incrementAndGet();
            }
        }

        auditLogger.logStitchingComplete(
                policies.size(),
                matched.get(),
                unmatched.get()
        );

        return new StitchingResult(policies.size(), matched.get(), unmatched.get());
    }

    /**
     * Same matching rules as {@link #stitchPolicies} but read-only — for reporting upload batch stats only.
     */
    public StitchingResult computeStitchingStats(List<StandardizedRecord> policies) {
        int matched = 0;
        int unmatched = 0;
        for (StandardizedRecord policy : policies) {
            if (findCustomer(policy).isPresent()) {
                matched++;
            } else {
                unmatched++;
            }
        }
        return new StitchingResult(policies.size(), matched, unmatched);
    }

    private Optional<CustomerDetails> findCustomer(StandardizedRecord policy) {
        // Priority 1: Match by PAN (refCustItNum)
        String pan = policy.getPan();
        if (pan != null && !pan.isBlank()) {
            Optional<CustomerDetails> byPan = customerDetailsRepository.findFirstByRefCustItNum(pan);
            if (byPan.isPresent()) return byPan;
        }

        // Priority 2: Match by Mobile + DOB
        Object mobile = policy.getMobile();
        Integer dob = policy.getDob();
        if (mobile != null && dob != null) {
            Optional<CustomerDetails> byMobileDob = customerDetailsRepository.findFirstByRefPhoneMobileAndDatBirthCust(mobile, dob);
            if (byMobileDob.isPresent()) return byMobileDob;
        }

        // Priority 3: Match by Email + DOB
        String email = policy.getEmail();
        if (email != null && !email.isBlank() && dob != null) {
            return customerDetailsRepository.findFirstByCustEmailIDAndDatBirthCust(email, dob);
        }

        return Optional.empty();
    }

    private UnmatchedPolicyRecord buildUnmatchedRecord(StandardizedRecord policy) {
        UnmatchedPolicyRecord record = new UnmatchedPolicyRecord();
        record.setSourceCollection(policy.getSourceCollection());
        record.setPolicyId(policy.getPolicyId());
        record.setInsurer(policy.getInsurer());
        record.setSumAssured(policy.getSumAssured());
        record.setStartDate(policy.getStartDate());
        record.setPolicyEnd(policy.getPolicyEnd());
        record.setPan(policy.getPan());
        record.setMobile(policy.getMobile());
        record.setEmail(policy.getEmail());
        record.setDob(policy.getDob());
        return record;
    }

    private UnifiedPortfolioRecord buildUnifiedRecord(StandardizedRecord policy, CustomerDetails customer) {
        String matchMethod = resolveMatchMethod(policy, customer);

        UnifiedPortfolioRecord record = new UnifiedPortfolioRecord();
        record.setCustomerId(customer.getCustomerId());
        record.setPolicyId(policy.getPolicyId());
        record.setInsurer(policy.getInsurer());
        record.setPremium(policy.getPremium());
        record.setSumAssured(policy.getSumAssured());
        record.setStartDate(policy.getStartDate());
        record.setPolicyEnd(policy.getPolicyEnd());
        record.setSourceCollection(policy.getSourceCollection());
        record.setMatchMethod(matchMethod);
        record.setEncryptedPan(securityUtils.encrypt(policy.getPan()));
        record.setEncryptedMobile(securityUtils.encrypt(policy.getMobile() != null ? policy.getMobile().toString() : null));
        record.setEncryptedEmail(securityUtils.encrypt(policy.getEmail()));
        return record;
    }

    private String resolveMatchMethod(StandardizedRecord policy, CustomerDetails customer) {
        if (customer.getRefCustItNum() != null && customer.getRefCustItNum().equals(policy.getPan())) return "PAN_MATCH";
        if (customer.getRefPhoneMobile() != null && policy.getMobile() != null
                && customer.getDatBirthCust() != null && customer.getDatBirthCust().equals(policy.getDob()))
            return "MOBILE_DOB_MATCH";
        if (customer.getCustEmailID() != null && customer.getCustEmailID().equals(policy.getEmail())
                && customer.getDatBirthCust() != null && customer.getDatBirthCust().equals(policy.getDob()))
            return "EMAIL_DOB_MATCH";
        return "UNKNOWN";
    }

    public record StitchingResult(int totalProcessed, int matched, int unmatched) {}
}
