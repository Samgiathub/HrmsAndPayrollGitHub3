using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpData1
{
    public decimal? EmpId { get; set; }

    public decimal? IncId { get; set; }

    public string? ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public string? LateHour { get; set; }

    public string? MaxLateLimit { get; set; }

    public decimal? TotalDuration { get; set; }
}
