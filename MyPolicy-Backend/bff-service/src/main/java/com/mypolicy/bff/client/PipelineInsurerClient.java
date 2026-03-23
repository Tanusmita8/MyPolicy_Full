package com.mypolicy.bff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

/**
 * Proxies Insurer Portal calls to data-pipeline-service pipeline APIs.
 */
@FeignClient(
    name = "data-pipeline-service",
    url = "${data-pipeline.service.url:http://localhost:8082}",
    contextId = "pipelineInsurerClient"
)
public interface PipelineInsurerClient {

  @PostMapping(value = "/api/pipeline/upload-async", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  Object uploadAsync(@RequestPart("file") MultipartFile file,
                     @RequestPart("collectionName") String collectionName);

  @GetMapping("/api/pipeline/jobs/{jobId}")
  Object getJob(@PathVariable("jobId") String jobId);

  @GetMapping("/api/pipeline/failed-log")
  Object getFailedLog(@RequestParam("collectionName") String collectionName,
                      @RequestParam(value = "limit", defaultValue = "50") int limit);
}
