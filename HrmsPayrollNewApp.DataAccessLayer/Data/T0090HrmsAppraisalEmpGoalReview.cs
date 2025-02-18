using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpGoalReview
{
    public decimal ReviewGoalId { get; set; }

    public decimal ReviewGoalCmpId { get; set; }

    public decimal FkGoalId { get; set; }

    public decimal FkGoalDescriptionId { get; set; }

    public decimal FkEmployeeId { get; set; }

    public string? Comment { get; set; }

    public decimal? FkRating { get; set; }

    public byte? ReviewGoalSignoff { get; set; }

    public DateTime? ReviewGoalSignoffDate { get; set; }

    public byte IsEmpManager { get; set; }

    public decimal FkSettingId { get; set; }

    public decimal ReviewGoalCreatedBy { get; set; }

    public DateTime ReviewGoalCreatedDate { get; set; }

    public decimal? ReviewGoalModifyBy { get; set; }

    public DateTime? ReviewGoalModifyDate { get; set; }

    public virtual T0090HrmsAppraisalEmpGoal FkGoal { get; set; } = null!;

    public virtual T0090HrmsAppraisalEmpGoalDescription FkGoalDescription { get; set; } = null!;

    public virtual T0040HrmsAppraisalSignoffSettingMaster FkSetting { get; set; } = null!;
}
