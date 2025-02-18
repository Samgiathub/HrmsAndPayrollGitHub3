using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100AssetStatusDetail
{
    public DateTime ApplicationDate { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public string? EmpCode { get; set; }

    public string Remarks { get; set; } = null!;

    public decimal EmpId { get; set; }

    public string? EmpFirstName { get; set; }

    public string? AssetMId { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? EmpBranch { get; set; }

    public decimal? EmpId1 { get; set; }

    public string? DeptName { get; set; }

    public decimal? DeptId { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public string ApplicationType { get; set; } = null!;

    public decimal AssetApplicationId { get; set; }

    public string? AssetName1 { get; set; }

    public string? AssetName { get; set; }
}
