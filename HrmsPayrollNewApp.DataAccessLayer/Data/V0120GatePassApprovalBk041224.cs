using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120GatePassApprovalBk041224
{
    public decimal? BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? IncrementId { get; set; }

    public string? AppStatus { get; set; }

    public decimal AppId { get; set; }

    public decimal? AprId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public string? Duration { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal Expr1 { get; set; }

    public string? ReasonName { get; set; }

    public string? ActualOutTime { get; set; }

    public string? ActualInTime { get; set; }

    public string? ActualDuration { get; set; }

    public string? ImageName { get; set; }

    public string? Remarks { get; set; }
}
