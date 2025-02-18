using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsTblTargetAchivement
{
    public int TaId { get; set; }

    public int? TargetAchiveid { get; set; }

    public int? LaLevelId { get; set; }

    public int? LaLevelValue { get; set; }

    public int? LaSectionId { get; set; }

    public int? LaGoalId { get; set; }

    public int? LaSubGoalId { get; set; }

    public int? CmpId { get; set; }
}
