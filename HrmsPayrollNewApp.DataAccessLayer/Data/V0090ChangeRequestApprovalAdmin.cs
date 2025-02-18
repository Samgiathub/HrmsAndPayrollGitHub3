using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090ChangeRequestApprovalAdmin
{
    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RequestTypeId { get; set; }

    public string? ChangeReason { get; set; }

    public DateTime? RequestDate { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public DateTime? RequestAprDate { get; set; }

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

    public DateTime? ChildBirthDate { get; set; }

    public int DepOccupationId { get; set; }

    public string DepHobbyId { get; set; } = null!;

    public string DepHobbyName { get; set; } = null!;

    public string DepDepCompanyName { get; set; } = null!;

    public string DepCmpCity { get; set; } = null!;

    public int DepStandardId { get; set; }

    public string DepShcoolCollege { get; set; } = null!;

    public string DepSchCity { get; set; } = null!;

    public string DepExtraActivity { get; set; } = null!;

    public string EmpFavSportId { get; set; } = null!;

    public string EmpFavSportName { get; set; } = null!;

    public string EmpHobbyId { get; set; } = null!;

    public string EmpHobbyName { get; set; } = null!;

    public string EmpFavFood { get; set; } = null!;

    public string EmpFavRestro { get; set; } = null!;

    public string EmpFavTrvDestination { get; set; } = null!;

    public string EmpFavFestival { get; set; } = null!;

    public string EmpFavSportPerson { get; set; } = null!;

    public string EmpFavSinger { get; set; } = null!;

    public string CurrEmpFavSportId { get; set; } = null!;

    public string CurrEmpFavSportName { get; set; } = null!;

    public string CurrEmpHobbyId { get; set; } = null!;

    public string CurrEmpHobbyName { get; set; } = null!;

    public string CurrEmpFavFood { get; set; } = null!;

    public string CurrEmpFavRestro { get; set; } = null!;

    public string CurrEmpFavTrvDestination { get; set; } = null!;

    public string CurrEmpFavFestival { get; set; } = null!;

    public string CurrEmpFavSportPerson { get; set; } = null!;

    public string CurrEmpFavSinger { get; set; } = null!;

    public string OtherHobby { get; set; } = null!;

    public string DepPancardNo { get; set; } = null!;

    public string DepAdharcardNo { get; set; } = null!;

    public string DepHeight { get; set; } = null!;

    public string DepWeight { get; set; } = null!;

    public string OtherSports { get; set; } = null!;

    public int CurrDepId { get; set; }

    public string CurrDepName { get; set; } = null!;

    public string CurrDepGender { get; set; } = null!;

    public DateTime CurrDepDob { get; set; }

    public decimal CurrDepCage { get; set; }

    public string CurrDepRelationship { get; set; } = null!;

    public int CurrDepIsresi { get; set; }

    public int CurrDepIsdep { get; set; }

    public string CurrDepImagePath { get; set; } = null!;

    public string CurrDepPanCard { get; set; } = null!;

    public string CurrDepAdharCard { get; set; } = null!;

    public string CurrDepHeight { get; set; } = null!;

    public string CurrDepWeight { get; set; } = null!;

    public int CurrDepOccupationId { get; set; }

    public string CurrDepOccupationName { get; set; } = null!;

    public string CurrDepHobbyId { get; set; } = null!;

    public string CurrDepHobbyName { get; set; } = null!;

    public string CurrDepCompanyName { get; set; } = null!;

    public string CurrDepCompanyCity { get; set; } = null!;

    public int CurrDepStandardId { get; set; }

    public string CurrDepStandardName { get; set; } = null!;

    public string CurrDepSchCol { get; set; } = null!;

    public string CurrDepSchColCity { get; set; } = null!;

    public string CurrDepExtraActivity { get; set; } = null!;

    public string DepStdSpecialization { get; set; } = null!;

    public string CurrDepStdSpecialization { get; set; } = null!;
}
