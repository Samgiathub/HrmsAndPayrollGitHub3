using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpLateEmpDay
{
    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public DateTime? ShiftStTime { get; set; }

    public DateTime? ShiftEndTime { get; set; }

    public decimal? LateSec { get; set; }

    public decimal? EarlySec { get; set; }

    public string? LateLimit { get; set; }

    public string? EarlyLimit { get; set; }

    public decimal? LateDeduction { get; set; }

    public decimal? EarlyDeduction { get; set; }

    public string? ExemptFlag { get; set; }
}
