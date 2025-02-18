using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpGoalDetail
{
    public string? GoalTitle { get; set; }

    public decimal EmpGoalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? GoalId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string GoalStatus { get; set; } = null!;

    public string? Description { get; set; }

    public string GoalS { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? AlphaEmpCode { get; set; }
}
