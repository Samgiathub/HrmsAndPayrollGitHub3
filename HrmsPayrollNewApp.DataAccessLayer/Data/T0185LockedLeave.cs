using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0185LockedLeave
{
    public int TranId { get; set; }

    public int LockId { get; set; }

    public int EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public int LeaveId { get; set; }

    public string LeaveType { get; set; } = null!;

    public DateTime? FromTime { get; set; }

    public DateTime? ToTime { get; set; }

    public decimal LeaveDays { get; set; }

    public bool IsPaid { get; set; }

    public bool IsCompOff { get; set; }

    public bool IsOd { get; set; }

    public int LeaveApprovalId { get; set; }

    public virtual T0180LockedAttendance Lock { get; set; } = null!;
}
