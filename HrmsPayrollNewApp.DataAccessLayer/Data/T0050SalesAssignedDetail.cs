using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050SalesAssignedDetail
{
    public decimal SadTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TargetTranId { get; set; }

    public decimal WeekTranId { get; set; }

    public decimal? AssignedTarget { get; set; }

    public decimal? AchievedTarget { get; set; }

    public decimal? AchievedPercent { get; set; }

    public virtual T0040SalesAssignedTarget TargetTran { get; set; } = null!;

    public virtual T0040SalesWeekMaster WeekTran { get; set; } = null!;
}
