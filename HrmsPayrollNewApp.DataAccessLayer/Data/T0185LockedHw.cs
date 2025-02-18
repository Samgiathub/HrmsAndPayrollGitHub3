using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0185LockedHw
{
    public int TranId { get; set; }

    public int LockId { get; set; }

    public int EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string DayName { get; set; } = null!;

    public decimal HwDay { get; set; }

    public bool? IsPComp { get; set; }

    public bool? IsHalf { get; set; }

    public bool IsCancel { get; set; }

    public string? CancelReason { get; set; }

    public string Flag { get; set; } = null!;

    public virtual T0180LockedAttendance Lock { get; set; } = null!;
}
