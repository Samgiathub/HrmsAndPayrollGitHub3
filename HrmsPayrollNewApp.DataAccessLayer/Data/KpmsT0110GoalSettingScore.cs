using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0110GoalSettingScore
{
    public int GsbId { get; set; }

    public int? GsbGoalSettingId { get; set; }

    public string? GsbTitle { get; set; }

    public double? GsbMin { get; set; }

    public double? GsbMax { get; set; }

    public int? CmpId { get; set; }
}
