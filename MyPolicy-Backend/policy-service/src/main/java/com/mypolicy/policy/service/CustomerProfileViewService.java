package com.mypolicy.policy.service;

import com.mypolicy.policy.dto.CustomerProfileResponse;
import com.mypolicy.policy.dto.PolicyDetailResponse;
import com.mypolicy.policy.readmodel.CustomerDetailsDocument;
import com.mypolicy.policy.readmodel.CustomerDetailsReadRepository;
import com.mypolicy.policy.readmodel.UnifiedPortfolioDocument;
import com.mypolicy.policy.readmodel.UnifiedPortfolioReadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class CustomerProfileViewService {

  private static final DateTimeFormatter DOB_DISPLAY =
      DateTimeFormatter.ofPattern("d MMMM yyyy", Locale.ENGLISH);

  private final CustomerDetailsReadRepository customerDetailsReadRepository;
  private final UnifiedPortfolioReadRepository unifiedPortfolioReadRepository;

  public CustomerProfileResponse getProfile(Integer customerId) {
    CustomerDetailsDocument cd =
        customerDetailsReadRepository
            .findFirstByCustomerId(customerId)
            .orElseThrow(
                () ->
                    new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Customer not found: " + customerId));

    List<UnifiedPortfolioDocument> policies =
        unifiedPortfolioReadRepository.findByCustomerId(customerId);
    long active =
        policies.stream().filter(p -> isActivePortfolioRow(p.getPolicyEnd())).count();

    String mobile = cd.getRefPhoneMobile() != null ? cd.getRefPhoneMobile().toString().trim() : null;
    String panMasked = maskPan(cd.getRefCustItNum());
    String dobDisplay = formatDob(cd.getDatBirthCust());

    return CustomerProfileResponse.builder()
        .customerId(String.valueOf(customerId))
        .fullName(cd.getCustomerFullName())
        .email(cd.getCustEmailID())
        .mobile(mobile)
        .dateOfBirthDisplay(dobDisplay)
        .panMasked(panMasked)
        .communicationAddress(null)
        .permanentAddress(null)
        .gender(null)
        .totalPolicies(policies.size())
        .activePoliciesCount(active)
        .kycVerified(cd.getRefCustItNum() != null && !cd.getRefCustItNum().isBlank())
        .build();
  }

  public PolicyDetailResponse getPolicyDetail(Integer customerId, String recordId) {
    UnifiedPortfolioDocument r =
        unifiedPortfolioReadRepository
            .findByIdAndCustomerId(recordId, customerId)
            .orElseThrow(
                () ->
                    new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Policy record not found for customer " + customerId));

    LocalDate start = parseYyyyMmDd(r.getStartDate());
    LocalDate end = parseYyyyMmDd(r.getPolicyEnd());
    String status = computeStatusLabel(end);

    BigDecimal sum =
        r.getSumAssured() != null
            ? BigDecimal.valueOf(r.getSumAssured())
            : BigDecimal.ZERO.setScale(2, RoundingMode.UNNECESSARY);

    return PolicyDetailResponse.builder()
        .portfolioRecordId(r.getId())
        .policyNumber(r.getPolicyId())
        .insurer(r.getInsurer())
        .sourceCollection(r.getSourceCollection())
        .planLabel(humanizeCollection(r.getSourceCollection()))
        .premiumAmount(r.getPremium())
        .sumAssured(sum)
        .startDate(start)
        .endDate(end)
        .matchMethod(r.getMatchMethod())
        .statusLabel(status)
        .build();
  }

  private static boolean isActivePortfolioRow(Integer policyEndYyyymmdd) {
    LocalDate end = parseYyyyMmDd(policyEndYyyymmdd);
    return end != null && !end.isBefore(LocalDate.now());
  }

  private static LocalDate parseYyyyMmDd(Integer yyyymmdd) {
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

  private static String formatDob(Integer datBirthCust) {
    LocalDate d = parseYyyyMmDd(datBirthCust);
    return d != null ? d.format(DOB_DISPLAY) : null;
  }

  private static String maskPan(String pan) {
    if (pan == null || pan.length() < 4) {
      return null;
    }
    String t = pan.trim().toUpperCase();
    return "****" + t.substring(t.length() - 4);
  }

  private static String humanizeCollection(String source) {
    if (source == null || source.isBlank()) {
      return "Policy";
    }
    return source.replace('_', ' ');
  }

  private static String computeStatusLabel(LocalDate endDate) {
    if (endDate == null) {
      return "UNKNOWN";
    }
    LocalDate now = LocalDate.now();
    if (endDate.isBefore(now)) {
      return "EXPIRED";
    }
    long days = java.time.temporal.ChronoUnit.DAYS.between(now, endDate);
    if (days <= 8) {
      return "EXPIRING_SOON";
    }
    if (days <= 30) {
      return "DUE";
    }
    return "ACTIVE";
  }
}
