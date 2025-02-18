using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmployeeGoalSettingEvaluationDetail
{
    public decimal EmpGoalSettingReviewDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpGoalSettingReviewId { get; set; }

    public decimal EmpGoalSettingDetailId { get; set; }

    public string? Actual { get; set; }

    public string? EmpFeedback { get; set; }

    public string? SupScore { get; set; }

    public string? SupFeedback { get; set; }

    public decimal? WeightedScore { get; set; }

    public int KpaTypeId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095EmployeeGoalSettingDetail EmpGoalSettingDetail { get; set; } = null!;

    public virtual T0095EmployeeGoalSettingEvaluation EmpGoalSettingReview { get; set; } = null!;

    public virtual ICollection<T0115EmployeeGoalSettingEvaluationDetailsLevel> T0115EmployeeGoalSettingEvaluationDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingEvaluationDetailsLevel>();
}
