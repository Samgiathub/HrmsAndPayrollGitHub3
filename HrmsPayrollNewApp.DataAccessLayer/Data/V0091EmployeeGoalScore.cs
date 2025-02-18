using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0091EmployeeGoalScore
{
    public string? GoalTitle { get; set; }

    public decimal EmpGoalSId { get; set; }

    public decimal? ApprDetailId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? EmpGoalId { get; set; }

    public int? GoalRate { get; set; }

    public string? Comments { get; set; }

    public int? GoalStatus { get; set; }

    public int? EmpStatus { get; set; }

    public string? GlStatus { get; set; }

    public string? Description { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }
}
