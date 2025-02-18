using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ShiftMaster
{
    public decimal ShiftId { get; set; }

    public decimal CmpId { get; set; }

    public string ShiftName { get; set; } = null!;

    public string ShiftStTime { get; set; } = null!;

    public string ShiftEndTime { get; set; } = null!;

    public string ShiftDur { get; set; } = null!;

    public string? FStTime { get; set; }

    public string? FEndTime { get; set; }

    public string? FDuration { get; set; }

    public string? SStTime { get; set; }

    public string? SEndTime { get; set; }

    public string? SDuration { get; set; }

    public string? TStTime { get; set; }

    public string? TEndTime { get; set; }

    public string? TDuration { get; set; }

    public byte? IncAutoShift { get; set; }

    public byte IsHalfDay { get; set; }

    public string? WeekDay { get; set; }

    public string? HalfStTime { get; set; }

    public string? HalfEndTime { get; set; }

    public string? HalfDur { get; set; }

    public string? HalfMinDuration { get; set; }

    public byte IsSplitShift { get; set; }

    public byte IsTrainingShift { get; set; }

    public decimal SplitShiftRate { get; set; }

    public decimal SplitShiftRatio { get; set; }

    public byte DeduHourSecondBreak { get; set; }

    public byte DeduHourThirdBreak { get; set; }

    public byte AutoShiftGroup { get; set; }

    public decimal ShiftWeekDayOtRate { get; set; }

    public decimal ShiftWeekOffOtRate { get; set; }

    public decimal ShiftHolidayOtRate { get; set; }

    public byte IsInActive { get; set; }

    public DateTime? InActiveDate { get; set; }

    public byte? IsNightShift { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050ShiftDetail> T0050ShiftDetails { get; set; } = new List<T0050ShiftDetail>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0100EmpShiftDetail> T0100EmpShiftDetails { get; set; } = new List<T0100EmpShiftDetail>();

    public virtual ICollection<T0210MonthlyPresentCalculation> T0210MonthlyPresentCalculations { get; set; } = new List<T0210MonthlyPresentCalculation>();
}
