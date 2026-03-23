package com.mypolicy.implementation.service;

import com.mypolicy.implementation.model.UnifiedPortfolioRecord;
import com.mypolicy.implementation.model.UnifiedPortfolioResponse;
import com.mypolicy.implementation.repository.UnifiedPortfolioRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PortfolioService {

    private final UnifiedPortfolioRepository unifiedPortfolioRepository;

    public PortfolioService(UnifiedPortfolioRepository unifiedPortfolioRepository) {
        this.unifiedPortfolioRepository = unifiedPortfolioRepository;
    }

    public UnifiedPortfolioResponse getUnifiedPortfolio(Integer customerId) {
        List<UnifiedPortfolioRecord> records = unifiedPortfolioRepository.findByCustomerId(customerId);

        List<UnifiedPortfolioResponse.PolicySummary> policies = records.stream()
                .map(r -> {
                    UnifiedPortfolioResponse.PolicySummary ps = new UnifiedPortfolioResponse.PolicySummary();
                    ps.setRecordId(r.getId());
                    ps.setPolicyId(r.getPolicyId());
                    ps.setInsurer(r.getInsurer());
                    ps.setSourceCollection(r.getSourceCollection());
                    ps.setPremium(r.getPremium());
                    ps.setSumAssured(r.getSumAssured());
                    ps.setStartDate(r.getStartDate());
                    ps.setPolicyEnd(r.getPolicyEnd());
                    ps.setMatchMethod(r.getMatchMethod());
                    return ps;
                })
                .collect(Collectors.toList());

        UnifiedPortfolioResponse resp = new UnifiedPortfolioResponse();
        resp.setCustomerId(customerId);
        resp.setPolicies(policies);
        resp.setTotalPolicies(policies.size());
        return resp;
    }
}
