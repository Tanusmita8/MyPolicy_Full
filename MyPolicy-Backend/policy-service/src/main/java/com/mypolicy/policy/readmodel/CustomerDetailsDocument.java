package com.mypolicy.policy.readmodel;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Read-only view of customer_details (same MongoDB collection as customer-service / pipeline).
 */
@Document(collection = "customer_details")
public class CustomerDetailsDocument {

  @Id
  private String id;
  private Integer customerId;
  private String refCustItNum;
  private Object refPhoneMobile;
  private Integer datBirthCust;
  private String custEmailID;
  private String customerFullName;

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public Integer getCustomerId() {
    return customerId;
  }

  public void setCustomerId(Integer customerId) {
    this.customerId = customerId;
  }

  public String getRefCustItNum() {
    return refCustItNum;
  }

  public void setRefCustItNum(String refCustItNum) {
    this.refCustItNum = refCustItNum;
  }

  public Object getRefPhoneMobile() {
    return refPhoneMobile;
  }

  public void setRefPhoneMobile(Object refPhoneMobile) {
    this.refPhoneMobile = refPhoneMobile;
  }

  public Integer getDatBirthCust() {
    return datBirthCust;
  }

  public void setDatBirthCust(Integer datBirthCust) {
    this.datBirthCust = datBirthCust;
  }

  public String getCustEmailID() {
    return custEmailID;
  }

  public void setCustEmailID(String custEmailID) {
    this.custEmailID = custEmailID;
  }

  public String getCustomerFullName() {
    return customerFullName;
  }

  public void setCustomerFullName(String customerFullName) {
    this.customerFullName = customerFullName;
  }
}
