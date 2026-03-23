package com.mypolicy.implementation.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Document(collection = "auto_insurance")
public class AutoInsurance {

    @Id
    private String id;
    @Field("PolicyNumber")
    private String policyNumber;
    @Field("CustomerName")
    private String customerName;
    private Integer DOB;
    private String PAN;
    private Object Mobile;
    private String Email;
    private String Insurer;
    private String VehicleType;
    private String VehicleRegNo;
    private Integer IDV;
    @Field("AnnualPremium")
    private Integer annualPremium;
    @Field("PolicyStartDate")
    private Integer policyStartDate;
    @Field("PolicyEndDate")
    private Integer policyEndDate;
    private String City;

    public String getId() {
        return id;
    }

    public String getPolicyNumber() {
        return policyNumber;
    }

    public void setPolicyNumber(String policyNumber) {
        this.policyNumber = policyNumber;
    }

    public Integer getDOB() {
        return DOB;
    }

    public void setDOB(Integer DOB) {
        this.DOB = DOB;
    }

    public String getPAN() {
        return PAN;
    }

    public void setPAN(String PAN) {
        this.PAN = PAN;
    }

    public Object getMobile() {
        return Mobile;
    }

    public void setMobile(Object mobile) {
        this.Mobile = mobile;
    }

    public String getEmail() {
        return Email;
    }

    public void setEmail(String email) {
        this.Email = email;
    }

    public String getInsurer() {
        return Insurer;
    }

    public void setInsurer(String insurer) {
        this.Insurer = insurer;
    }

    public Integer getIDV() {
        return IDV;
    }

    public void setIDV(Integer IDV) {
        this.IDV = IDV;
    }

    public Integer getAnnualPremium() {
        return annualPremium;
    }

    public void setAnnualPremium(Integer annualPremium) {
        this.annualPremium = annualPremium;
    }

    public Integer getPolicyStartDate() {
        return policyStartDate;
    }

    public void setPolicyStartDate(Integer policyStartDate) {
        this.policyStartDate = policyStartDate;
    }

    public Integer getPolicyEndDate() {
        return policyEndDate;
    }

    public void setPolicyEndDate(Integer policyEndDate) {
        this.policyEndDate = policyEndDate;
    }

    public String getVehicleType() {
        return VehicleType;
    }

    public void setVehicleType(String VehicleType) {
        this.VehicleType = VehicleType;
    }

    public String getVehicleRegNo() {
        return VehicleRegNo;
    }

    public void setVehicleRegNo(String VehicleRegNo) {
        this.VehicleRegNo = VehicleRegNo;
    }

    public String getCity() {
        return City;
    }

    public void setCity(String City) {
        this.City = City;
    }
}
