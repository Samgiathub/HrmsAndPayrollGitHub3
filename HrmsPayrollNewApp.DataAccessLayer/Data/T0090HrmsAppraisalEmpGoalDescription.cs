using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpGoalDescription
{
    public decimal GoalDescriptionId { get; set; }

    public decimal FkGoalId { get; set; }

    public decimal GoalDescriptionCmpId { get; set; }

    public string GoalDescription { get; set; } = null!;

    public string SuccessCriteria { get; set; } = null!;

    public decimal? FkGoalType { get; set; }

    public string? AbovePar { get; set; }

    public string? AtPar { get; set; }

    public string? BelowPar { get; set; }

    public string? EmployeeComment { get; set; }

    public string? SupervisorComment { get; set; }

    public decimal? FkRating { get; set; }

    public decimal? FkEmployeeId { get; set; }

    public decimal? FkSupervisorId { get; set; }

    public decimal? GoalDescriptionYear { get; set; }

    public decimal GoalDescriptionCreatedBy { get; set; }

    public DateTime GoalDescriptionCreatedDate { get; set; }

    public decimal? GoalDescriptionModifyBy { get; set; }

    public DateTime? GoalDescriptionModifyDate { get; set; }

    public virtual T0090HrmsAppraisalEmpGoal FkGoal { get; set; } = null!;

    public virtual ICollection<T0090HrmsAppraisalEmpGoalReview> T0090HrmsAppraisalEmpGoalReviews { get; set; } = new List<T0090HrmsAppraisalEmpGoalReview>();
}
