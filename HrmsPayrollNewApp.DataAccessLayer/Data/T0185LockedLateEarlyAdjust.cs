using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0185LockedLateEarlyAdjust
{
    public int TranId { get; set; }

    public int LockId { get; set; }

    public int CmpId { get; set; }

    public int EmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public int SortId { get; set; }

    public int LeaveId { get; set; }

    public decimal LastBalance { get; set; }

    public string Flag { get; set; } = null!;

    public decimal AdjustDays { get; set; }

    public virtual T0180LockedAttendance Lock { get; set; } = null!;
}
