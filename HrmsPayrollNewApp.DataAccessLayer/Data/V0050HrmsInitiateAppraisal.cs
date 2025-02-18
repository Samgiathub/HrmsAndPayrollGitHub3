using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050HrmsInitiateAppraisal
{
    public decimal InitiateId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? AppraiserId { get; set; }

    public DateTime? SaStartdate { get; set; }

    public DateTime? SaEnddate { get; set; }

    public string? SaEmpComments { get; set; }

    public string? SaAppComments { get; set; }

    public int? SaStatus { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? AppraiserCode { get; set; }

    public string? AppraiserName { get; set; }

    public DateTime? SaSubmissionDate { get; set; }

    public DateTime? SaApprovedDate { get; set; }

    public decimal? SaApprovedBy { get; set; }

    public string? ApprovedName { get; set; }

    public string? ApprovedCode { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? Expr1 { get; set; }

    public string Appraiser { get; set; } = null!;

    public string Approvedby { get; set; } = null!;

    public decimal? OverallScore { get; set; }

    public decimal OverallScoreHod { get; set; }

    public decimal OverallScoreRm { get; set; }

    public decimal OverallScoreGh { get; set; }

    public string? OldRefNo { get; set; }

    public int? OverallStatus { get; set; }

    public decimal? PerApprovedBy { get; set; }

    public DateTime? AppraiserDate { get; set; }

    public string? PerApprovedName { get; set; }

    public string? PerApprovedCode { get; set; }

    public string PerApprovedBy1 { get; set; } = null!;

    public decimal? AchivementId { get; set; }

    public string? RangeLevel { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public string? GrdName { get; set; }

    public decimal? DeptId { get; set; }

    public int? SaSendToRm { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? PromoDesig { get; set; }

    public int? SendToHod { get; set; }

    public decimal? HodApprovedBy { get; set; }

    public DateTime? HodApprovedOn { get; set; }

    public decimal? HodId { get; set; }

    public int? DirectScore { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? TypeId { get; set; }

    public int? DurationFromMonth { get; set; }

    public int? DurationToMonth { get; set; }

    public decimal? PromoGrade { get; set; }

    public int? FinancialYear { get; set; }

    public int? FinalEvaluation { get; set; }

    public int? PromoYesNo { get; set; }

    public DateTime? PromoWef { get; set; }

    public int? JrYesNo { get; set; }

    public decimal? GhId { get; set; }

    public byte RmRequired { get; set; }

    public string ReviewType { get; set; } = null!;

    public string? EmpLeft { get; set; }

    public int EmpEngagement { get; set; }

    public string EmpEngagementComment { get; set; } = null!;

    public int AchivementIdRm { get; set; }

    public int AchivementIdHod { get; set; }

    public int AchivementIdGh { get; set; }

    public string? DurationFromMonth1 { get; set; }

    public string? DurationToMonth1 { get; set; }

    public int SendDirectlyPerformanceAssessment { get; set; }

    public string? AppraiserComment { get; set; }
}
