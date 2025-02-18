using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0110TargetAchivement
{
    public int TargetAchiveid { get; set; }

    public int? Sectionid { get; set; }

    public int? Goalid { get; set; }

    public int? Subgoalid { get; set; }

    public int Targetvalue { get; set; }

    public int? FreqId { get; set; }

    public int EmpId { get; set; }

    public int? REmpId { get; set; }

    public int? SchemeId { get; set; }

    public int? GoalAltId { get; set; }

    public int? WeightageType { get; set; }

    public int? Achievement { get; set; }

    public string? Month { get; set; }

    public int? LevelAssignid { get; set; }

    public int? ActualTarget { get; set; }

    public int? CmpId { get; set; }

    public string? MonthNum { get; set; }

    public int? GoalSettingId { get; set; }
}
