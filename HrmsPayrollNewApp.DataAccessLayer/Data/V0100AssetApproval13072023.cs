using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100AssetApproval13072023
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

    public string Status { get; set; } = null!;

    public string AllocationDate { get; set; } = null!;

    public string ReturnDate { get; set; } = null!;

    public string? EmpFirstName { get; set; }

    public decimal? AppliedBy { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? EmpDept { get; set; }

    public int? BranchForDept { get; set; }

    public int? TransferBranchForDept { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpCode { get; set; }

    public string? ApplicationType1 { get; set; }

    public int AssetMId { get; set; }

    public string? AppliedByEmpCode { get; set; }

    public string? AppliedByName { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? TransferId { get; set; }

    public string? AssetName1 { get; set; }

    public decimal? TransferEmpId { get; set; }

    public decimal? TransferBranchId { get; set; }

    public string? TransferFrom { get; set; }

    public decimal? TransferDeptId { get; set; }

    public string? AssetName { get; set; }
}
