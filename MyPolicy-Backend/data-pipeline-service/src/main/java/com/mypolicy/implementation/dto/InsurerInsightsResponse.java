package com.mypolicy.implementation.dto;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Aggregates unified_portfolio, customer_details, and unmatched_policies for the customer app.
 */
public class InsurerInsightsResponse {

    private Integer customerId;
    private List<String> missingCustomerDetailFields = new ArrayList<>();
    private int unifiedPortfolioPolicyCount;
    /** sourceCollection (e.g. life_insurance, auto_insurance) → count */
    private Map<String, Integer> policiesBySourceCollection = new LinkedHashMap<>();
    /** Insurer name → summary */
    private List<InsurerBucket> perInsurer = new ArrayList<>();
    /** Rows from unmatched_policies matched to this customer's PAN */
    private List<UnmatchedRow> unmatchedPoliciesForCustomer = new ArrayList<>();

    public static class InsurerBucket {
        private String insurerName;
        private int policyCount;
        private java.math.BigDecimal totalPremium;
        private List<String> sourceCollections = new ArrayList<>();

        public String getInsurerName() {
            return insurerName;
        }

        public void setInsurerName(String insurerName) {
            this.insurerName = insurerName;
        }

        public int getPolicyCount() {
            return policyCount;
        }

        public void setPolicyCount(int policyCount) {
            this.policyCount = policyCount;
        }

        public java.math.BigDecimal getTotalPremium() {
            return totalPremium;
        }

        public void setTotalPremium(java.math.BigDecimal totalPremium) {
            this.totalPremium = totalPremium;
        }

        public List<String> getSourceCollections() {
            return sourceCollections;
        }

        public void setSourceCollections(List<String> sourceCollections) {
            this.sourceCollections = sourceCollections;
        }
    }

    public static class UnmatchedRow {
        private String policyId;
        private String insurer;
        private String sourceCollection;
        private Integer sumAssured;
        private String pan;

        public String getPolicyId() {
            return policyId;
        }

        public void setPolicyId(String policyId) {
            this.policyId = policyId;
        }

        public String getInsurer() {
            return insurer;
        }

        public void setInsurer(String insurer) {
            this.insurer = insurer;
        }

        public String getSourceCollection() {
            return sourceCollection;
        }

        public void setSourceCollection(String sourceCollection) {
            this.sourceCollection = sourceCollection;
        }

        public Integer getSumAssured() {
            return sumAssured;
        }

        public void setSumAssured(Integer sumAssured) {
            this.sumAssured = sumAssured;
        }

        public String getPan() {
            return pan;
        }

        public void setPan(String pan) {
            this.pan = pan;
        }
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public List<String> getMissingCustomerDetailFields() {
        return missingCustomerDetailFields;
    }

    public void setMissingCustomerDetailFields(List<String> missingCustomerDetailFields) {
        this.missingCustomerDetailFields = missingCustomerDetailFields;
    }

    public int getUnifiedPortfolioPolicyCount() {
        return unifiedPortfolioPolicyCount;
    }

    public void setUnifiedPortfolioPolicyCount(int unifiedPortfolioPolicyCount) {
        this.unifiedPortfolioPolicyCount = unifiedPortfolioPolicyCount;
    }

    public Map<String, Integer> getPoliciesBySourceCollection() {
        return policiesBySourceCollection;
    }

    public void setPoliciesBySourceCollection(Map<String, Integer> policiesBySourceCollection) {
        this.policiesBySourceCollection = policiesBySourceCollection;
    }

    public List<InsurerBucket> getPerInsurer() {
        return perInsurer;
    }

    public void setPerInsurer(List<InsurerBucket> perInsurer) {
        this.perInsurer = perInsurer;
    }

    public List<UnmatchedRow> getUnmatchedPoliciesForCustomer() {
        return unmatchedPoliciesForCustomer;
    }

    public void setUnmatchedPoliciesForCustomer(List<UnmatchedRow> unmatchedPoliciesForCustomer) {
        this.unmatchedPoliciesForCustomer = unmatchedPoliciesForCustomer;
    }
}
