package com.mypolicy.implementation.controller;

import com.mypolicy.implementation.dto.InsurerInsightsResponse;
import com.mypolicy.implementation.service.InsurerInsightsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/insights")
public class InsurerInsightsController {

    private final InsurerInsightsService insurerInsightsService;

    public InsurerInsightsController(InsurerInsightsService insurerInsightsService) {
        this.insurerInsightsService = insurerInsightsService;
    }

    /**
     * Real data from customer_details, unified_portfolio (via portfolio service), and unmatched_policies.
     */
    @GetMapping("/insurer-details/{customerId}")
    public ResponseEntity<InsurerInsightsResponse> insurerDetails(@PathVariable Integer customerId) {
        return ResponseEntity.ok(insurerInsightsService.build(customerId));
    }
}
