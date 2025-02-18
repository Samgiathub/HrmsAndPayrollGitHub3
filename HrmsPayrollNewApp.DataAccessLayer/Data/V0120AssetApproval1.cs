using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120AssetApproval1
{
    public DateTime? AssetApprovalDate { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal? ApplicationCode { get; set; }

    public decimal? AssetApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetApprovalId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? EmpBranch { get; set; }

    public string? EmpFullName { get; set; }

    public string Status { get; set; } = null!;

    public string? EmpFirstName { get; set; }

    public string ApplicationType { get; set; } = null!;

    public string? EmpCode { get; set; }

    public string? ApprovedBy { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string? AppliedByName { get; set; }

    public string? AssetName1 { get; set; }

    public string? AssetName { get; set; }
}
