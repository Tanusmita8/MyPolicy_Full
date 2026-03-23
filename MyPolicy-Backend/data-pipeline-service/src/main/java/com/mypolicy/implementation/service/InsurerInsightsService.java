package com.mypolicy.implementation.service;

import com.mypolicy.implementation.dto.InsurerInsightsResponse;
import com.mypolicy.implementation.model.CustomerDetails;
import com.mypolicy.implementation.model.UnifiedPortfolioResponse;
import com.mypolicy.implementation.model.UnmatchedPolicyRecord;
import com.mypolicy.implementation.repository.CustomerDetailsRepository;
import com.mypolicy.implementation.repository.UnmatchedPolicyRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class InsurerInsightsService {

    private final CustomerDetailsRepository customerDetailsRepository;
    private final UnmatchedPolicyRepository unmatchedPolicyRepository;
    private final PortfolioService portfolioService;

    public InsurerInsightsService(
            CustomerDetailsRepository customerDetailsRepository,
            UnmatchedPolicyRepository unmatchedPolicyRepository,
            PortfolioService portfolioService) {
        this.customerDetailsRepository = customerDetailsRepository;
        this.unmatchedPolicyRepository = unmatchedPolicyRepository;
        this.portfolioService = portfolioService;
    }

    public InsurerInsightsResponse build(Integer customerId) {
        InsurerInsightsResponse out = new InsurerInsightsResponse();
        out.setCustomerId(customerId);

        Optional<CustomerDetails> custOpt = customerDetailsRepository.findFirstByCustomerId(customerId);
        CustomerDetails cd = custOpt.orElse(null);
        List<String> missing = new ArrayList<>();
        if (cd == null) {
            missing.add("Entire customer_details document (no row for customerId=" + customerId + ")");
        } else {
            if (isBlank(cd.getCustomerFullName())) {
                missing.add("customerFullName");
            }
            if (isBlank(cd.getRefCustItNum())) {
                missing.add("refCustItNum (PAN)");
            }
            if (isBlank(cd.getCustEmailID())) {
                missing.add("custEmailID");
            }
            if (cd.getRefPhoneMobile() == null) {
                missing.add("refPhoneMobile");
            }
            if (cd.getDatBirthCust() == null) {
                missing.add("datBirthCust");
            }
        }
        out.setMissingCustomerDetailFields(missing);

        UnifiedPortfolioResponse portfolio = portfolioService.getUnifiedPortfolio(customerId);
        List<UnifiedPortfolioResponse.PolicySummary> policies =
                portfolio.getPolicies() != null ? portfolio.getPolicies() : List.of();
        out.setUnifiedPortfolioPolicyCount(portfolio.getTotalPolicies());

        Map<String, Integer> byCollection = new LinkedHashMap<>();
        Map<String, Agg> byInsurer = new LinkedHashMap<>();
        for (UnifiedPortfolioResponse.PolicySummary p : policies) {
            String sc = p.getSourceCollection() != null ? p.getSourceCollection() : "unknown";
            byCollection.merge(sc, 1, Integer::sum);

            String ins = p.getInsurer() != null && !p.getInsurer().isBlank() ? p.getInsurer() : "(unknown insurer)";
            Agg agg = byInsurer.computeIfAbsent(ins, Agg::new);
            agg.count++;
            if (p.getPremium() != null) {
                agg.premium = agg.premium.add(p.getPremium());
            }
            if (p.getSourceCollection() != null && !p.getSourceCollection().isBlank()) {
                agg.collections.add(p.getSourceCollection());
            }
        }
        out.setPoliciesBySourceCollection(byCollection);

        List<InsurerInsightsResponse.InsurerBucket> buckets = byInsurer.entrySet().stream()
                .sorted(Map.Entry.comparingByKey(String.CASE_INSENSITIVE_ORDER))
                .map(e -> {
                    InsurerInsightsResponse.InsurerBucket b = new InsurerInsightsResponse.InsurerBucket();
                    b.setInsurerName(e.getKey());
                    b.setPolicyCount(e.getValue().count);
                    b.setTotalPremium(e.getValue().premium);
                    b.setSourceCollections(e.getValue().collections.stream().distinct().sorted().collect(Collectors.toList()));
                    return b;
                })
                .collect(Collectors.toList());
        out.setPerInsurer(buckets);

        String pan = cd != null ? cd.getRefCustItNum() : null;
        if (pan != null && !pan.isBlank()) {
            String panNorm = pan.trim();
            for (UnmatchedPolicyRecord u : unmatchedPolicyRepository.findAll()) {
                if (u.getPan() == null) {
                    continue;
                }
                if (!panNorm.equalsIgnoreCase(u.getPan().trim())) {
                    continue;
                }
                InsurerInsightsResponse.UnmatchedRow row = new InsurerInsightsResponse.UnmatchedRow();
                row.setPolicyId(u.getPolicyId());
                row.setInsurer(u.getInsurer());
                row.setSourceCollection(u.getSourceCollection());
                row.setSumAssured(u.getSumAssured());
                row.setPan(u.getPan());
                out.getUnmatchedPoliciesForCustomer().add(row);
            }
        }

        return out;
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static final class Agg {
        int count;
        BigDecimal premium = BigDecimal.ZERO;
        final Set<String> collections = new LinkedHashSet<>();

        Agg(String ignored) {
        }
    }
}
