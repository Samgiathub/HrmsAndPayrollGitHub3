using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpMasterClone
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? BankId { get; set; }

    public decimal EmpCode { get; set; }

    public string? Initial { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public decimal? CurrId { get; set; }

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

    public decimal? BasicSalary { get; set; }

    public string? ImageName { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public decimal? IncrementId { get; set; }

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

    public byte? IsEmpFnf { get; set; }

    public byte? IsOnProbation { get; set; }

    public decimal? TallyLedId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? Probation { get; set; }

    public decimal? WorkerAdultNo { get; set; }

    public string? FatherName { get; set; }

    public string? BankBsr { get; set; }

    public string? ProductName { get; set; }

    public string? OldRefNo { get; set; }

    public int? ChgPwd { get; set; }

    public string? AlphaCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? IfscCode { get; set; }

    public byte? LeaveInProbation { get; set; }

    public byte? IsLwf { get; set; }

    public string? DbrdCode { get; set; }

    public string? DealerCode { get; set; }

    public string? CcenterRemark { get; set; }

    public decimal EmpPfOpening { get; set; }

    public string? EmpCategory { get; set; }

    public string? EmpUidno { get; set; }

    public string? EmpCast { get; set; }

    public string? EmpAnnivarsaryDate { get; set; }

    public decimal? ExtraAbDeduction { get; set; }

    public string CompOffMinHrs { get; set; } = null!;

    public string? MotherName { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public DateTime? GroupJoiningDate { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? BankIdTwo { get; set; }

    public string? IfscCodeTwo { get; set; }

    public string? CodeDate { get; set; }

    public string? CodeDateFormat { get; set; }

    public string? EmpNameAliasPrimaryBank { get; set; }

    public string? EmpNameAliasSecondaryBank { get; set; }

    public string? EmpNameAliasPf { get; set; }

    public string? EmpNameAliasPt { get; set; }

    public string? EmpNameAliasTax { get; set; }

    public string? EmpNameAliasEsic { get; set; }

    public string? EmpNameAliasSalary { get; set; }

    public decimal EmpNoticePeriod { get; set; }

    public DateTime? SystemDateJoinLeft { get; set; }

    public string? EmpCanteenCode { get; set; }

    public string? EmpDressCode { get; set; }

    public string? EmpShirtSize { get; set; }

    public string? EmpPentSize { get; set; }

    public string? EmpShoeSize { get; set; }

    public decimal ThanaId { get; set; }

    public string? Tehsil { get; set; }

    public string? District { get; set; }

    public decimal ThanaIdWok { get; set; }

    public string? TehsilWok { get; set; }

    public string? DistrictWok { get; set; }

    public int? SkillTypeId { get; set; }

    public decimal CompOffWoAppDays { get; set; }

    public decimal CompOffWoAvailDays { get; set; }

    public decimal CompOffWdAppDays { get; set; }

    public decimal CompOffWdAvailDays { get; set; }

    public decimal CompOffHoAppDays { get; set; }

    public decimal CompOffHoAvailDays { get; set; }

    public DateTime? DateOfRetirement { get; set; }

    public decimal SalaryDependsOnProduction { get; set; }

    public decimal IsOnTraining { get; set; }

    public decimal? TrainingMonth { get; set; }

    public string? AadharCardNo { get; set; }

    public decimal IsOnTraning { get; set; }

    public decimal Traning { get; set; }

    public string? InductionTraining { get; set; }

    public decimal? HolidayCompOffAvailAfterDays { get; set; }

    public decimal? WeekOffCompOffAvailAfterDays { get; set; }

    public decimal? WeekdayCompOffAvailAfterDays { get; set; }

    public string? EmpCastJoin { get; set; }

    public string? EmpFavSportId { get; set; }

    public string? EmpFavSportName { get; set; }

    public string? EmpHobbyId { get; set; }

    public string? EmpHobbyName { get; set; }

    public string? EmpFavFood { get; set; }

    public string? EmpFavRestro { get; set; }

    public string? EmpFavTrvDestination { get; set; }

    public string? EmpFavFestival { get; set; }

    public string? EmpFavSportPerson { get; set; }

    public string? EmpFavSinger { get; set; }
}
