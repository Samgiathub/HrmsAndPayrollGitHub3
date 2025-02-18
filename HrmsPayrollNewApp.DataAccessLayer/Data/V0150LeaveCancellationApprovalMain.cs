using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150LeaveCancellationApprovalMain
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? LeaveApprovalId { get; set; }

    public decimal LeaveId { get; set; }

    public string? ForDate { get; set; }

    public byte IsApprove { get; set; }

    public string Mcomment { get; set; } = null!;

    public string LeaveName { get; set; } = null!;

    public string LeaveApplicationId { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? SEmpFullName { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? LeavePeriod { get; set; }

    public decimal BranchId { get; set; }

    public decimal? AEmpId { get; set; }

    public decimal? TranId { get; set; }

    public int ApplyHourly { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string? LForDate { get; set; }

    public decimal? SEmpId { get; set; }
}
