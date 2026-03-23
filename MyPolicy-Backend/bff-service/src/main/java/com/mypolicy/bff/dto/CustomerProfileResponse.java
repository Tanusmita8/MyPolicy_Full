package com.mypolicy.bff.dto;

import lombok.Data;

@Data
public class CustomerProfileResponse {
  private String customerId;
  private String fullName;
  private String email;
  private String mobile;
  private String dateOfBirthDisplay;
  private String panMasked;
  private String communicationAddress;
  private String permanentAddress;
  private String gender;
  private int totalPolicies;
  private long activePoliciesCount;
  private boolean kycVerified;
}
