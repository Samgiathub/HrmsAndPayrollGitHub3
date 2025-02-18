using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050InitiateEmpDetail
{
    public decimal InitiateId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? AppraiserId { get; set; }

    public DateTime? SaStartdate { get; set; }

    public string? SaEmpComments { get; set; }

    public DateTime? SaEnddate { get; set; }

    public string? SaAppComments { get; set; }

    public int? SaStatus { get; set; }

    public decimal? KpaScore { get; set; }

    public decimal? KpaFinal { get; set; }

    public DateTime? SaSubmissionDate { get; set; }

    public DateTime? SaApprovedDate { get; set; }

    public decimal? PfFinal { get; set; }

    public decimal? PoScore { get; set; }

    public decimal? PfScore { get; set; }

    public decimal? PoFinal { get; set; }

    public decimal? OverallScore { get; set; }

    public decimal? AchivementId { get; set; }

    public string? AppraiserComment { get; set; }

    public int? PromoYesNo { get; set; }

    public decimal? PromoDesig { get; set; }

    public DateTime? PromoWef { get; set; }

    public int? JrYesNo { get; set; }

    public DateTime? JrFrom { get; set; }

    public DateTime? JrTo { get; set; }

    public int? IncYesNo { get; set; }

    public string? IncReason { get; set; }

    public string? ReviewerComment { get; set; }

    public DateTime? AppraiserDate { get; set; }

    public decimal? SaApprovedBy { get; set; }

    public decimal? PerApprovedBy { get; set; }

    public int? OverallStatus { get; set; }

    public string? GhComment { get; set; }

    public decimal? Expr1 { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public string? WorkEmail { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? REmpId { get; set; }

    public string? OldRefNo { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public string Superior { get; set; } = null!;

    public decimal? SuperiorId { get; set; }

    public string? RangeLevel { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GrdId { get; set; }

    public string? GrdName { get; set; }

    public int? SendToHod { get; set; }

    public decimal? HodApprovedBy { get; set; }

    public decimal? HodId { get; set; }

    public decimal? GhId { get; set; }

    public byte RmRequired { get; set; }

    public string ReviewType { get; set; } = null!;

    public string? EmpLeft { get; set; }

    public string? DurationFromMonth { get; set; }

    public string? DurationToMonth { get; set; }

    public string? ApprovalStatus { get; set; }
}
