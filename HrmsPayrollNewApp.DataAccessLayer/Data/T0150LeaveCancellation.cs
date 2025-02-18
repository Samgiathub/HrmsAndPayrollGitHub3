using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150LeaveCancellation
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

    public string? Mcomment { get; set; }

    public decimal? AEmpId { get; set; }

    public string? DayType { get; set; }

    public decimal? ActualLeaveDay { get; set; }

    public string? CompoffWorkDate { get; set; }

    public byte BackdatedCancel { get; set; }
}
