using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewReimbursementFinalNLevelApproval
{
    public decimal CmpId { get; set; }

    public string AdName { get; set; } = null!;

    public string Taxable { get; set; } = null!;

    public decimal RcAppId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime AppDate { get; set; }

    public decimal AppTaxFreeAmount { get; set; }

    public decimal? AppTaxAmount { get; set; }

    public decimal? AprTaxFreeAmount { get; set; }

    public decimal? AprTaxAmount { get; set; }

    public string? AppComments { get; set; }

    public byte? AppStatus { get; set; }

    public DateTime? LeaveFromDate { get; set; }

    public DateTime? LeaveToDate { get; set; }

    public decimal? Days { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string Status { get; set; } = null!;

    public decimal? RcAprId { get; set; }

    public string? Fy { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? BranchId { get; set; }

    public byte? IsManagerRecord { get; set; }

    public decimal? SEmpIdA { get; set; }

    public byte SubmitFlag { get; set; }
}
