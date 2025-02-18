using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0110GoalSettingSectionWithoutDepe
{
    public int GssId { get; set; }

    public int? GssGoalSettingId { get; set; }

    public int? GssSectionId { get; set; }

    public int? GssWeightageTypeId { get; set; }

    public int? GssWeightageValue { get; set; }

    public int? GssStatusId { get; set; }

    public int? GssMonthId { get; set; }

    public int? CmpId { get; set; }

    public int? SectionIndex { get; set; }
}
