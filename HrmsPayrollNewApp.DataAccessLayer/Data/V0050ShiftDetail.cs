using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050ShiftDetail
{
    public decimal ShiftTranId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? FromHour { get; set; }

    public decimal? ToHour { get; set; }

    public decimal MinimumHour { get; set; }

    public decimal? CalculateDays { get; set; }

    public decimal OtApplicable { get; set; }

    public string ShiftName { get; set; } = null!;

    public byte? OtStartTime { get; set; }

    public byte? IncAutoShift { get; set; }

    public byte OtEndTime { get; set; }
}
