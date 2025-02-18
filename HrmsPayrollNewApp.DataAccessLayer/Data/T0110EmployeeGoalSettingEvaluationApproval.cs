using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110EmployeeGoalSettingEvaluationApproval
{
    public decimal EgsReviewLevelId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? EmpGoalSettingReviewId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApprovalComments { get; set; }

    public string? AdditionalAchievement { get; set; }

    public decimal? LoginId { get; set; }

    public int? RptLevel { get; set; }

    public int? ApprovalStatus { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095EmployeeGoalSettingEvaluation? EmpGoalSettingReview { get; set; }

    public virtual ICollection<T0115EmployeeGoalSettingEvaluationDetailsLevel> T0115EmployeeGoalSettingEvaluationDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingEvaluationDetailsLevel>();

    public virtual ICollection<T0115EmployeeGoalSupEvalLevel> T0115EmployeeGoalSupEvalLevels { get; set; } = new List<T0115EmployeeGoalSupEvalLevel>();
}
