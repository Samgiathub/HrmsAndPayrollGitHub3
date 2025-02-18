using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100AssetRejectDetail
{
    public decimal AssetApprovalId { get; set; }

    public decimal? AssetApplicationId { get; set; }

    public string? AssetName { get; set; }

    public string? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string BranchName { get; set; } = null!;

    public string? AllocationDate { get; set; }

    public string? ReturnDate { get; set; }

    public string AssetApprovalDate { get; set; } = null!;

    public string Status { get; set; } = null!;

    public string ApplicationType1 { get; set; } = null!;

    public decimal CmpId { get; set; }

    public string? AssetMId { get; set; }

    public string? AppliedByName { get; set; }

    public string? DeptName { get; set; }
}
