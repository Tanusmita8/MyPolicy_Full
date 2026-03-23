package com.mypolicy.bff.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
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
  private String statusLabel;
}
