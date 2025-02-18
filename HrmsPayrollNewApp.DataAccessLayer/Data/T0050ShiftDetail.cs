using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ShiftDetail
{
    public decimal ShiftTranId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? FromHour { get; set; }

    public decimal? ToHour { get; set; }

    public decimal MinimumHour { get; set; }

    public decimal? CalculateDays { get; set; }

    public decimal OtApplicable { get; set; }

    public decimal? FixOtHours { get; set; }

    public decimal? FixWHours { get; set; }

    public byte? OtStartTime { get; set; }

    public decimal? Rate { get; set; }

    public byte OtEndTime { get; set; }

    public byte WorkingHrsEndTime { get; set; }

    public byte WorkingHrsStTime { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040ShiftMaster Shift { get; set; } = null!;
}
