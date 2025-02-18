using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115EmployeeGoalSettingEvaluationDetailsLevel
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpGoalSettingReviewDetailId { get; set; }

    public decimal? EgsReviewLevelId { get; set; }

    public int? RptLevel { get; set; }

    public decimal? EmpGoalSettingDetailId { get; set; }

    public string? Actual { get; set; }

    public string? SupScore { get; set; }

    public string? SupFeedback { get; set; }

    public decimal? WeightedScore { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0110EmployeeGoalSettingEvaluationApproval? EgsReviewLevel { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095EmployeeGoalSettingDetail? EmpGoalSettingDetail { get; set; }

    public virtual T0100EmployeeGoalSettingEvaluationDetail EmpGoalSettingReviewDetail { get; set; } = null!;
}
