using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0091EmployeeGoalScore
{
    public decimal EmpGoalSId { get; set; }

    public decimal? ApprDetailId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? EmpGoalId { get; set; }

    public int? GoalRate { get; set; }

    public string? Comments { get; set; }

    public int? GoalStatus { get; set; }

    public int? EmpStatus { get; set; }

    public virtual T0090HrmsAppraisalInitiationDetail? ApprDetail { get; set; }

    public virtual T0090EmpGoalDetail? EmpGoal { get; set; }
}
