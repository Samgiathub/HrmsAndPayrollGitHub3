using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpGoal
{
    public decimal GoalId { get; set; }

    public decimal GoalCmpId { get; set; }

    public string GoalTitle { get; set; } = null!;

    public decimal FkGoalType { get; set; }

    public string? EmployeeComment { get; set; }

    public byte? EmployeeSignOff { get; set; }

    public DateTime? EmployeeSignOffDate { get; set; }

    public string? SupervisorComment { get; set; }

    public byte? SupervisorSignOff { get; set; }

    public DateTime? SupervisorSignOffDate { get; set; }

    public decimal? FkEmployeeId { get; set; }

    public decimal? FkSupervisorId { get; set; }

    public DateTime? GoalStartDate { get; set; }

    public DateTime? GoalEndDate { get; set; }

    public decimal? GoalYear { get; set; }

    public decimal GoalCreatedBy { get; set; }

    public DateTime GoalCreatedDate { get; set; }

    public decimal? GoalModifyBy { get; set; }

    public DateTime? GoalModifyDate { get; set; }

    public virtual ICollection<T0090HrmsAppraisalEmpGoalDescription> T0090HrmsAppraisalEmpGoalDescriptions { get; set; } = new List<T0090HrmsAppraisalEmpGoalDescription>();

    public virtual ICollection<T0090HrmsAppraisalEmpGoalReview> T0090HrmsAppraisalEmpGoalReviews { get; set; } = new List<T0090HrmsAppraisalEmpGoalReview>();

    public virtual ICollection<T0090HrmsAppraisalEmpGoalSignoffHistory> T0090HrmsAppraisalEmpGoalSignoffHistories { get; set; } = new List<T0090HrmsAppraisalEmpGoalSignoffHistory>();
}
