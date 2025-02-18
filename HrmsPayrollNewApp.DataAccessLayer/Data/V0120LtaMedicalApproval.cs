using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LtaMedicalApproval
{
    public decimal LmAprId { get; set; }

    public decimal LmAppId { get; set; }

    public DateTime? AprDate { get; set; }

    public decimal? AprAmount { get; set; }

    public string? AprComments { get; set; }

    public string? AprCode { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? SystemDate { get; set; }

    public int? AprStatus { get; set; }

    public int? TypeId { get; set; }

    public decimal? LoginId { get; set; }

    public string? LoginName { get; set; }

    public decimal? BalanceOpening { get; set; }

    public decimal? BalanceClosing { get; set; }

    public string? Status { get; set; }

    public string? TypeName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpCode { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public string? LeaveFromDate { get; set; }

    public string? LeaveToDate { get; set; }

    public int? NoOfDays { get; set; }

    public int? EffectSalary { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string EffectOnSalary { get; set; } = null!;

    public decimal? SalTranId { get; set; }

    public string PaidStatus { get; set; } = null!;

    public decimal PStatus { get; set; }

    public decimal PaidAmount { get; set; }

    public decimal? PendingAmount { get; set; }
}
