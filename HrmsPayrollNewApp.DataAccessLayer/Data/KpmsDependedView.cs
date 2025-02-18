using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsDependedView
{
    public int GsgId { get; set; }

    public int? GsgGoalSettingId { get; set; }

    public int? GsgGoalSettingSectionId { get; set; }

    public int? GsgGoalId { get; set; }

    public int? GsgSubGoalId { get; set; }

    public int? GsgFrequecyId { get; set; }

    public int? GsgWeightageTypeId { get; set; }

    public int? GsgWeightageValue { get; set; }

    public int? GsgStatusId { get; set; }

    public bool? GsgIsDependency { get; set; }

    public int? GsgDependGoalId { get; set; }

    public int? GsgDependTypeId { get; set; }

    public int? GsgDependValue { get; set; }

    public int? CmpId { get; set; }
}
