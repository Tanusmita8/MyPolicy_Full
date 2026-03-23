package com.mypolicy.bff.controller;

import com.mypolicy.bff.client.PipelineInsurerClient;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/**
 * BFF entry point for the Insurer Portal (Flutter) — forwards to data-pipeline-service.
 */
@RestController
@RequestMapping("/api/bff/pipeline")
@RequiredArgsConstructor
public class InsurerPipelineController {

  private final PipelineInsurerClient pipelineInsurerClient;

  @PostMapping(value = "/upload-async", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  public ResponseEntity<Object> uploadAsync(
      @RequestPart("file") MultipartFile file,
      @RequestPart("collectionName") String collectionName) {
    return ResponseEntity.ok(pipelineInsurerClient.uploadAsync(file, collectionName));
  }

  @GetMapping("/jobs/{jobId}")
  public ResponseEntity<Object> getJob(@PathVariable String jobId) {
    return ResponseEntity.ok(pipelineInsurerClient.getJob(jobId));
  }

  @GetMapping("/failed-log")
  public ResponseEntity<Object> getFailedLog(
      @RequestParam String collectionName,
      @RequestParam(defaultValue = "50") int limit) {
    return ResponseEntity.ok(pipelineInsurerClient.getFailedLog(collectionName, limit));
  }
}
