using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0185LockedInOut
{
    public int TranId { get; set; }

    public int LockId { get; set; }

    public int EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public int? DurationInSec { get; set; }

    public int? ShiftId { get; set; }

    public int? EmpOt { get; set; }

    public decimal? PDays { get; set; }

    public decimal? OtSec { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? ShiftStartTime { get; set; }

    public byte? ShiftChange { get; set; }

    public int? WeekoffOtSec { get; set; }

    public int? HolidayOtSec { get; set; }

    public byte? ChkBySuperior { get; set; }

    public DateTime? OutTime { get; set; }

    public DateTime? ShiftEndTime { get; set; }

    public decimal? GatePassDeductDays { get; set; }

    public decimal? LeaveDays { get; set; }

    public decimal? WDays { get; set; }

    public decimal? HDays { get; set; }

    public int? LateSec { get; set; }

    public int? EarlySec { get; set; }

    public string? Status1 { get; set; }

    public string? Status2 { get; set; }

    public decimal? LateSalDeduDays { get; set; }

    public decimal? EarlySalDeduDays { get; set; }

    public virtual T0180LockedAttendance Lock { get; set; } = null!;
}
