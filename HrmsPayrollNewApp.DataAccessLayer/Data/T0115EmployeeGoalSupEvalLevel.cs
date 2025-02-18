using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115EmployeeGoalSupEvalLevel
{
    public decimal SupEvalLevelId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? EmpGoalSettingReviewId { get; set; }

    public decimal? SupEvalId { get; set; }

    public string? SupEvalComments { get; set; }

    public string? YearEndFinalRating { get; set; }

    public string? YearEndNormalRating { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public int? RptLevel { get; set; }

    public decimal? EgsReviewLevelId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0110EmployeeGoalSettingEvaluationApproval? EgsReviewLevel { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0095EmployeeGoalSettingEvaluation? EmpGoalSettingReview { get; set; }

    public virtual T0100EmployeeGoalSupEval? SupEval { get; set; }
}
