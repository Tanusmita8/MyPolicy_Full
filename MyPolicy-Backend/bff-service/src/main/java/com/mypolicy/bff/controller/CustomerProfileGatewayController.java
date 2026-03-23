package com.mypolicy.bff.controller;

import com.mypolicy.bff.client.PolicyClient;
import com.mypolicy.bff.dto.CustomerProfileResponse;
import com.mypolicy.bff.dto.PolicyDetailResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Proxies customer profile and stitched policy detail from policy-service (Mongo:
 * customer_details, unified_portfolio).
 */
@RestController
@RequestMapping("/api/bff/customer")
@RequiredArgsConstructor
public class CustomerProfileGatewayController {

  private final PolicyClient policyClient;

  @GetMapping("/{customerId}/profile")
  public ResponseEntity<CustomerProfileResponse> getProfile(@PathVariable Integer customerId) {
    return ResponseEntity.ok(policyClient.getCustomerProfile(customerId));
  }

  @GetMapping("/{customerId}/policies/{recordId}")
  public ResponseEntity<PolicyDetailResponse> getPolicyDetail(
      @PathVariable Integer customerId, @PathVariable String recordId) {
    return ResponseEntity.ok(policyClient.getPolicyDetail(customerId, recordId));
  }
}
