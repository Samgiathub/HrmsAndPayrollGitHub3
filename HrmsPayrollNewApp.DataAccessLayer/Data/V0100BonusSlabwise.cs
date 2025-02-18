using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100BonusSlabwise
{
    public decimal? GrossSalary { get; set; }

    public decimal? EligibleDay { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? WorkingDays { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal TranId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? BonusComments { get; set; }

    public decimal? BonusEffectYear { get; set; }

    public decimal? BonusEffectMonth { get; set; }

    public decimal? BonusEffectOnSal { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? TotalBonusAmount { get; set; }

    public decimal? AdditionalAmount { get; set; }

    public decimal? BonusAmount { get; set; }

    public decimal? PaidDay { get; set; }

    public decimal? LeaveSlab { get; set; }

    public decimal ExtraPaidDays { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string? DateOfJoin { get; set; }

    public string? PaymentMode { get; set; }

    public string? IncBankAcNo { get; set; }

    public string? BankName { get; set; }
}
