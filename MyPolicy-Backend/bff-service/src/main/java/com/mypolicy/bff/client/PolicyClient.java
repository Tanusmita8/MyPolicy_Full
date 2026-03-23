package com.mypolicy.bff.client;

import com.mypolicy.bff.dto.CustomerProfileResponse;
import com.mypolicy.bff.dto.PolicyDTO;
import com.mypolicy.bff.dto.PolicyDetailResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "policy-service")
public interface PolicyClient {

  @GetMapping("/api/v1/policies/customer/{customerId}")
  List<PolicyDTO> getPoliciesByCustomer(@PathVariable("customerId") String customerId);

  @GetMapping("/api/v1/policies/{id}")
  PolicyDTO getPolicyById(@PathVariable("id") String id);

  /** customer_details + unified_portfolio counts (policy-service read model). */
  @GetMapping("/api/v1/customers/{customerId}/profile")
  CustomerProfileResponse getCustomerProfile(@PathVariable("customerId") Integer customerId);

  /** Single unified_portfolio document by Mongo _id. */
  @GetMapping("/api/v1/customers/{customerId}/policies/{recordId}")
  PolicyDetailResponse getPolicyDetail(
      @PathVariable("customerId") Integer customerId,
      @PathVariable("recordId") String recordId);
}
