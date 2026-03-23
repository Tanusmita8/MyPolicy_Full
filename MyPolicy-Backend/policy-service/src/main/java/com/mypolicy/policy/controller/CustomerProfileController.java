package com.mypolicy.policy.controller;

import com.mypolicy.policy.dto.CustomerProfileResponse;
import com.mypolicy.policy.dto.PolicyDetailResponse;
import com.mypolicy.policy.service.CustomerProfileViewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
public class CustomerProfileController {

  private final CustomerProfileViewService customerProfileViewService;

  /**
   * Profile for customer app: customer_details fields + unified_portfolio counts.
   */
  @GetMapping("/{customerId}/profile")
  public ResponseEntity<CustomerProfileResponse> getProfile(@PathVariable Integer customerId) {
    return ResponseEntity.ok(customerProfileViewService.getProfile(customerId));
  }

  /**
   * Single stitched policy row by unified_portfolio document id.
   */
  @GetMapping("/{customerId}/policies/{recordId}")
  public ResponseEntity<PolicyDetailResponse> getPolicyDetail(
      @PathVariable Integer customerId, @PathVariable String recordId) {
    return ResponseEntity.ok(customerProfileViewService.getPolicyDetail(customerId, recordId));
  }
}
