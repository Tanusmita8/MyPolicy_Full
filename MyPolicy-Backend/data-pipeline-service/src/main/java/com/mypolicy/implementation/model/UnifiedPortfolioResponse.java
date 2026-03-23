package com.mypolicy.implementation.model;

import java.math.BigDecimal;
import java.util.List;

public class UnifiedPortfolioResponse {

    private Integer customerId;
    private List<PolicySummary> policies;
    private int totalPolicies;

    public static class PolicySummary {
        /** MongoDB _id of unified_portfolio document (for detail views). */
        private String recordId;
        private String policyId;
        private String insurer;
        private String sourceCollection;
        private BigDecimal premium;
        private Integer sumAssured;
        private Integer startDate;
        private Integer policyEnd;
        private String matchMethod;

        public String getRecordId() { return recordId; }
        public void setRecordId(String recordId) { this.recordId = recordId; }
        public String getPolicyId() { return policyId; }
        public void setPolicyId(String policyId) { this.policyId = policyId; }
        public String getInsurer() { return insurer; }
        public void setInsurer(String insurer) { this.insurer = insurer; }
        public String getSourceCollection() { return sourceCollection; }
        public void setSourceCollection(String sourceCollection) { this.sourceCollection = sourceCollection; }
        public BigDecimal getPremium() { return premium; }
        public void setPremium(BigDecimal premium) { this.premium = premium; }
        public Integer getSumAssured() { return sumAssured; }
        public void setSumAssured(Integer sumAssured) { this.sumAssured = sumAssured; }
        public Integer getStartDate() { return startDate; }
        public void setStartDate(Integer startDate) { this.startDate = startDate; }
        public Integer getPolicyEnd() { return policyEnd; }
        public void setPolicyEnd(Integer policyEnd) { this.policyEnd = policyEnd; }
        public String getMatchMethod() { return matchMethod; }
        public void setMatchMethod(String matchMethod) { this.matchMethod = matchMethod; }
    }

    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
    public List<PolicySummary> getPolicies() { return policies; }
    public void setPolicies(List<PolicySummary> policies) { this.policies = policies; }
    public int getTotalPolicies() { return totalPolicies; }
    public void setTotalPolicies(int totalPolicies) { this.totalPolicies = totalPolicies; }
}
