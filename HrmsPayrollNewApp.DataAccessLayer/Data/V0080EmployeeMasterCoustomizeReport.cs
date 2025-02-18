using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmployeeMasterCoustomizeReport
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpCode { get; set; }

    public string FirstName { get; set; } = null!;

    public string SecondName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? Shift { get; set; }

    public string? Department { get; set; }

    public string? Gender { get; set; }

    public string? Status { get; set; }

    public string MaritalStatus { get; set; } = null!;

    public string? Grade { get; set; }

    public string? FullName { get; set; }

    public string? EmpLeft { get; set; }

    public string? HomeTelephone { get; set; }

    public string? MobileNo { get; set; }

    public string? DateOfBirth { get; set; }

    public string? ManagerName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? WorkingTown { get; set; }

    public string? WorkingRegion { get; set; }

    public string? WorkingPostbox { get; set; }

    public string? WorkingAddress { get; set; }

    public string? LeftDate { get; set; }

    public string? PersonalEmail { get; set; }

    public string? WorkingEmail { get; set; }

    public string? WorkTelephone { get; set; }

    public string? PermanentPostbox { get; set; }

    public string? PermanentRegion { get; set; }

    public string? PermanentTown { get; set; }

    public string? PermanentAddress { get; set; }

    public string? Nationality { get; set; }

    public string? DrivingLicenseExpiry { get; set; }

    public string? PanNo { get; set; }

    public string? DrivingLicense { get; set; }

    public string? EsicNo { get; set; }

    public string? PfNo { get; set; }

    public string? Designation { get; set; }

    public string? CompanyName { get; set; }

    public string? Branch { get; set; }

    public string? ImageName { get; set; }

    public decimal EnrollNo { get; set; }

    public string? InitialName { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? OtApplicable { get; set; }

    public string? EmpOtMinLimit { get; set; }

    public string? EmpOtMaxLimit { get; set; }

    public decimal? LateMarkApplicable { get; set; }

    public decimal? PtApplicable { get; set; }

    public decimal? FullPfApplicable { get; set; }

    public decimal? FixSalaryApplicable { get; set; }

    public byte? EmpPartTime { get; set; }

    public string? LateDeduType { get; set; }

    public string? EmpLateLimit { get; set; }

    public decimal? PtAmount { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public string? BankAcountNo { get; set; }

    public string? PaymentMode { get; set; }

    public string? SalaryBasisOn { get; set; }

    public string? WagesType { get; set; }

    public string? BloodGroup { get; set; }

    public string? Religion { get; set; }

    public string? Height { get; set; }

    public string? MarkOfIdentification { get; set; }

    public string? Despencery { get; set; }

    public string? DoctorName { get; set; }

    public string? DespenceryAddress { get; set; }

    public string? InsuranceNo { get; set; }

    public byte? GratuityApplicable { get; set; }

    public byte? YearlyBonusApplicable { get; set; }

    public decimal? YearlyLeaveDays { get; set; }

    public decimal? YearlyLeaveAmount { get; set; }

    public string? DateOfConfirmation { get; set; }

    public byte? OnProbation { get; set; }

    public decimal? ProbationPeriod { get; set; }

    public decimal? YearlyBonusPercentage { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? IncrementId { get; set; }
}
