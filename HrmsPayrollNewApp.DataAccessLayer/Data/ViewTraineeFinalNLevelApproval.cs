using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewTraineeFinalNLevelApproval
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal BranchId { get; set; }

    public DateTime DateOfJoin { get; set; }

    public DateTime? ProbationDate { get; set; }

    public decimal RptLevel { get; set; }

    public decimal? DesigId { get; set; }

    public decimal SEmpIdA { get; set; }

    public string Status { get; set; } = null!;

    public DateTime EvaluationDate { get; set; }

    public DateTime? OldProbationEndDate { get; set; }

    public decimal TranId { get; set; }

    public decimal ProbationStatus { get; set; }

    public int SchemeId { get; set; }

    public int FinalApprover { get; set; }

    public int IsFwdLeaveRej { get; set; }

    public decimal? TrainingMonth { get; set; }

    public string? ReviewType { get; set; }

    public string? TrainingId { get; set; }

    public string? ApprovalPeriodType { get; set; }

    public string? MajorStrength { get; set; }

    public string? MajorWeakness { get; set; }

    public string? AppraiserRemarks { get; set; }

    public string? AppraisalReviewerRemarks { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public string? TypeName { get; set; }

    public decimal? ExtendPeriod { get; set; }

    public DateTime? NewProbationEndDate { get; set; }

    public decimal? DeptId { get; set; }
}
