using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060HrmsEmpMasterIncrementGet
{
    public decimal EmpCode { get; set; }

    public string? Initial { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public DateTime DateOfJoin { get; set; }

    public string? SsnNo { get; set; }

    public string? SinNo { get; set; }

    public string? DrLicNo { get; set; }

    public string? PanNo { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? MaritalStatus { get; set; }

    public string? Gender { get; set; }

    public DateTime? DrLicExDate { get; set; }

    public string? Nationality { get; set; }

    public decimal? LocId { get; set; }

    public string? Street1 { get; set; }

    public string? City { get; set; }

    public string? State { get; set; }

    public string? ZipCode { get; set; }

    public string? HomeTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? WorkTelNo { get; set; }

    public string? WorkEmail { get; set; }

    public string? OtherEmail { get; set; }

    public string? ImageName { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public decimal IncrementId { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? EnrollNo { get; set; }

    public string? BloodGroup { get; set; }

    public string? TallyLedName { get; set; }

    public string? Religion { get; set; }

    public string? Height { get; set; }

    public string? EmpMarkOfIdentification { get; set; }

    public string? Despencery { get; set; }

    public string? DoctorName { get; set; }

    public string? DespenceryAddress { get; set; }

    public string? InsuranceNo { get; set; }

    public byte? IsGrApp { get; set; }

    public byte? IsYearlyBonus { get; set; }

    public decimal? YearlyLeaveDays { get; set; }

    public decimal? YearlyLeaveAmount { get; set; }

    public decimal? YearlyBonusPer { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public DateTime? EmpConfirmDate { get; set; }

    public byte? IsOnProbation { get; set; }

    public decimal? TallyLedId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? BankId { get; set; }

    public decimal? CurrId { get; set; }

    public string? WagesType { get; set; }

    public string? SalaryBasisOn { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? GrossSalary { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }

    public string? PaymentMode { get; set; }

    public string? IncBankAcNo { get; set; }

    public decimal? EmpOt { get; set; }

    public string? EmpOtMinLimit { get; set; }

    public string? EmpOtMaxLimit { get; set; }

    public decimal? EmpLateMark { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpPt { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public byte? EmpPartTime { get; set; }

    public string? LateDeduType { get; set; }

    public string? EmpLateLimit { get; set; }

    public decimal? EmpPtAmount { get; set; }

    public byte? EmpChildran { get; set; }

    public byte? IsMasterRec { get; set; }

    public byte? IsEmpFnf { get; set; }

    public decimal? Probation { get; set; }

    public byte? IsDeputationReminder { get; set; }

    public string DeputationEndDate { get; set; } = null!;

    public string? IncrementType { get; set; }

    public decimal? WorkerAdultNo { get; set; }

    public string? FatherName { get; set; }

    public string? BankBsr { get; set; }

    public string? OldRefNo { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? AlphaCode { get; set; }

    public byte? LeaveInProbation { get; set; }

    public byte IsLwf { get; set; }

    public decimal Ctc { get; set; }

    public decimal CenterId { get; set; }

    public string DbrdCode { get; set; } = null!;

    public string DealerCode { get; set; } = null!;

    public string CcenterRemark { get; set; } = null!;

    public decimal? EmpEarlyMark { get; set; }

    public string? EarlyDeduType { get; set; }

    public string? EmpEarlyLimit { get; set; }

    public string? IfscCode { get; set; }

    public decimal? Expr1 { get; set; }

    public decimal? EmpWeekDayOtRate { get; set; }

    public decimal? EmpWeekOffOtRate { get; set; }

    public decimal? EmpHolidayOtRate { get; set; }

    public decimal EmpPfOpening { get; set; }

    public string? EmpCategory { get; set; }

    public string? EmpUidno { get; set; }

    public string? EmpCast { get; set; }

    public string? EmpAnnivarsaryDate { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? ExtraAbDeduction { get; set; }

    public string CompOffMinHrs { get; set; } = null!;

    public string? MotherName { get; set; }

    public byte IsMetroCity { get; set; }

    public byte IsPhysical { get; set; }

    public byte? Expr2 { get; set; }

    public DateTime? EmpOfferDate { get; set; }

    public decimal? SalDateId { get; set; }

    public byte EmpAutoVpf { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public DateTime? GroupJoiningDate { get; set; }

    public byte MonthlyDeficitAdjustOtHrs { get; set; }

    public decimal FixOtHourRateWd { get; set; }

    public decimal FixOtHourRateWoHo { get; set; }

    public string? IfscCodeTwo { get; set; }

    public decimal? BankIdTwo { get; set; }

    public string? PaymentModeTwo { get; set; }

    public string? IncBankAcNoTwo { get; set; }

    public string? BankBranchName { get; set; }

    public string? BankBranchNameTwo { get; set; }

    public string? CodeDate { get; set; }

    public string? CodeDateFormat { get; set; }

    public string? EmpNameAliasPrimaryBank { get; set; }

    public string? EmpNameAliasPf { get; set; }

    public string? EmpNameAliasPt { get; set; }

    public string? EmpNameAliasSecondaryBank { get; set; }

    public string? EmpNameAliasTax { get; set; }

    public string? EmpNameAliasEsic { get; set; }

    public string? EmpNameAliasSalary { get; set; }

    public decimal EmpNoticePeriod { get; set; }

    public string? EmpShoeSize { get; set; }

    public string? EmpPentSize { get; set; }

    public string? EmpShirtSize { get; set; }

    public string? EmpDressCode { get; set; }

    public string? EmpCanteenCode { get; set; }

    public decimal ThanaId { get; set; }

    public string? Tehsil { get; set; }

    public string? District { get; set; }

    public decimal ThanaIdWok { get; set; }

    public string? TehsilWok { get; set; }

    public string? DistrictWok { get; set; }

    public int? SkillTypeId { get; set; }

    public string? AboutMe { get; set; }

    public string? UanNo { get; set; }

    public decimal CompOffWoAppDays { get; set; }

    public decimal CompOffWoAvailDays { get; set; }

    public decimal CompOffWdAppDays { get; set; }

    public decimal CompOffWdAvailDays { get; set; }

    public decimal CompOffHoAppDays { get; set; }

    public decimal CompOffHoAvailDays { get; set; }

    public DateTime? DateOfRetirement { get; set; }

    public decimal SalaryDependsOnProduction { get; set; }

    public string? RationCardType { get; set; }

    public string? RationCardNo { get; set; }

    public string? VehicleNo { get; set; }

    public decimal IsOnTraining { get; set; }

    public decimal? TrainingMonth { get; set; }

    public string? AadharCardNo { get; set; }

    public DateTime? ActualDateOfBirth { get; set; }

    public byte IsPfTrust { get; set; }

    public string PfTrustNo { get; set; } = null!;

    public string? SystemDate { get; set; }

    public string? ExtensionNo { get; set; }

    public string? LinkedInId { get; set; }

    public string? TwitterId { get; set; }

    public byte CustomerAudit { get; set; }

    public decimal ManagerProbation { get; set; }

    public DateTime? PfStartDate { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public string SalesCode { get; set; } = null!;

    public string? SignatureImageName { get; set; }

    public decimal LeaveEncashWorkingDays { get; set; }

    public decimal PhysicalPercent { get; set; }

    public byte IsProbationMonthDays { get; set; }

    public byte IsTraineeMonthDays { get; set; }

    public decimal WeekOffCompOffAvailAfterDays { get; set; }

    public decimal HolidayCompOffAvailAfterDays { get; set; }

    public decimal WeekdayCompOffAvailAfterDays { get; set; }

    public string? SubVerticalName { get; set; }

    public string? VerticalName { get; set; }

    public string? SegmentName { get; set; }

    public string? CatName { get; set; }
}
