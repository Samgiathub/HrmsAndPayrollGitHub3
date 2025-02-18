using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095IncrementHrm
{
    public string? EmpFullName { get; set; }

    public decimal IncrementId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

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

    public string? IncrementType { get; set; }

    public DateTime IncrementDate { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }

    public string? PaymentMode { get; set; }

    public string? IncBankAcNo { get; set; }

    public decimal? EmpOt { get; set; }

    public string? EmpOtMinLimit { get; set; }

    public string? EmpOtMaxLimit { get; set; }

    public decimal? IncrementPer { get; set; }

    public decimal? IncrementAmount { get; set; }

    public decimal? PreBasicSalary { get; set; }

    public decimal? PreGrossSalary { get; set; }

    public string? IncrementComments { get; set; }

    public decimal? EmpLateMark { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpPt { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpLeft { get; set; }

    public string? BranchName { get; set; }

    public string GrdName { get; set; } = null!;

    public decimal? YearlyBonusAmount { get; set; }

    public DateTime? DeputationEndDate { get; set; }

    public decimal? LoginId { get; set; }

    public string? EmpLateLimit { get; set; }

    public byte? IsDeputationReminder { get; set; }

    public byte? EmpPartTime { get; set; }

    public string? LateDeduType { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }
}
