package com.mypolicy.policy.readmodel;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface CustomerDetailsReadRepository extends MongoRepository<CustomerDetailsDocument, String> {

  Optional<CustomerDetailsDocument> findFirstByCustomerId(Integer customerId);
}
