using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100UniformEmpIssue
{
    public decimal UniAprId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? IssueDate { get; set; }

    public decimal? UniId { get; set; }

    public decimal? UniPieces { get; set; }

    public decimal? UniRate { get; set; }

    public decimal? UniAmount { get; set; }

    public decimal? UniDeductInstallment { get; set; }

    public decimal? UniDeductAmount { get; set; }

    public decimal? UniRefundInstallment { get; set; }

    public decimal? UniRefundAmount { get; set; }

    public decimal? DeductPendingAmount { get; set; }

    public decimal? RefundPendingAmount { get; set; }

    public string? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? IpAddress { get; set; }

    public decimal? UniStitchingPrice { get; set; }

    public DateTime? DeductionStartDate { get; set; }

    public DateTime? RefundStartDate { get; set; }

    public decimal? NewReqAprId { get; set; }
}
