using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewTraineeProbationApproval
{
    public decimal ProbationEvaluationId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ProbationStatus { get; set; }

    public DateTime EvaluationDate { get; set; }

    public decimal? ExtendPeriod { get; set; }

    public decimal OldProbationPeriod { get; set; }

    public DateTime? OldProbationEndDate { get; set; }

    public DateTime? NewProbationEndDate { get; set; }

    public string? MajorStrength { get; set; }

    public string? MajorWeakness { get; set; }

    public string? AppraiserRemarks { get; set; }

    public string? AppraisalReviewerRemarks { get; set; }

    public decimal SupervisorId { get; set; }

    public string? Flag { get; set; }

    public string? TrainingId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public DateTime DateOfJoin { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime? ProbationDate { get; set; }

    public decimal IsOnTraining { get; set; }

    public byte? IsOnProbation { get; set; }

    public int CompletedMonth { get; set; }

    public string ReviewType { get; set; } = null!;

    public string? ReviewBy { get; set; }

    public string? ApprovalPeriodType { get; set; }

    public string? TypeName { get; set; }

    public string AttachDocs { get; set; } = null!;

    public decimal? MaxIncrementId { get; set; }

    public DateTime? ConfirmationDate { get; set; }

    public decimal EmpId1 { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }

    public decimal DeptId { get; set; }

    public decimal GrdId { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal? SalDateId { get; set; }

    public string? DeptName { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? Probation { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal CatId { get; set; }

    public decimal TypeId { get; set; }

    public decimal MaxIncrementId1 { get; set; }

    public byte IsProbationMonthDays { get; set; }
}
