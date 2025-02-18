using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052ResumeFinalApproval
{
    public decimal CanAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? ResumeFinalId { get; set; }

    public decimal? ApproverEmpId { get; set; }

    public int? IsFinal { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? CanAppStatus { get; set; }

    public decimal? ResumeId { get; set; }

    public int? ResumeStatus { get; set; }

    public decimal? RecPostId { get; set; }

    public string? Comments { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public DateTime? JoiningDate { get; set; }

    public decimal? BasicSalay { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? TotalCtc { get; set; }

    public decimal? ReportingManagerId { get; set; }

    public string? Remarks { get; set; }

    public decimal? ShiftId { get; set; }

    public decimal? EmploymentTypeId { get; set; }

    public int? RptLevel { get; set; }

    public decimal? RCmpId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? GrossSalary { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }

    public virtual T0052HrmsPostedRecruitment? RecPost { get; set; }

    public virtual T0055ResumeMaster? Resume { get; set; }

    public virtual T0060ResumeFinal? ResumeFinal { get; set; }

    public virtual T0040ShiftMaster? Shift { get; set; }

    public virtual T0050SubVertical? SubVertical { get; set; }

    public virtual ICollection<T0100HrmsCandidateSchemeLevel> T0100HrmsCandidateSchemeLevels { get; set; } = new List<T0100HrmsCandidateSchemeLevel>();

    public virtual ICollection<T0100HrmsResumeEarnDeductionLevel> T0100HrmsResumeEarnDeductionLevels { get; set; } = new List<T0100HrmsResumeEarnDeductionLevel>();

    public virtual T0040VerticalSegment? Vertical { get; set; }
}
