using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0100LevelAssign
{
    public int LevelAssignId { get; set; }

    public int? SectionId { get; set; }

    public int? GoalId { get; set; }

    public int? SubGoalId { get; set; }

    public int? WeightageType { get; set; }

    public int? TargetValues { get; set; }

    public string? LevelValues { get; set; }

    public string? LevlGrpValues { get; set; }

    public int? GoalSettingId { get; set; }

    public int? GoalSheetId { get; set; }

    public int? GoalAllotmentId { get; set; }

    public int? CmpId { get; set; }
}
