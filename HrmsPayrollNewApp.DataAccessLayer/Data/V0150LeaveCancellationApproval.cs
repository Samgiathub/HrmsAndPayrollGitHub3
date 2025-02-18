using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150LeaveCancellationApproval
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? LeaveApprovalId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? LeavePeriodApp { get; set; }

    public byte IsApprove { get; set; }

    public string? Comment { get; set; }

    public DateTime RequestDate { get; set; }

    public string Mcomment { get; set; } = null!;

    public decimal? AEmpId { get; set; }

    public string? DayType { get; set; }

    public decimal? ActualLeaveDay { get; set; }

    public string LeaveName { get; set; } = null!;

    public decimal LeaveOpening { get; set; }

    public decimal LeaveCredit { get; set; }

    public decimal LeaveUsed { get; set; }

    public decimal LeaveClosing { get; set; }

    public string LeaveApplicationId { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? SEmpFullName { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string LeaveCode { get; set; } = null!;

    public int ApplyHourly { get; set; }

    public decimal LeaveUsedComp { get; set; }
}
