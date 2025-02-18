using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpAssetDetail
{
    public string AssetName { get; set; } = null!;

    public decimal AssetId { get; set; }

    public decimal EmpAssetId { get; set; }

    public decimal CmpId { get; set; }

    public string ModelNo { get; set; } = null!;

    public string? IssueDate { get; set; }

    public string? ReturnDate { get; set; }

    public string? AssetComment { get; set; }

    public decimal EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpName { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? DateOfJoin { get; set; }
}
