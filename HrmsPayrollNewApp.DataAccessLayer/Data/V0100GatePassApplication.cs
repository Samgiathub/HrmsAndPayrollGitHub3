using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100GatePassApplication
{
    public decimal AppId { get; set; }

    public DateTime AppDate { get; set; }

    public DateTime ForDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public string Duration { get; set; } = null!;

    public string? Remarks { get; set; }

    public decimal? AppUserId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? AppStatus { get; set; }

    public decimal CmpId { get; set; }

    public string? ReasonName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpId { get; set; }

    public decimal ReasonId { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal GrdId { get; set; }

    public string GrdName { get; set; } = null!;

    public decimal? DeptId { get; set; }

    public string? DeptName { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime FromDateTime { get; set; }

    public DateTime ToDateTime { get; set; }

    public int AprId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public DateTime? ActualOutTime { get; set; }

    public DateTime? ActualInTime { get; set; }

    public string? ActualDuration { get; set; }
}
