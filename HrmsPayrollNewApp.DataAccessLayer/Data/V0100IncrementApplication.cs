using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100IncrementApplication
{
    public string? EmpFullName { get; set; }

    public decimal AppId { get; set; }

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

    public string? BasicSalary { get; set; }

    public string? GrossSalary { get; set; }

    public string? IncrementType { get; set; }

    public DateTime IncrementDate { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }

    public string? PaymentMode { get; set; }

    public string? IncBankAcNo { get; set; }

    public decimal? EmpOt { get; set; }

    public string? EmpOtMinLimit { get; set; }

    public string? EmpOtMaxLimit { get; set; }

    public decimal? IncrementPer { get; set; }

    public string? IncrementAmount { get; set; }

    public string? PreBasicSalary { get; set; }

    public string? PreGrossSalary { get; set; }

    public string? IncrementComments { get; set; }

    public decimal? EmpLateMark { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpPt { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpLeft { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public DateTime? DeputationEndDate { get; set; }

    public string? DesigName { get; set; }

    public string? Ctc { get; set; }

    public decimal CenterId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? PreCtcSalary { get; set; }

    public string? IncermentAmountGross { get; set; }

    public string? IncermentAmountCtc { get; set; }

    public byte IncrementMode { get; set; }

    public byte? IsPhysical { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public byte EmpAutoVpf { get; set; }

    public DateTime? GroupJoiningDate { get; set; }

    public decimal? SalDateId { get; set; }

    public decimal ReasonId { get; set; }

    public string? ReasonName { get; set; }

    public string? AppStatus { get; set; }

    public DateTime? SystemDate { get; set; }

    public byte CustomerAudit { get; set; }

    public string? SalesCode { get; set; }

    public byte? IsPieceTransSalary { get; set; }

    public decimal? BandId { get; set; }

    public bool? IsPradhanMantri { get; set; }

    public bool? Is1timePfMember { get; set; }

    public string? Remarks { get; set; }
}
