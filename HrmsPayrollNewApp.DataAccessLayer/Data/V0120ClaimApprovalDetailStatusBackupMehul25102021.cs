using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120ClaimApprovalDetailStatusBackupMehul25102021
{
    public decimal EmpId { get; set; }

    public decimal ClaimAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimAppId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public decimal? ClaimAprPendingAmount { get; set; }

    public string? EmpLeft { get; set; }

    public decimal EmpCode { get; set; }

    public string? ClaimAprStatus { get; set; }

    public DateTime ClaimAprDate { get; set; }

    public DateTime? ClaimAppDate { get; set; }

    public decimal SEmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal GrdId { get; set; }

    public string? ClaimAppCode { get; set; }

    public string? ClaimAppDoc { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string ClaimLimitType { get; set; } = null!;

    public string? OtherEmail { get; set; }

    public string? MobileNo { get; set; }

    public string? WorkEmail { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string ClaimName { get; set; } = null!;

    public string? Designation { get; set; }

    public string? Department { get; set; }

    public string? BranchName1 { get; set; }

    public string GradeName { get; set; } = null!;
}
