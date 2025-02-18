using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020SubGoalMaster
{
    public int CmpId { get; set; }

    public int SubGoalId { get; set; }

    public string SubGoalName { get; set; } = null!;

    public int IsActive { get; set; }

    public int GoalId { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
