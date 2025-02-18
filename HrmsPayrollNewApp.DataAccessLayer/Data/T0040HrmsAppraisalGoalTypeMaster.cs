using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsAppraisalGoalTypeMaster
{
    public decimal GoalTypeId { get; set; }

    public decimal GoalTypeCmpId { get; set; }

    public string GoalType { get; set; } = null!;

    public byte GoalTypeIsActive { get; set; }

    public decimal GoalTypeCreatedBy { get; set; }

    public DateTime GoalTypeCreatedDate { get; set; }

    public decimal? GoalTypeModifyBy { get; set; }

    public DateTime? GoalTypeModifyDate { get; set; }
}
