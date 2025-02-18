using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmployeeGoalSupEval
{
    public decimal SupEvalId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? EmpGoalSettingReviewId { get; set; }

    public string? SupEvalComments { get; set; }

    public string? YearEndFinalRating { get; set; }

    public string? YearEndNormalRating { get; set; }

    public bool? SupPromoRecommend { get; set; }

    public bool? FinalPromoRecommend { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0095EmployeeGoalSettingEvaluation? EmpGoalSettingReview { get; set; }

    public virtual ICollection<T0115EmployeeGoalSupEvalLevel> T0115EmployeeGoalSupEvalLevels { get; set; } = new List<T0115EmployeeGoalSupEvalLevel>();
}
