using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095EmpGoalDetail
{
    public decimal EmpGoalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? GoalId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string GoalStatus { get; set; } = null!;

    public string? GoalTitle { get; set; }

    public decimal? Expr1 { get; set; }
}
