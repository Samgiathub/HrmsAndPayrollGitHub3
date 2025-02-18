using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsFrqWiseTargetAchievement
{
    public int FtaId { get; set; }

    public int? FreqId { get; set; }

    public string? Month { get; set; }

    public int? Achievement { get; set; }

    public int? EmpId { get; set; }

    public string? AchievementId { get; set; }

    public int? TargetAchiveid { get; set; }

    public int? ActualAchievement { get; set; }

    public int? LevelAssignid { get; set; }

    public int? CmpId { get; set; }
}
