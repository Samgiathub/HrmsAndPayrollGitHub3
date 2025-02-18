using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblTargetAchiveValue
{
    public int TaId { get; set; }

    public int? TargetAchiveid { get; set; }

    public int? TaLevelId { get; set; }

    public int? TaLevelValue { get; set; }

    public int? TaSectionId { get; set; }

    public int? TaGoalId { get; set; }

    public int? TaSubGoalId { get; set; }
}
