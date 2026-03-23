package com.mypolicy.customer.repository;

import com.mypolicy.customer.model.CustomerDetails;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

/**
 * Repository for customer_details collection.
 * Used for login - match by full name (Customer ID/User ID) and PAN (password).
 */
public interface CustomerDetailsRepository extends MongoRepository<CustomerDetails, String> {

    Optional<CustomerDetails> findFirstByCustomerFullNameIgnoreCaseAndRefCustItNum(
            String customerFullName, String refCustItNum);

    /** Login: resolve user by full name (case-insensitive), then verify PAN in service. */
    Optional<CustomerDetails> findFirstByCustomerFullNameIgnoreCase(String customerFullName);

    Optional<CustomerDetails> findFirstByCustomerId(Integer customerId);
}
