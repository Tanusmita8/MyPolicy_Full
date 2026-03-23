package com.mypolicy.policy.dto;

import lombok.Builder;
import lombok.Data;

/**
 * Profile fields sourced from customer_details + counts from unified_portfolio.
 */
@Data
@Builder
public class CustomerProfileResponse {
  private String customerId;
  private String fullName;
  private String email;
  private String mobile;
  /** Human-readable DOB when datBirthCust is YYYYMMDD */
  private String dateOfBirthDisplay;
  /** Last 4 chars of PAN only, prefixed with **** */
  private String panMasked;
  private String communicationAddress;
  private String permanentAddress;
  private String gender;
  private int totalPolicies;
  private long activePoliciesCount;
  private boolean kycVerified;
}
