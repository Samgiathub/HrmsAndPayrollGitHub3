using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100BreakTime
{
    public decimal BreakId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal DeptId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string BreakStartTime { get; set; } = null!;

    public string BreakEndTime { get; set; } = null!;

    public string BreakDuration { get; set; } = null!;

    public byte Type { get; set; }
}
