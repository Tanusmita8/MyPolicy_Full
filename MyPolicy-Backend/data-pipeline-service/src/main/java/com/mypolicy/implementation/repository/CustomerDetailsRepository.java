package com.mypolicy.implementation.repository;

import com.mypolicy.implementation.model.CustomerDetails;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface CustomerDetailsRepository extends MongoRepository<CustomerDetails, String> {

    Optional<CustomerDetails> findFirstByRefCustItNum(String refCustItNum);

    Optional<CustomerDetails> findFirstByRefPhoneMobileAndDatBirthCust(Object refPhoneMobile, Integer datBirthCust);

    Optional<CustomerDetails> findFirstByCustEmailIDAndDatBirthCust(String custEmailID, Integer datBirthCust);

    Optional<CustomerDetails> findFirstByCustomerId(Integer customerId);
}
