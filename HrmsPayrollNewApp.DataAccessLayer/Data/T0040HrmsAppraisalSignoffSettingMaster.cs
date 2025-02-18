using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsAppraisalSignoffSettingMaster
{
    public decimal SettingId { get; set; }

    public decimal SettingCmpId { get; set; }

    public decimal SettingEmpId { get; set; }

    public decimal SettingType { get; set; }

    public decimal SettingYear { get; set; }

    public DateTime SettingFromDate { get; set; }

    public DateTime SettingToDate { get; set; }

    public decimal SettingCreatedBy { get; set; }

    public DateTime SettingCreatedDate { get; set; }

    public decimal? SettingModifyBy { get; set; }

    public DateTime? SettingModifyDate { get; set; }

    public virtual ICollection<T0090HrmsAppraisalEmpGoalReview> T0090HrmsAppraisalEmpGoalReviews { get; set; } = new List<T0090HrmsAppraisalEmpGoalReview>();

    public virtual ICollection<T0090HrmsAppraisalEmpPerfSummReview> T0090HrmsAppraisalEmpPerfSummReviews { get; set; } = new List<T0090HrmsAppraisalEmpPerfSummReview>();

    public virtual ICollection<T0090HrmsAppraisalEmpSolassessmentDtl> T0090HrmsAppraisalEmpSolassessmentDtls { get; set; } = new List<T0090HrmsAppraisalEmpSolassessmentDtl>();
}
