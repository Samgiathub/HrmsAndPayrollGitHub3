using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewClaimFinalNLevelApproval
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? Supervisor { get; set; }

    public decimal ClaimAppId { get; set; }

    public string ClaimAppCode { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal? DesigId { get; set; }

    public string? DesigName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime ClaimAppDate { get; set; }

    public string? ApplicationStatus1 { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal ClaimApprovalId { get; set; }

    public decimal Clmaprid { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal BranchId { get; set; }

    public decimal? SEmpIdA { get; set; }

    public decimal? SEmpId { get; set; }

    public string? ClaimAppStatus { get; set; }

    public decimal CmpId { get; set; }

    public decimal GrdId { get; set; }

    public string Attachment { get; set; } = null!;

    public string MobileAttachment { get; set; } = null!;

    public DateTime ApprovalDate { get; set; }

    public string ClaimName { get; set; } = null!;

    public decimal? ClaimAppAmount { get; set; }

    public decimal? ClaimAprAmount { get; set; }

    public string? ClaimDateLabel { get; set; }
}
