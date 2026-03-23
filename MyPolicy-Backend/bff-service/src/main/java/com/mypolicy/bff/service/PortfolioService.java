package com.mypolicy.bff.service;

import com.mypolicy.bff.client.CustomerClient;
import com.mypolicy.bff.client.DataPipelineClient;
import com.mypolicy.bff.dto.CustomerDTO;
import com.mypolicy.bff.dto.DataPipelinePortfolioResponse;
import com.mypolicy.bff.dto.PolicyDTO;
import com.mypolicy.bff.dto.PortfolioResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Aggregates portfolio from customer-service (customer details) and
 * data-pipeline-service (unified_portfolio - stitched policies).
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PortfolioService {

  private final CustomerClient customerClient;
  private final DataPipelineClient dataPipelineClient;

  /**
   * Fetches unified portfolio: customer info from customer_details + policies from unified_portfolio.
   * customerId is the Integer from customer_details (users who logged in via full name + PAN).
   */
  public PortfolioResponse getPortfolio(String customerId) {
    log.info("Fetching portfolio for customer: {}", customerId);

    Integer customerIdInt = parseCustomerId(customerId);
    if (customerIdInt == null) {
      throw new IllegalArgumentException("Invalid customer ID: " + customerId);
    }

    // Get customer details from customer_details (customer-service)
    CustomerDTO customer = customerClient.getCustomerDetails(customerIdInt);

    // Get portfolio from unified_portfolio (data-pipeline-service)
    DataPipelinePortfolioResponse pipelinePortfolio = dataPipelineClient.getPortfolio(customerIdInt);

    // Map to BFF response
    List<PolicyDTO> policies = pipelinePortfolio.getPolicies() != null
        ? pipelinePortfolio.getPolicies().stream()
            .map(ps -> {
              PolicyDTO dto = new PolicyDTO();
              dto.setPortfolioRecordId(ps.getRecordId());
              dto.setId(ps.getRecordId() != null ? ps.getRecordId() : ps.getPolicyId());
              dto.setPolicyNumber(ps.getPolicyId());
              dto.setPlanName(ps.getSourceCollection());
              dto.setPolicyType(ps.getSourceCollection());
              dto.setPremiumAmount(ps.getPremium());
              dto.setSumAssured(ps.getSumAssured() != null ? BigDecimal.valueOf(ps.getSumAssured()) : null);
              dto.setInsurerId(ps.getInsurer());
              dto.setStartDate(parseYyyyMmDd(ps.getStartDate()));
              dto.setEndDate(parseYyyyMmDd(ps.getPolicyEnd()));
              return dto;
            })
            .collect(Collectors.toList())
        : Collections.emptyList();

    BigDecimal totalPremium = policies.stream()
        .map(p -> p.getPremiumAmount() != null ? p.getPremiumAmount() : BigDecimal.ZERO)
        .reduce(BigDecimal.ZERO, BigDecimal::add);

    BigDecimal totalCoverage = policies.stream()
        .map(p -> p.getSumAssured() != null ? p.getSumAssured() : BigDecimal.ZERO)
        .reduce(BigDecimal.ZERO, BigDecimal::add);

    PortfolioResponse response = new PortfolioResponse();
    response.setCustomer(customer);
    response.setPolicies(policies);
    response.setTotalPolicies(pipelinePortfolio.getTotalPolicies());
    response.setTotalPremium(totalPremium);
    response.setTotalCoverage(totalCoverage);

    log.info("Portfolio fetched: {} policies, total premium: {}", policies.size(), totalPremium);
    return response;
  }

  private Integer parseCustomerId(String customerId) {
    if (customerId == null || customerId.isBlank()) return null;
    try {
      return Integer.parseInt(customerId.trim());
    } catch (NumberFormatException e) {
      return null;
    }
  }

  private LocalDate parseYyyyMmDd(Integer yyyymmdd) {
    if (yyyymmdd == null) {
      return null;
    }
    String s = yyyymmdd.toString();
    if (s.length() != 8) {
      return null;
    }
    int year = Integer.parseInt(s.substring(0, 4));
    int month = Integer.parseInt(s.substring(4, 6));
    int day = Integer.parseInt(s.substring(6, 8));
    return LocalDate.of(year, month, day);
  }
}
