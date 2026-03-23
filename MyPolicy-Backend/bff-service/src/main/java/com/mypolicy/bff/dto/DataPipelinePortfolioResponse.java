package com.mypolicy.bff.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * Maps to data-pipeline-service UnifiedPortfolioResponse.
 */
@Data
public class DataPipelinePortfolioResponse {
  private Integer customerId;
  private List<PolicySummary> policies;
  private int totalPolicies;

  @Data
  public static class PolicySummary {
    private String recordId;
    private String policyId;
    private String insurer;
    private String sourceCollection;
    private BigDecimal premium;
    private Integer sumAssured;
    private Integer startDate;
    private Integer policyEnd;
    private String matchMethod;
  }
}
