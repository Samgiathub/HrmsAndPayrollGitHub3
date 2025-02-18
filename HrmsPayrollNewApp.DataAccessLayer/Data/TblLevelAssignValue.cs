using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblLevelAssignValue
{
    public int LaId { get; set; }

    public int? LaAllotmentId { get; set; }

    public int? LaLevelAssignId { get; set; }

    public int? LaLevelId { get; set; }

    public int? LaLevelValue { get; set; }

    public int? LaSectionId { get; set; }

    public int? LaGoalId { get; set; }

    public int? LaSubGoalId { get; set; }

    public int? LaLvlGrpId { get; set; }

    public int? CmpId { get; set; }
}
