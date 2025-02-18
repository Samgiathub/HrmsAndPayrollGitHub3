using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmployeeGoalSettingEvaluation
{
    public decimal EmpGoalSettingReviewId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int FinYear { get; set; }

    public int ReviewType { get; set; }

    public decimal ReviewStatus { get; set; }

    public string? EmpComments { get; set; }

    public string? ManagerComments { get; set; }

    public string? AdditionalAchievement { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0100EmployeeGoalSettingEvaluationDetail> T0100EmployeeGoalSettingEvaluationDetails { get; set; } = new List<T0100EmployeeGoalSettingEvaluationDetail>();

    public virtual ICollection<T0100EmployeeGoalSupEval> T0100EmployeeGoalSupEvals { get; set; } = new List<T0100EmployeeGoalSupEval>();

    public virtual ICollection<T0110EmployeeGoalSettingEvaluationApproval> T0110EmployeeGoalSettingEvaluationApprovals { get; set; } = new List<T0110EmployeeGoalSettingEvaluationApproval>();

    public virtual ICollection<T0115EmployeeGoalSupEvalLevel> T0115EmployeeGoalSupEvalLevels { get; set; } = new List<T0115EmployeeGoalSupEvalLevel>();
}
