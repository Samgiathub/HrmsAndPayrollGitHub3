using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100UniformEmpIssue
{
    public decimal UniAprId { get; set; }

    public decimal? UniId { get; set; }

    public string? UniName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? IssueDate { get; set; }

    public decimal? UniPiece { get; set; }

    public decimal? UniRate { get; set; }

    public decimal? UniAmount { get; set; }

    public decimal? UniDedInstall { get; set; }

    public decimal? UniRefInstall { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal? UniDeductAmount { get; set; }

    public decimal? DeductPendingAmount { get; set; }

    public decimal? RefundPendingAmount { get; set; }

    public decimal? UniRefundAmount { get; set; }
}
