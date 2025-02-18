using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120RcApproval
{
    public decimal RcAprId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? RcAppId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RcId { get; set; }

    public DateTime? AprDate { get; set; }

    public decimal? AprAmount { get; set; }

    public decimal? TaxableExemptionAmount { get; set; }

    public string? AprComments { get; set; }

    public byte? AprStatus { get; set; }

    public decimal? RcAprEffectInSalary { get; set; }

    public string? RcAprChequeNo { get; set; }

    public string? PaymentMode { get; set; }

    public int CreateBy { get; set; }

    public DateTime DateCreated { get; set; }

    public int? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public DateTime? PaymentDate { get; set; }

    public string? Status { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpCode { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public string? LeaveFromDate { get; set; }

    public string? LeaveToDate { get; set; }
}
