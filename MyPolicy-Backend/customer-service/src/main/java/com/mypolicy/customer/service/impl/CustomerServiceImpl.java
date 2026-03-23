package com.mypolicy.customer.service.impl;

import com.mypolicy.customer.dto.CustomerRegistrationRequest;
import com.mypolicy.customer.dto.CustomerResponse;
import com.mypolicy.customer.dto.CustomerUpdateRequest;
import com.mypolicy.customer.dto.LoginRequest;
import com.mypolicy.customer.exception.CustomerNotFoundException;
import com.mypolicy.customer.exception.DuplicateCustomerException;
import com.mypolicy.customer.exception.InvalidCredentialsException;
import com.mypolicy.customer.model.Customer;
import com.mypolicy.customer.model.CustomerStatus;
import com.mypolicy.customer.repository.CustomerRepository;
import com.mypolicy.customer.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

  private final CustomerRepository customerRepository;
  private final com.mypolicy.customer.repository.CustomerDetailsRepository customerDetailsRepository;
  private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;
  private final com.mypolicy.customer.security.JwtService jwtService;

  @Override
  @Transactional
  public CustomerResponse registerCustomer(CustomerRegistrationRequest request) {
    if (customerRepository.existsByEmail(request.getEmail())) {
      throw new DuplicateCustomerException("Email", request.getEmail());
    }
    if (customerRepository.existsByMobileNumber(request.getMobileNumber())) {
      throw new DuplicateCustomerException("Mobile number", request.getMobileNumber());
    }

    Customer customer = new Customer();
    customer.setCustomerId(java.util.UUID.randomUUID().toString());
    customer.setFirstName(request.getFirstName());
    customer.setLastName(request.getLastName());
    customer.setEmail(request.getEmail());
    customer.setMobileNumber(request.getMobileNumber());
    customer.setPasswordHash(passwordEncoder.encode(request.getPassword()));
    customer.setPanNumber(request.getPanNumber());
    customer.setDateOfBirth(request.getDateOfBirth());
    customer.setAddress(request.getAddress());
    customer.setStatus(CustomerStatus.ACTIVE);

    Customer saved = customerRepository.save(customer);
    return mapToResponse(saved);
  }

  @Override
  public com.mypolicy.customer.dto.AuthResponse login(LoginRequest request) {
    // Login uses customer_details: full name = Customer ID/User ID, PAN = password
    String fullName = request.getCustomerIdOrUserId() != null ? request.getCustomerIdOrUserId().trim() : "";
    String panInput = request.getPassword() != null ? request.getPassword().trim() : "";

    com.mypolicy.customer.model.CustomerDetails customerDetails =
        customerDetailsRepository.findFirstByCustomerFullNameIgnoreCase(fullName)
            .orElseThrow(() -> new InvalidCredentialsException());

    String storedPan = customerDetails.getRefCustItNum();
    if (storedPan == null
        || !storedPan.trim().equalsIgnoreCase(panInput)) {
      throw new InvalidCredentialsException();
    }

    String token = jwtService.generateToken(customerDetails.getCustomerFullName());
    CustomerResponse response = mapCustomerDetailsToResponse(customerDetails);
    return new com.mypolicy.customer.dto.AuthResponse(token, response);
  }

  @Override
  public CustomerResponse getCustomerById(String customerId) {
    return customerRepository.findById(customerId)
        .map(this::mapToResponse)
        .orElseThrow(() -> new CustomerNotFoundException(customerId, "id"));
  }

  @Override
  @Transactional
  public CustomerResponse updateCustomer(String customerId, CustomerUpdateRequest request) {
    Customer customer = customerRepository.findById(customerId)
        .orElseThrow(() -> new CustomerNotFoundException(customerId, "id"));

    // Update only non-null fields
    if (request.getFirstName() != null && !request.getFirstName().isEmpty()) {
      customer.setFirstName(request.getFirstName());
    }

    if (request.getLastName() != null && !request.getLastName().isEmpty()) {
      customer.setLastName(request.getLastName());
    }

    if (request.getEmail() != null && !request.getEmail().isEmpty()) {
      // Check if new email is already taken by another customer
      customerRepository.findByEmail(request.getEmail()).ifPresent(existing -> {
        if (!existing.getCustomerId().equals(customerId)) {
          throw new DuplicateCustomerException("Email", request.getEmail());
        }
      });
      customer.setEmail(request.getEmail());
    }

    if (request.getMobileNumber() != null && !request.getMobileNumber().isEmpty()) {
      // Check if new mobile is already taken by another customer
      customerRepository.findByMobileNumber(request.getMobileNumber()).ifPresent(existing -> {
        if (!existing.getCustomerId().equals(customerId)) {
          throw new DuplicateCustomerException("Mobile number", request.getMobileNumber());
        }
      });
      customer.setMobileNumber(request.getMobileNumber());
    }

    if (request.getPanNumber() != null && !request.getPanNumber().isEmpty()) {
      // Check if new PAN is already taken by another customer
      customerRepository.findByPanNumber(request.getPanNumber()).ifPresent(existing -> {
        if (!existing.getCustomerId().equals(customerId)) {
          throw new DuplicateCustomerException("PAN number", request.getPanNumber());
        }
      });
      customer.setPanNumber(request.getPanNumber());
    }


    if (request.getDateOfBirth() != null && !request.getDateOfBirth().isEmpty()) {
      LocalDate dob = LocalDate.parse(request.getDateOfBirth());
      customer.setDateOfBirth(dob);
    }

    if (request.getAddress() != null && !request.getAddress().isEmpty()) {
      customer.setAddress(request.getAddress());
    }

    Customer updated = customerRepository.save(customer);
    return mapToResponse(updated);
  }

  @Override
  public Optional<CustomerResponse> searchByMobile(String mobile) {
    return customerRepository.findByMobileNumber(mobile)
        .map(this::mapToResponse);
  }

  @Override
  public Optional<CustomerResponse> searchByEmail(String email) {
    return customerRepository.findByEmail(email)
        .map(this::mapToResponse);
  }

  @Override
  public Optional<CustomerResponse> searchByPan(String pan) {
    return customerRepository.findByPanNumber(pan)
        .map(this::mapToResponse);
  }

  @Override
  public Optional<CustomerResponse> getCustomerDetailsByIntegerId(Integer customerId) {
    return customerDetailsRepository.findFirstByCustomerId(customerId)
        .map(this::mapCustomerDetailsToResponse);
  }

  private CustomerResponse mapToResponse(Customer c) {
    return CustomerResponse.builder()
        .customerId(c.getCustomerId())
        .firstName(c.getFirstName())
        .lastName(c.getLastName())
        .email(c.getEmail())
        .mobileNumber(c.getMobileNumber())
        .status(c.getStatus())
        .panNumber(c.getPanNumber())
        .dateOfBirth(c.getDateOfBirth())
        .address(c.getAddress())
        .build();
  }

  /** Maps CustomerDetails (from customer_details collection) to CustomerResponse for login */
  private CustomerResponse mapCustomerDetailsToResponse(com.mypolicy.customer.model.CustomerDetails cd) {
    String customerIdStr = cd.getCustomerId() != null ? String.valueOf(cd.getCustomerId()) : "";
    String mobile = cd.getRefPhoneMobile() != null ? cd.getRefPhoneMobile().toString() : null;
    return CustomerResponse.builder()
        .customerId(customerIdStr)
        .firstName(cd.getCustomerFullName())
        .lastName("")
        .email(cd.getCustEmailID())
        .mobileNumber(mobile)
        .status(com.mypolicy.customer.model.CustomerStatus.ACTIVE)
        .panNumber(maskPanForDisplay(cd.getRefCustItNum()))
        .dateOfBirth(parseYyyyMmDd(cd.getDatBirthCust()))
        .address(null)
        .build();
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

  /** Last 4 characters only; full PAN is never returned. */
  private static String maskPanForDisplay(String pan) {
    if (pan == null || pan.length() < 4) {
      return null;
    }
    String t = pan.trim().toUpperCase();
    return "****" + t.substring(t.length() - 4);
  }
}
