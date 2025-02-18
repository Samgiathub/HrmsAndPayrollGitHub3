using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpSolassessmentDtl
{
    public decimal SolassessmentDtlId { get; set; }

    public decimal SolassessmentDtlCmpId { get; set; }

    public decimal FkSolassessmentId { get; set; }

    public decimal FkSol { get; set; }

    public decimal FkEmployeeId { get; set; }

    public string? IndicativeExample { get; set; }

    public string? DepartmentActionPlan { get; set; }

    public decimal? FkRatingEmp { get; set; }

    public decimal? FkRatingSup { get; set; }

    public byte? ReviewSolSignoff { get; set; }

    public DateTime? ReviewSolSignoffDate { get; set; }

    public byte IsEmpManager { get; set; }

    public decimal FkSettingId { get; set; }

    public decimal SolassessmentDtlCreatedBy { get; set; }

    public DateTime SolassessmentDtlCreatedDate { get; set; }

    public decimal? SolassessmentDtlModifyBy { get; set; }

    public DateTime? SolassessmentDtlModifyDate { get; set; }

    public virtual T0040HrmsAppraisalSignoffSettingMaster FkSetting { get; set; } = null!;

    public virtual T0040HrmsAppraisalSolMaster FkSolNavigation { get; set; } = null!;

    public virtual T0090HrmsAppraisalEmpSolassessment FkSolassessment { get; set; } = null!;
}
