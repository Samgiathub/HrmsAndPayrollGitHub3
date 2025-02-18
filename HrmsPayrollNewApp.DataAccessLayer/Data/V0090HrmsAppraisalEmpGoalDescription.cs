using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalEmpGoalDescription
{
    public decimal GoalDescriptionId { get; set; }

    public decimal FkGoalId { get; set; }

    public decimal GoalDescriptionCmpId { get; set; }

    public string GoalDescription { get; set; } = null!;

    public string SuccessCriteria { get; set; } = null!;

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

    public string? Rating { get; set; }

    public string? EmpFullName { get; set; }

    public string? SupFullName { get; set; }

    public decimal? FkGoalType { get; set; }

    public string? GoalType { get; set; }
}
