using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0020InactiveUserHistory
{
    public decimal HistoryId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoginId { get; set; }

    public string? Reason { get; set; }

    public DateTime SystemDate { get; set; }

    public string ActiveStatus { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public DateTime DateOfJoin { get; set; }

    public string? BasicSalary { get; set; }

    public string? ShiftName { get; set; }

    public string? DeptName { get; set; }

    public string Gender { get; set; } = null!;

    public string? TypeName { get; set; }

    public string? MaritalStatus { get; set; }

    public string? GrdName { get; set; }

    public string? EmpFullNameNew { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public string? WorkTelNo { get; set; }

    public string? MobileNo { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string EmpFullNameSuperior { get; set; } = null!;

    public decimal EmpSuperior { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public string? PresentStreet { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public string OtherEmail { get; set; } = null!;

    public string WorkEmail { get; set; } = null!;

    public string? HomeTelNo { get; set; }

    public string? ZipCode { get; set; }

    public string? State { get; set; }

    public string? City { get; set; }

    public string? Street1 { get; set; }

    public string? Nationality { get; set; }

    public DateTime? DrLicExDate { get; set; }

    public string? PanNo { get; set; }

    public string? DrLicNo { get; set; }

    public string? SinNo { get; set; }

    public string? SsnNo { get; set; }

    public decimal? DesigId { get; set; }

    public string? DesigName { get; set; }

    public decimal? DefId { get; set; }

    public string? CmpName { get; set; }

    public decimal? DeptId { get; set; }

    public string? BranchName { get; set; }

    public string POtherMail { get; set; } = null!;

    public string PWorkMail { get; set; } = null!;

    public decimal? GrdId { get; set; }

    public string? ImageName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal EnrollNo { get; set; }

    public string? Initial { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? EmpOt { get; set; }

    public string? EmpOtMinLimit { get; set; }

    public string? EmpOtMaxLimit { get; set; }

    public decimal? EmpLateMark { get; set; }

    public decimal? EmpPt { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public byte? EmpPartTime { get; set; }

    public string? LateDeduType { get; set; }

    public string? EmpLateLimit { get; set; }

    public decimal? EmpPtAmount { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public string? IncBankAcNo { get; set; }

    public string? PaymentMode { get; set; }

    public string? SalaryBasisOn { get; set; }

    public string? WagesType { get; set; }

    public decimal? BankId { get; set; }

    public decimal? TypeId { get; set; }

    public string? BloodGroup { get; set; }

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

    public DateTime? EmpConfirmDate { get; set; }

    public byte? IsOnProbation { get; set; }

    public decimal? Probation { get; set; }

    public decimal? YearlyBonusPer { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? IncrementId { get; set; }

    public decimal? ParentId { get; set; }

    public byte? IsMain { get; set; }

    public string? LocName { get; set; }

    public DateTime? RegAcceptDate { get; set; }

    public decimal? LocId { get; set; }

    public string? SupMobileNo { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? AlphaCode { get; set; }

    public string? OldRefNo { get; set; }

    public decimal EmpCode { get; set; }

    public string? IfscCode { get; set; }

    public string? BankBsr { get; set; }

    public byte? LeaveInProbation { get; set; }
}
