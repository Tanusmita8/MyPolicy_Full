package com.mypolicy.policy.readmodel;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface UnifiedPortfolioReadRepository extends MongoRepository<UnifiedPortfolioDocument, String> {

  List<UnifiedPortfolioDocument> findByCustomerId(Integer customerId);

  Optional<UnifiedPortfolioDocument> findByIdAndCustomerId(String id, Integer customerId);
}
