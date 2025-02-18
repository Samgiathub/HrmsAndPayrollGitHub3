using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090ChangeRequestApprovalAdminReport
{
    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RequestTypeId { get; set; }

    public string? ChangeReason { get; set; }

    public DateTime? RequestDate { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public DateTime? ShiftFromDate { get; set; }

    public DateTime? ShiftToDate { get; set; }

    public string? CurrDetails { get; set; }

    public string? NewDetails { get; set; }

    public string? CurrTehsil { get; set; }

    public string? CurrDistrict { get; set; }

    public string? CurrThana { get; set; }

    public string? CurrCityVillage { get; set; }

    public string? CurrState { get; set; }

    public decimal? CurrPincode { get; set; }

    public string? NewTehsil { get; set; }

    public string? NewDistrict { get; set; }

    public string? NewThana { get; set; }

    public string? NewCityVillage { get; set; }

    public string? NewState { get; set; }

    public decimal? NewPincode { get; set; }

    public string? RequestStatus { get; set; }

    public decimal? IncrementId { get; set; }

    public decimal? IncrementIdOld { get; set; }

    public decimal RequestAprId { get; set; }

    public string? RequestType { get; set; }

    public decimal RequestId { get; set; }

    public decimal? QuaulificationId { get; set; }

    public string? Specialization { get; set; }

    public decimal? PassingYear { get; set; }

    public string? Score { get; set; }

    public DateTime? QuaulificationStarDate { get; set; }

    public DateTime? QuaulificationEndDate { get; set; }

    public string? DependantName { get; set; }

    public string? DependantGender { get; set; }

    public DateTime? DependantDob { get; set; }

    public decimal? DependantAge { get; set; }

    public string? DependantRelationship { get; set; }

    public decimal? DependantIsResident { get; set; }

    public decimal? DependantIsDependant { get; set; }

    public decimal? PassVisaCitizenship { get; set; }

    public string? PassVisaNo { get; set; }

    public DateTime? PassVisaIssueDate { get; set; }

    public DateTime? PassVisaExpDate { get; set; }

    public DateTime? PassVisaReviewDate { get; set; }

    public string? PassVisaStatus { get; set; }

    public decimal? LicenseId { get; set; }

    public string? LicenseType { get; set; }

    public DateTime? LicenseIssueDate { get; set; }

    public string? LicenseNo { get; set; }

    public DateTime? LicenseExpDate { get; set; }

    public decimal? LicenseIsExpired { get; set; }

    public string? ImagePath { get; set; }

    public string? CurrIfscCode { get; set; }

    public string? CurrAccountNo { get; set; }

    public string? CurrBranchName { get; set; }

    public string? NewIfscCode { get; set; }

    public string? NewAccountNo { get; set; }

    public string? NewBranchName { get; set; }

    public string? NominessAddress { get; set; }

    public decimal? NominessShare { get; set; }

    public decimal? NominessFor { get; set; }

    public string? NomineesRowId { get; set; }

    public string? HospitalName { get; set; }

    public string? HospitalAddress { get; set; }

    public DateTime? AdmitDate { get; set; }

    public decimal? MediCalimApprovalAmount { get; set; }

    public string? OldPanNo { get; set; }

    public string? OldAdharNo { get; set; }

    public string? NewAdharNo { get; set; }

    public string? NewPanNo { get; set; }

    public decimal? LoanMonth { get; set; }

    public decimal? LoanYear { get; set; }

    public DateTime? ApplicationRequestDate { get; set; }

    public DateTime? ChildBirthDate { get; set; }
}
