using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalEmpGoalReview
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

    public decimal? EmpReviewId { get; set; }

    public string? EmpCommentReview { get; set; }

    public decimal? EmpIdReview { get; set; }

    public decimal? EmpSettingIdReview { get; set; }

    public byte? EmpSignoffReview { get; set; }

    public DateTime? EmpSignoffDateReview { get; set; }

    public decimal? MngReviewId { get; set; }

    public string? MngCommentReview { get; set; }

    public decimal? MngRatingReview { get; set; }

    public decimal? MngEmployeeIdReview { get; set; }

    public decimal? MngSettingIdReview { get; set; }

    public byte? MngSignoffReview { get; set; }

    public DateTime? MngSignoffDateReview { get; set; }

    public byte? IsEmpManager { get; set; }
}
