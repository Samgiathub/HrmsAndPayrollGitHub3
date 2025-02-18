using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmployeeDetail
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

    public string? BranchName { get; set; }

    public string? LocName { get; set; }

    public string? AlphaCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? OldRefNo { get; set; }
}
