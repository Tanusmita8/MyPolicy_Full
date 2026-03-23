package com.mypolicy.policy.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Policy detail from unified_portfolio (and display helpers for the customer app).
 */
@Data
@Builder
public class PolicyDetailResponse {
  private String portfolioRecordId;
  private String policyNumber;
  private String insurer;
  private String sourceCollection;
  private String planLabel;
  private BigDecimal premiumAmount;
  private BigDecimal sumAssured;
  private LocalDate startDate;
  private LocalDate endDate;
  private String matchMethod;
  /** e.g. ACTIVE, DUE, EXPIRING_SOON, EXPIRED */
  private String statusLabel;
}
