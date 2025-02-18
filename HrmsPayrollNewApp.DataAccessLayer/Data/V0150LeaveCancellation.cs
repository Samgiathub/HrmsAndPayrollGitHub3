using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150LeaveCancellation
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? LeaveApprovalId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? LeavePeriod { get; set; }

    public byte IsApprove { get; set; }

    public string? Comment { get; set; }

    public DateTime RequestDate { get; set; }

    public string LeaveName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? Mcomment { get; set; }

    public string? DayType { get; set; }

    public decimal? ActualLeaveDay { get; set; }

    public decimal BranchId { get; set; }

    public string LeaveCode { get; set; } = null!;

    public int ApplyHourly { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? BranchName { get; set; }
}
